#!/bin/bash
# =============================================================================
# Auto Compound Script
# =============================================================================
# Pipeline completo: report → PRD → tasks → implementación → PR
#
# Este script:
# 1. Lee el reporte más reciente con items priorizados
# 2. Selecciona el item #1 de prioridad
# 3. Crea un PRD para ese item
# 4. Convierte el PRD en tareas
# 5. Ejecuta el loop de implementación
# 6. Crea un PR con los cambios
#
# Uso: ./scripts/compound/auto-compound.sh [--dry-run] [--max-iterations N]
# =============================================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuración por defecto
MAX_ITERATIONS=${MAX_ITERATIONS:-25}
DRY_RUN=false

# Parsear argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --max-iterations)
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        *)
            echo "Argumento desconocido: $1"
            exit 1
            ;;
    esac
done

# Funciones de logging
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] ✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ❌ $1${NC}"
}

log_step() {
    echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')] 📌 $1${NC}"
}

# Directorio del proyecto
PROJECT_DIR="${PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
SCRIPTS_DIR="$PROJECT_DIR/scripts/compound"

log "=============================================="
log "       AUTO COMPOUND - PHP Development       "
log "=============================================="
log "Directorio: $PROJECT_DIR"
log "Max iteraciones: $MAX_ITERATIONS"
log "Dry run: $DRY_RUN"
echo ""

cd "$PROJECT_DIR"

# Cargar variables de entorno si existen
if [ -f ".env.local" ]; then
    source .env.local
    log "Variables de entorno cargadas desde .env.local"
fi

# =============================================================================
# PASO 1: Sincronizar repositorio
# =============================================================================
log_step "PASO 1: Sincronizando repositorio..."

MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

# Fetch con reintentos
MAX_RETRIES=4
RETRY_COUNT=0
RETRY_DELAY=2

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if git fetch origin "$MAIN_BRANCH" 2>/dev/null; then
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            log_warning "Error en fetch, reintentando en ${RETRY_DELAY}s..."
            sleep $RETRY_DELAY
            RETRY_DELAY=$((RETRY_DELAY * 2))
        fi
    fi
done

git reset --hard "origin/$MAIN_BRANCH"
log_success "Repositorio sincronizado con $MAIN_BRANCH"

# =============================================================================
# PASO 2: Encontrar reporte más reciente
# =============================================================================
log_step "PASO 2: Buscando reporte priorizado..."

REPORTS_DIR="$PROJECT_DIR/reports"

if [ ! -d "$REPORTS_DIR" ]; then
    log_error "Directorio de reportes no encontrado: $REPORTS_DIR"
    log "Creando directorio de reportes..."
    mkdir -p "$REPORTS_DIR"
fi

LATEST_REPORT=$(ls -t "$REPORTS_DIR"/*.md 2>/dev/null | head -1 || echo "")

if [ -z "$LATEST_REPORT" ]; then
    log_warning "No se encontraron reportes en $REPORTS_DIR"
    log "Creando reporte de ejemplo..."

    # Crear reporte de ejemplo
    cat > "$REPORTS_DIR/backlog.md" << 'EOF'
# Backlog Priorizado

## Prioridad Alta

1. **Refactorizar UserService** - Extraer lógica de autenticación a AuthService
2. **Implementar Value Objects** - Crear Email y UserId como value objects
3. **Agregar tests unitarios** - Cobertura mínima 80% para Domain layer

## Prioridad Media

4. **Optimizar queries N+1** - Identificar y corregir en OrderRepository
5. **Documentar API** - Generar OpenAPI spec para endpoints públicos

## Prioridad Baja

6. **Actualizar dependencias** - Composer update con tests
7. **Limpiar código muerto** - Remover clases deprecated
EOF

    LATEST_REPORT="$REPORTS_DIR/backlog.md"
    log_success "Reporte de ejemplo creado: $LATEST_REPORT"
fi

log "Reporte encontrado: $LATEST_REPORT"

# =============================================================================
# PASO 3: Analizar reporte y obtener prioridad #1
# =============================================================================
log_step "PASO 3: Analizando reporte..."

# Ejecutar script de análisis
ANALYSIS=$("$SCRIPTS_DIR/analyze-report.sh" "$LATEST_REPORT")

PRIORITY_ITEM=$(echo "$ANALYSIS" | jq -r '.priority_item // empty' 2>/dev/null || echo "")
BRANCH_NAME=$(echo "$ANALYSIS" | jq -r '.branch_name // empty' 2>/dev/null || echo "")

if [ -z "$PRIORITY_ITEM" ]; then
    # Fallback: extraer manualmente el primer item
    PRIORITY_ITEM=$(grep -E "^[0-9]+\." "$LATEST_REPORT" | head -1 | sed 's/^[0-9]*\.\s*//' | sed 's/\*\*//g')
    BRANCH_NAME="feature/$(echo "$PRIORITY_ITEM" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | cut -c1-50)"
fi

if [ -z "$PRIORITY_ITEM" ]; then
    log_error "No se pudo extraer item de prioridad del reporte"
    exit 1
fi

log_success "Item priorizado: $PRIORITY_ITEM"
log "Rama: $BRANCH_NAME"

# =============================================================================
# PASO 4: Crear rama de feature
# =============================================================================
log_step "PASO 4: Creando rama de feature..."

if $DRY_RUN; then
    log_warning "[DRY RUN] Se crearía rama: $BRANCH_NAME"
else
    git checkout -b "$BRANCH_NAME" 2>/dev/null || git checkout "$BRANCH_NAME"
    log_success "Rama creada/activada: $BRANCH_NAME"
fi

# =============================================================================
# PASO 5: Crear PRD
# =============================================================================
log_step "PASO 5: Creando PRD..."

PRD_NAME=$(echo "$BRANCH_NAME" | sed 's/feature\///')
PRD_FILE="tasks/prd-${PRD_NAME}.md"

PRD_PROMPT="Usa el comando /prd para crear un Product Requirement Document para:

$PRIORITY_ITEM

Contexto del proyecto: Este es un proyecto PHP siguiendo las convenciones en CLAUDE.md.

Guarda el PRD en: $PRD_FILE"

if $DRY_RUN; then
    log_warning "[DRY RUN] Se crearía PRD: $PRD_FILE"
else
    if command -v claude &> /dev/null; then
        echo "$PRD_PROMPT" | claude -p --dangerously-skip-permissions
        log_success "PRD creado: $PRD_FILE"
    else
        log_error "Claude Code no disponible"
        exit 1
    fi
fi

# =============================================================================
# PASO 6: Convertir PRD a tareas
# =============================================================================
log_step "PASO 6: Convirtiendo PRD a tareas..."

TASKS_PROMPT="Usa el comando /tasks para convertir el PRD en $PRD_FILE a tareas ejecutables.

Guarda las tareas en: scripts/compound/prd.json"

if $DRY_RUN; then
    log_warning "[DRY RUN] Se convertirían tareas desde: $PRD_FILE"
else
    if command -v claude &> /dev/null; then
        echo "$TASKS_PROMPT" | claude -p --dangerously-skip-permissions
        log_success "Tareas generadas en scripts/compound/prd.json"
    fi
fi

# =============================================================================
# PASO 7: Ejecutar loop de implementación
# =============================================================================
log_step "PASO 7: Ejecutando loop de implementación..."

if $DRY_RUN; then
    log_warning "[DRY RUN] Se ejecutaría loop con $MAX_ITERATIONS iteraciones"
else
    "$SCRIPTS_DIR/loop.sh" "$MAX_ITERATIONS"
    log_success "Loop de implementación completado"
fi

# =============================================================================
# PASO 8: Crear PR
# =============================================================================
log_step "PASO 8: Creando Pull Request..."

if $DRY_RUN; then
    log_warning "[DRY RUN] Se crearía PR para rama: $BRANCH_NAME"
else
    # Push con reintentos
    RETRY_COUNT=0
    RETRY_DELAY=2

    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        if git push -u origin "$BRANCH_NAME" 2>/dev/null; then
            log_success "Push exitoso a origin/$BRANCH_NAME"
            break
        else
            RETRY_COUNT=$((RETRY_COUNT + 1))
            if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
                log_warning "Error en push, reintentando en ${RETRY_DELAY}s..."
                sleep $RETRY_DELAY
                RETRY_DELAY=$((RETRY_DELAY * 2))
            else
                log_error "No se pudo hacer push después de $MAX_RETRIES intentos"
                exit 1
            fi
        fi
    done

    # Crear PR con gh
    if command -v gh &> /dev/null; then
        PR_BODY="## Summary
- Implementación automática de: $PRIORITY_ITEM
- Generado por Auto Compound Script

## Contexto
- PRD: $PRD_FILE
- Tareas: scripts/compound/prd.json

## Test plan
- [ ] Verificar que los tests pasan
- [ ] Revisar cambios de código
- [ ] Validar contra criterios de aceptación del PRD

---
*Generado automáticamente por auto-compound.sh*"

        PR_URL=$(gh pr create --draft --title "Compound: $PRIORITY_ITEM" --base "$MAIN_BRANCH" --body "$PR_BODY" 2>/dev/null || echo "")

        if [ -n "$PR_URL" ]; then
            log_success "PR creado: $PR_URL"
        else
            log_warning "No se pudo crear PR automáticamente"
        fi
    else
        log_warning "gh CLI no disponible, crear PR manualmente"
    fi
fi

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
log "=============================================="
log "              RESUMEN                         "
log "=============================================="
log_success "Auto Compound completado"
log "Item implementado: $PRIORITY_ITEM"
log "Rama: $BRANCH_NAME"
log "PRD: $PRD_FILE"
echo ""

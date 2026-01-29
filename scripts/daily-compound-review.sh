#!/bin/bash
# =============================================================================
# Daily Compound Review Script
# =============================================================================
# Este script revisa los threads de las últimas 24 horas y extrae aprendizajes
# que no fueron capturados durante las sesiones de trabajo.
#
# Ejecutar ANTES de auto-compound.sh para actualizar CLAUDE.md con aprendizajes.
#
# Uso: ./scripts/daily-compound-review.sh
# =============================================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
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

# Directorio del proyecto (puede ser sobrescrito con variable de entorno)
PROJECT_DIR="${PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

log "Iniciando Daily Compound Review..."
log "Directorio del proyecto: $PROJECT_DIR"

# Cambiar al directorio del proyecto
cd "$PROJECT_DIR"

# Verificar que estamos en un repositorio git
if [ ! -d ".git" ]; then
    log_error "No es un repositorio git. Abortando."
    exit 1
fi

# Verificar que existe CLAUDE.md
if [ ! -f "CLAUDE.md" ]; then
    log_error "CLAUDE.md no encontrado. Abortando."
    exit 1
fi

# Asegurar que estamos en main y actualizado
log "Sincronizando con rama principal..."
MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

git checkout "$MAIN_BRANCH" 2>/dev/null || {
    log_warning "No se pudo cambiar a $MAIN_BRANCH, continuando en rama actual"
}

# Intentar pull con reintentos
MAX_RETRIES=4
RETRY_COUNT=0
RETRY_DELAY=2

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if git pull origin "$MAIN_BRANCH" 2>/dev/null; then
        log_success "Repositorio actualizado"
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            log_warning "Error en pull, reintentando en ${RETRY_DELAY}s... (intento $RETRY_COUNT/$MAX_RETRIES)"
            sleep $RETRY_DELAY
            RETRY_DELAY=$((RETRY_DELAY * 2))
        else
            log_warning "No se pudo hacer pull, continuando con versión local"
        fi
    fi
done

# Ejecutar Claude Code con el comando compound
log "Ejecutando revisión de compound engineering..."

# Prompt para Claude Code
COMPOUND_PROMPT="Carga la habilidad compound-engineering con /compound.

Revisa todos los threads de Claude Code de las últimas 24 horas. Para cada thread donde NO se usó la habilidad Compound Engineering al final para extraer aprendizajes, hazlo ahora:

1. Extrae los aprendizajes clave de ese thread
2. Actualiza las secciones relevantes de CLAUDE.md:
   - Patrones Descubiertos
   - Errores Comunes Evitados
   - Optimizaciones Aplicadas
   - Contexto del Proyecto

3. Haz commit de tus cambios con mensaje descriptivo
4. Push a la rama principal

Si no hay threads sin procesar o no hay aprendizajes nuevos, indica que la revisión está completa."

# Ejecutar Claude Code
# Nota: Ajustar según tu configuración de Claude Code
if command -v claude &> /dev/null; then
    echo "$COMPOUND_PROMPT" | claude -p --dangerously-skip-permissions
    CLAUDE_EXIT_CODE=$?
else
    log_error "Claude Code no está instalado o no está en el PATH"
    exit 1
fi

# Verificar resultado
if [ $CLAUDE_EXIT_CODE -eq 0 ]; then
    log_success "Daily Compound Review completado exitosamente"
else
    log_error "Daily Compound Review falló con código: $CLAUDE_EXIT_CODE"
    exit $CLAUDE_EXIT_CODE
fi

# Mostrar resumen de cambios
if git diff --quiet HEAD~1 CLAUDE.md 2>/dev/null; then
    log "No hubo cambios en CLAUDE.md"
else
    log_success "CLAUDE.md fue actualizado con nuevos aprendizajes"
    echo ""
    echo "Cambios realizados:"
    git diff HEAD~1 CLAUDE.md --stat 2>/dev/null || true
fi

log_success "Script finalizado"

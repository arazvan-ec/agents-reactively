#!/bin/bash
# =============================================================================
# Execution Loop Script
# =============================================================================
# Ejecuta tareas de prd.json iterativamente hasta completarlas o alcanzar
# el límite de iteraciones.
#
# Uso: ./scripts/compound/loop.sh [max_iterations]
# =============================================================================

set -e

# Configuración
MAX_ITERATIONS=${1:-25}
ITERATION=0

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Directorio del proyecto
PROJECT_DIR="${PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
TASKS_FILE="$PROJECT_DIR/scripts/compound/prd.json"

# Funciones de logging
log() {
    echo -e "${BLUE}[LOOP $(date '+%H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[LOOP $(date '+%H:%M:%S')] ✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}[LOOP $(date '+%H:%M:%S')] ⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}[LOOP $(date '+%H:%M:%S')] ❌ $1${NC}"
}

log_task() {
    echo -e "${CYAN}[LOOP $(date '+%H:%M:%S')] 📌 $1${NC}"
}

# Función para obtener siguiente tarea pendiente
get_next_task() {
    if [ ! -f "$TASKS_FILE" ]; then
        echo ""
        return
    fi

    # Obtener primera tarea pendiente sin dependencias incompletas
    python3 << EOF 2>/dev/null || echo ""
import json
import sys

try:
    with open('$TASKS_FILE', 'r') as f:
        data = json.load(f)

    tasks = data.get('tasks', [])
    completed_ids = {t['id'] for t in tasks if t.get('status') == 'completed'}

    for task in tasks:
        if task.get('status') == 'pending':
            deps = task.get('dependencies', [])
            if all(dep in completed_ids for dep in deps):
                print(json.dumps(task))
                sys.exit(0)

    print('')
except Exception as e:
    print('')
EOF
}

# Función para marcar tarea como en progreso
mark_in_progress() {
    local task_id=$1

    python3 << EOF
import json

with open('$TASKS_FILE', 'r') as f:
    data = json.load(f)

for task in data['tasks']:
    if task['id'] == $task_id:
        task['status'] = 'in_progress'
        break

with open('$TASKS_FILE', 'w') as f:
    json.dump(data, f, indent=2)
EOF
}

# Función para marcar tarea como completada
mark_completed() {
    local task_id=$1

    python3 << EOF
import json

with open('$TASKS_FILE', 'r') as f:
    data = json.load(f)

for task in data['tasks']:
    if task['id'] == $task_id:
        task['status'] = 'completed'
        break

data['completed_tasks'] = sum(1 for t in data['tasks'] if t.get('status') == 'completed')

with open('$TASKS_FILE', 'w') as f:
    json.dump(data, f, indent=2)
EOF
}

# Función para obtener progreso
get_progress() {
    if [ ! -f "$TASKS_FILE" ]; then
        echo "0/0"
        return
    fi

    python3 << EOF
import json

try:
    with open('$TASKS_FILE', 'r') as f:
        data = json.load(f)

    total = len(data.get('tasks', []))
    completed = sum(1 for t in data.get('tasks', []) if t.get('status') == 'completed')
    print(f"{completed}/{total}")
except:
    print("0/0")
EOF
}

# Función para verificar si todas las tareas están completadas
all_completed() {
    if [ ! -f "$TASKS_FILE" ]; then
        return 1
    fi

    python3 << EOF
import json
import sys

try:
    with open('$TASKS_FILE', 'r') as f:
        data = json.load(f)

    tasks = data.get('tasks', [])
    if not tasks:
        sys.exit(1)

    all_done = all(t.get('status') == 'completed' for t in tasks)
    sys.exit(0 if all_done else 1)
except:
    sys.exit(1)
EOF
}

# =============================================================================
# LOOP PRINCIPAL
# =============================================================================

cd "$PROJECT_DIR"

log "=============================================="
log "     EXECUTION LOOP - PHP Development        "
log "=============================================="
log "Max iteraciones: $MAX_ITERATIONS"
log "Archivo de tareas: $TASKS_FILE"
echo ""

# Verificar archivo de tareas
if [ ! -f "$TASKS_FILE" ]; then
    log_warning "Archivo de tareas no encontrado: $TASKS_FILE"
    log "Ejecuta /tasks primero para generar las tareas"
    exit 1
fi

# Loop principal
while [ $ITERATION -lt $MAX_ITERATIONS ]; do
    ITERATION=$((ITERATION + 1))

    log "----------------------------------------------"
    log "Iteración $ITERATION/$MAX_ITERATIONS"
    log "Progreso: $(get_progress)"
    echo ""

    # Verificar si todas las tareas están completadas
    if all_completed; then
        log_success "¡Todas las tareas completadas!"
        break
    fi

    # Obtener siguiente tarea
    NEXT_TASK=$(get_next_task)

    if [ -z "$NEXT_TASK" ]; then
        log_warning "No hay tareas pendientes disponibles"
        log "Puede haber dependencias circulares o todas las tareas están en progreso"
        break
    fi

    # Extraer información de la tarea
    TASK_ID=$(echo "$NEXT_TASK" | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])")
    TASK_TITLE=$(echo "$NEXT_TASK" | python3 -c "import json,sys; print(json.load(sys.stdin)['title'])")
    TASK_DESC=$(echo "$NEXT_TASK" | python3 -c "import json,sys; print(json.load(sys.stdin).get('description', ''))")
    TASK_TYPE=$(echo "$NEXT_TASK" | python3 -c "import json,sys; print(json.load(sys.stdin).get('type', 'general'))")
    TASK_FILES=$(echo "$NEXT_TASK" | python3 -c "import json,sys; print(', '.join(json.load(sys.stdin).get('files', [])))")
    TASK_CRITERIA=$(echo "$NEXT_TASK" | python3 -c "import json,sys; print('\\n'.join('- ' + c for c in json.load(sys.stdin).get('acceptance_criteria', [])))")

    log_task "Tarea #$TASK_ID: $TASK_TITLE"
    log "Tipo: $TASK_TYPE"
    if [ -n "$TASK_FILES" ]; then
        log "Archivos: $TASK_FILES"
    fi
    echo ""

    # Marcar como en progreso
    mark_in_progress "$TASK_ID"

    # Construir prompt para Claude
    TASK_PROMPT="Estás trabajando en la tarea #$TASK_ID del archivo prd.json.

## Tarea
**Título**: $TASK_TITLE
**Tipo**: $TASK_TYPE
**Descripción**: $TASK_DESC

## Archivos a modificar/crear
$TASK_FILES

## Criterios de aceptación
$TASK_CRITERIA

## Instrucciones
1. Lee CLAUDE.md para entender las convenciones del proyecto PHP
2. Implementa la tarea siguiendo los patrones establecidos
3. Ejecuta los tests si existen
4. Haz commit de los cambios con mensaje descriptivo

Si encuentras errores o la tarea no puede completarse, describe el problema claramente."

    # Ejecutar Claude Code
    log "Ejecutando Claude Code para implementar tarea..."

    if command -v claude &> /dev/null; then
        if echo "$TASK_PROMPT" | claude -p --dangerously-skip-permissions; then
            mark_completed "$TASK_ID"
            log_success "Tarea #$TASK_ID completada"
        else
            log_error "Error ejecutando tarea #$TASK_ID"
            log "La tarea permanece en estado 'in_progress'"
            # No marcamos como fallida, podría reintentarse
        fi
    else
        log_error "Claude Code no disponible"
        exit 1
    fi

    echo ""

    # Pequeña pausa entre iteraciones
    sleep 2
done

# Resumen final
echo ""
log "=============================================="
log "              RESUMEN FINAL                   "
log "=============================================="
log "Iteraciones ejecutadas: $ITERATION"
log "Progreso final: $(get_progress)"

if all_completed; then
    log_success "¡Todas las tareas completadas exitosamente!"
else
    log_warning "Algunas tareas quedaron pendientes"
    log "Ejecuta el loop nuevamente o completa manualmente"
fi

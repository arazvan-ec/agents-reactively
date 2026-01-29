#!/bin/bash
# =============================================================================
# Analyze Report Script
# =============================================================================
# Analiza un reporte de backlog priorizado y extrae el item #1 de prioridad.
#
# Uso: ./scripts/compound/analyze-report.sh <ruta-al-reporte>
# Output: JSON con priority_item y branch_name
# =============================================================================

set -e

# Verificar argumento
if [ -z "$1" ]; then
    echo "Uso: $0 <ruta-al-reporte>" >&2
    exit 1
fi

REPORT_FILE="$1"

if [ ! -f "$REPORT_FILE" ]; then
    echo "Error: Archivo no encontrado: $REPORT_FILE" >&2
    exit 1
fi

# Función para limpiar texto
clean_text() {
    echo "$1" | sed 's/\*\*//g' | sed 's/`//g' | sed 's/^[ \t]*//' | sed 's/[ \t]*$//'
}

# Función para generar nombre de rama
generate_branch_name() {
    local text="$1"
    echo "$text" | \
        tr '[:upper:]' '[:lower:]' | \
        sed 's/[áàäâ]/a/g' | \
        sed 's/[éèëê]/e/g' | \
        sed 's/[íìïî]/i/g' | \
        sed 's/[óòöô]/o/g' | \
        sed 's/[úùüû]/u/g' | \
        sed 's/ñ/n/g' | \
        sed 's/[^a-z0-9]/-/g' | \
        sed 's/--*/-/g' | \
        sed 's/^-//' | \
        sed 's/-$//' | \
        cut -c1-50
}

# Buscar el primer item de prioridad alta
# Patrones soportados:
# - "1. **Texto**" (markdown numbered list with bold)
# - "1. Texto" (simple numbered list)
# - "- **Texto**" (bullet with bold)
# - "- [ ] Texto" (checkbox)

PRIORITY_ITEM=""

# Intentar diferentes patrones en orden de prioridad

# Patrón 1: Lista numerada con negrita
if [ -z "$PRIORITY_ITEM" ]; then
    PRIORITY_ITEM=$(grep -E "^1\.\s*\*\*" "$REPORT_FILE" | head -1 | sed 's/^1\.\s*//' | sed 's/\*\*//g' | sed 's/\s*-\s*.*//')
fi

# Patrón 2: Lista numerada simple
if [ -z "$PRIORITY_ITEM" ]; then
    PRIORITY_ITEM=$(grep -E "^1\.\s+" "$REPORT_FILE" | head -1 | sed 's/^1\.\s*//' | sed 's/\s*-\s*.*//')
fi

# Patrón 3: Primera línea después de "Prioridad Alta" o "High Priority"
if [ -z "$PRIORITY_ITEM" ]; then
    PRIORITY_ITEM=$(grep -A1 -iE "(prioridad alta|high priority|## 1\.|#1)" "$REPORT_FILE" | tail -1 | sed 's/^[0-9]*\.\s*//' | sed 's/^-\s*//' | sed 's/\*\*//g')
fi

# Patrón 4: Primer item de cualquier lista
if [ -z "$PRIORITY_ITEM" ]; then
    PRIORITY_ITEM=$(grep -E "^(\s*[-*]|\s*[0-9]+\.)\s+" "$REPORT_FILE" | head -1 | sed 's/^[[:space:]]*[-*0-9.]*[[:space:]]*//' | sed 's/\*\*//g')
fi

# Limpiar el resultado
PRIORITY_ITEM=$(clean_text "$PRIORITY_ITEM")

if [ -z "$PRIORITY_ITEM" ]; then
    echo '{"error": "No se pudo extraer item de prioridad", "priority_item": null, "branch_name": null}'
    exit 1
fi

# Generar nombre de rama
BRANCH_NAME="feature/$(generate_branch_name "$PRIORITY_ITEM")"

# Extraer descripción adicional si existe (después de " - ")
DESCRIPTION=""
if echo "$PRIORITY_ITEM" | grep -q " - "; then
    DESCRIPTION=$(echo "$PRIORITY_ITEM" | sed 's/.*- //')
    PRIORITY_ITEM=$(echo "$PRIORITY_ITEM" | sed 's/ -.*//')
fi

# Output JSON
cat << EOF
{
    "priority_item": "$PRIORITY_ITEM",
    "description": "$DESCRIPTION",
    "branch_name": "$BRANCH_NAME",
    "source_file": "$REPORT_FILE",
    "analyzed_at": "$(date -Iseconds)"
}
EOF

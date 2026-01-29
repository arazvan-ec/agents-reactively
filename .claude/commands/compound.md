# Compound Engineering Skill

## Descripción

Esta habilidad permite extraer aprendizajes de la sesión actual y persistirlos en el archivo CLAUDE.md para que el conocimiento se acumule entre sesiones.

## Instrucciones

Cuando el usuario ejecute `/compound`, sigue estos pasos:

### 1. Analizar la Sesión

Revisa todo el trabajo realizado en esta sesión:
- Archivos creados o modificados
- Problemas encontrados y cómo se resolvieron
- Patrones de código utilizados
- Decisiones técnicas tomadas
- Errores cometidos y corregidos

### 2. Extraer Aprendizajes

Identifica información valiosa en estas categorías:

**Patrones Descubiertos**
- Nuevos patrones de código que funcionaron bien
- Estructuras reutilizables
- Soluciones elegantes a problemas comunes

**Errores Comunes Evitados**
- Bugs encontrados y su causa raíz
- Configuraciones incorrectas
- Malas prácticas identificadas

**Optimizaciones Aplicadas**
- Mejoras de rendimiento
- Refactorizaciones exitosas
- Simplificaciones de código

**Contexto del Proyecto**
- Información sobre la estructura del proyecto
- Dependencias importantes
- Configuraciones específicas

### 3. Actualizar CLAUDE.md

Añade los aprendizajes a las secciones correspondientes de CLAUDE.md:

```markdown
### Patrones Descubiertos

- **[Fecha] [Título del patrón]**: Descripción breve del patrón y cuándo usarlo.
  ```php
  // Ejemplo de código si aplica
  ```

### Errores Comunes Evitados

- **[Fecha] [Título del error]**: Descripción del error, por qué ocurre, y cómo evitarlo.

### Optimizaciones Aplicadas

- **[Fecha] [Título]**: Descripción de la optimización y su impacto.
```

### 4. Commit los Cambios

```bash
git add CLAUDE.md
git commit -m "compound: persist learnings from session

- [Lista breve de aprendizajes]

https://claude.ai/code/session_ID"
```

## Formato de Aprendizajes

Cada aprendizaje debe ser:
- **Específico**: No genérico, aplicable a este proyecto
- **Actionable**: Que se pueda aplicar en futuras sesiones
- **Conciso**: 1-3 oraciones máximo
- **Con ejemplo**: Código cuando sea relevante

## Ejemplo de Uso

```
Usuario: /compound

Agente: Analizando la sesión de trabajo...

📚 Aprendizajes extraídos:

**Patrones Descubiertos:**
- Uso de Data Transfer Objects para validación de requests en Laravel

**Errores Evitados:**
- El método `findOrFail` lanza excepción 404, no retorna null

**Optimizaciones:**
- Eager loading con `with()` para evitar N+1 queries

Actualizando CLAUDE.md y haciendo commit...
✅ Aprendizajes persistidos exitosamente.
```

## Notas

- Ejecutar `/compound` al final de cada sesión significativa
- No duplicar aprendizajes que ya existan en CLAUDE.md
- Si no hay nuevos aprendizajes, indicarlo al usuario

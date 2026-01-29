# PRD (Product Requirement Document) Skill

## Descripción

Esta habilidad permite crear documentos de requisitos estructurados para nuevas funcionalidades o refactorizaciones.

## Instrucciones

Cuando el usuario ejecute `/prd [descripción]`, crea un PRD siguiendo esta estructura:

### Plantilla PRD

```markdown
# PRD: [Título de la Funcionalidad]

## Resumen Ejecutivo

[1-2 párrafos describiendo qué se va a construir y por qué]

## Problema

### Situación Actual
- [Descripción del estado actual]
- [Limitaciones o problemas existentes]

### Impacto
- [Quién se ve afectado]
- [Cuánto cuesta el problema actual]

## Solución Propuesta

### Descripción
[Descripción detallada de la solución]

### Alcance
**Incluido:**
- [ ] [Funcionalidad 1]
- [ ] [Funcionalidad 2]

**Excluido:**
- [Qué NO se incluye en esta iteración]

## Requisitos Técnicos

### Arquitectura
[Diagrama o descripción de la arquitectura]

### Componentes
1. **[Componente 1]**
   - Responsabilidad: [...]
   - Archivos: [...]

2. **[Componente 2]**
   - Responsabilidad: [...]
   - Archivos: [...]

### Dependencias
- [Paquetes necesarios]
- [Servicios externos]

### Base de Datos
[Migraciones necesarias, si aplica]

```sql
-- Ejemplo de migración
CREATE TABLE example (...);
```

## Criterios de Aceptación

- [ ] [Criterio 1]: [Descripción específica y medible]
- [ ] [Criterio 2]: [Descripción específica y medible]
- [ ] [Criterio 3]: [Descripción específica y medible]

## Plan de Testing

### Tests Unitarios
- [ ] [Test 1]
- [ ] [Test 2]

### Tests de Integración
- [ ] [Test 1]

### Tests E2E (si aplica)
- [ ] [Test 1]

## Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| [Riesgo 1] | Alta/Media/Baja | Alto/Medio/Bajo | [Estrategia] |

## Métricas de Éxito

- [Métrica 1]: [Valor objetivo]
- [Métrica 2]: [Valor objetivo]

## Timeline Estimado

| Fase | Descripción | Estimación |
|------|-------------|------------|
| 1 | [Fase 1] | [X tareas] |
| 2 | [Fase 2] | [X tareas] |

---

**Creado**: [Fecha]
**Autor**: Claude Agent
**Estado**: Draft
```

## Proceso

1. **Entender el contexto**: Leer CLAUDE.md para entender el proyecto
2. **Clarificar requisitos**: Hacer preguntas si algo no está claro
3. **Crear PRD**: Generar documento completo
4. **Guardar**: Crear archivo en `tasks/prd-[nombre].md`
5. **Confirmar**: Mostrar resumen al usuario

## Ejemplo de Uso

```
Usuario: /prd Implementar sistema de caché para queries frecuentes

Agente: Creando PRD para sistema de caché...

📄 PRD creado: tasks/prd-cache-system.md

Resumen:
- 5 componentes identificados
- 8 criterios de aceptación
- 3 riesgos documentados
- Estimación: 12 tareas

¿Deseas revisar el PRD o proceder a convertirlo en tareas con /tasks?
```

## Notas para PHP

Al crear PRDs para proyectos PHP, considerar:
- Compatibilidad con PSR standards
- Impacto en autoloading
- Necesidad de migraciones
- Cacheo de config y routes en producción

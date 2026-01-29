# Roadmap de Desarrollo - Plugin AI Workflow

## Principio Rector

> **"La mejor feature es la que no necesitas implementar"**

Cada propuesta debe justificar su existencia antes de escribir una sola línea de código.

---

## Framework de Evaluación Anti-Sobreingeniería

### Criterios de Decisión

| Criterio | Pregunta | Peso |
|----------|----------|------|
| **Problema Real** | ¿Resuelve un problema que existe HOY, no hipotético? | Alto |
| **Frecuencia** | ¿Se usaría al menos 1x por semana? | Alto |
| **Alternativa Simple** | ¿Se puede resolver con lo que ya existe? | Alto |
| **Complejidad** | ¿Añade más de 100 líneas de código? | Medio |
| **Mantenimiento** | ¿Requiere actualizaciones frecuentes? | Medio |
| **Dependencias** | ¿Introduce nuevas dependencias externas? | Bajo |

### Escala de Decisión

```
IMPLEMENTAR    → Problema real + uso frecuente + sin alternativa simple
SIMPLIFICAR    → Útil pero se puede hacer más simple
POSPONER       → Podría ser útil pero no hay evidencia de necesidad
DESCARTAR      → Sobreingeniería clara o ya existe solución
```

---

## Propuestas a Evaluar

### 1. Skills Específicos de Symfony

**Descripción**: Crear `/symfony-*` skills para comandos, bundles, doctrine, etc.

#### Análisis

| Criterio | Evaluación |
|----------|------------|
| Problema Real | ❓ ¿Hay frustración actual trabajando con Symfony sin skills específicos? |
| Frecuencia | ❓ ¿Cuántos proyectos Symfony hay activos? |
| Alternativa Simple | ⚠️ El skill `/php-refactor` ya cubre patrones generales |
| Complejidad | ~200-400 líneas por skill |
| Mantenimiento | Alto - Symfony cambia entre versiones |

#### Preguntas Antes de Implementar

1. ¿Qué tarea específica de Symfony es repetitiva y tediosa hoy?
2. ¿Claude Code sin skills especiales falla en esas tareas?
3. ¿Un prompt bien escrito en `/prd` resuelve lo mismo?

#### Veredicto Preliminar

```
[ ] IMPLEMENTAR
[ ] SIMPLIFICAR
[?] POSPONER     ← Probable: necesita evidencia de uso real
[ ] DESCARTAR
```

---

### 2. Skills de Testing/Migrations

**Descripción**: Skills para `/test-generate`, `/migration-create`, etc.

#### Análisis

| Criterio | Evaluación |
|----------|------------|
| Problema Real | ❓ ¿Se olvidan tests? ¿Las migrations son problemáticas? |
| Frecuencia | Tests: potencialmente alto. Migrations: bajo |
| Alternativa Simple | ⚠️ PRD puede especificar "incluir tests" |
| Complejidad | ~100-150 líneas por skill |
| Mantenimiento | Bajo si son genéricos |

#### Preguntas Antes de Implementar

1. ¿El agente actualmente NO genera tests cuando debería?
2. ¿Las migrations generadas tienen problemas recurrentes?
3. ¿Bastaría con añadir "siempre incluir tests" en CLAUDE.md?

#### Veredicto Preliminar

```
[ ] IMPLEMENTAR
[?] SIMPLIFICAR  ← Probable: añadir regla en CLAUDE.md primero
[ ] POSPONER
[ ] DESCARTAR
```

---

### 3. Mejoras al Loop de Automatización

**Descripción**: Añadir retry logic, notificaciones, paralelismo, etc.

#### Análisis

| Criterio | Evaluación |
|----------|------------|
| Problema Real | ❓ ¿El loop actual falla frecuentemente? |
| Frecuencia | N/A - es infraestructura |
| Alternativa Simple | ⚠️ El loop actual ya tiene manejo básico de errores |
| Complejidad | Variable - puede escalar rápidamente |
| Mantenimiento | Alto si se añade mucha lógica |

#### Preguntas Antes de Implementar

1. ¿Cuántas veces ha fallado el loop nocturno?
2. ¿Qué tipo de fallos han ocurrido?
3. ¿El problema es el loop o la calidad de las tareas?

#### Veredicto Preliminar

```
[ ] IMPLEMENTAR
[ ] SIMPLIFICAR
[ ] POSPONER
[?] DESCARTAR    ← Probable: optimización prematura sin datos de fallos
```

---

### 4. Configuración de Backlog Inicial

**Descripción**: Crear un `reports/backlog.md` con items priorizados.

#### Análisis

| Criterio | Evaluación |
|----------|------------|
| Problema Real | ✅ Sin backlog, el sistema nocturno no hace nada |
| Frecuencia | Necesario para que TODO funcione |
| Alternativa Simple | ❌ No hay alternativa - es requisito |
| Complejidad | ~20-50 líneas de markdown |
| Mantenimiento | Bajo - el usuario lo actualiza |

#### Preguntas Antes de Implementar

1. ¿Qué proyectos/tareas reales hay pendientes?
2. ¿Cuál es el criterio de priorización?

#### Veredicto Preliminar

```
[✓] IMPLEMENTAR  ← Claro: es requisito para usar el sistema
[ ] SIMPLIFICAR
[ ] POSPONER
[ ] DESCARTAR
```

---

## Resumen de Evaluación

| Propuesta | Veredicto | Razón |
|-----------|-----------|-------|
| Skills Symfony | 🟡 POSPONER | Sin evidencia de necesidad real |
| Skills Testing | 🟡 SIMPLIFICAR | Probar primero con regla en CLAUDE.md |
| Mejoras Loop | 🔴 DESCARTAR | Optimización prematura |
| Backlog Inicial | 🟢 IMPLEMENTAR | Requisito para usar el sistema |

---

## Próximos Pasos Recomendados

### Fase 1: Lo Mínimo Necesario (Ahora)

1. **Crear backlog inicial** con 3-5 tareas reales de un proyecto Symfony
2. **Probar el flujo completo** manualmente una vez
3. **Documentar qué falla** o qué falta

### Fase 2: Basado en Evidencia (Después de usar)

1. Revisar logs de ejecución
2. Identificar patrones de fallos reales
3. Decidir qué skills realmente hacen falta

### Fase 3: Iterar (Solo si hay datos)

1. Implementar SOLO lo que los datos muestren necesario
2. Medir impacto
3. Repetir

---

## Registro de Decisiones

| Fecha | Decisión | Razón | Resultado |
|-------|----------|-------|-----------|
| 2026-01-29 | Crear framework de evaluación | Evitar sobreingeniería | Pendiente |
| | | | |

---

## Notas

- Este documento se actualiza conforme se toman decisiones
- Cada implementación debe referenciar este análisis
- Si no hay entrada aquí, no se implementa

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

## Caso de Estudio: Proyecto SNAAPI

Análisis realizado el 2026-01-29 sobre proyecto Symfony 6.4 real.

### Métricas del Proyecto

| Métrica | Valor |
|---------|-------|
| Archivos PHP (src) | 89 |
| Archivos PHP (tests) | 63 |
| Líneas de código | ~5,659 |
| Stack | Symfony 6.4, PHP 8.1+, PHPStan 9, PHPUnit 10 |

### Problemas Reales Detectados

| Archivo | Problema | Evidencia |
|---------|----------|-----------|
| `EditorialOrchestrator.php` | 536 líneas | CLAUDE.md dice max 200 |
| `execute()` método | ~180 líneas | CLAUDE.md dice max 20 |
| Constructor | 18 dependencias | Violación SRP |
| Líneas 125-207 | Código duplicado | `insertedNews` ≈ `recommendedEditorials` |
| Varios archivos | 5x `@phpstan-ignore` | Code smells |

### Skill Existente Mal Adaptado

El proyecto tiene `.claude/skills/code-simplifier.md` pero menciona:
- "ES modules"
- "arrow functions"
- "React components"

**Conclusión**: Es una plantilla JavaScript que nunca se adaptó a PHP.

---

## Propuestas Evaluadas con Evidencia

### 1. Corregir `/code-simplifier` para PHP

**Descripción**: Adaptar el skill existente para que funcione con PHP/Symfony.

| Criterio | Evaluación |
|----------|------------|
| Problema Real | ✅ El skill actual NO funciona - menciona JS/React |
| Frecuencia | ✅ Cada sesión de desarrollo |
| Alternativa Simple | ❌ No existe - hay que corregirlo |
| Complejidad | ~100 líneas |
| Mantenimiento | Bajo |

**Veredicto**: 🟢 **IMPLEMENTAR**

---

### 2. Skills Específicos de Symfony

**Descripción**: Crear `/symfony-*` skills para comandos, bundles, doctrine.

| Criterio | Evaluación |
|----------|------------|
| Problema Real | ❌ SNAAPI ya tiene CLAUDE.md completo con patrones Symfony |
| Frecuencia | ❓ Sin datos |
| Alternativa Simple | ✅ CLAUDE.md del proyecto ya cubre todo |

**Veredicto**: 🔴 **DESCARTAR** - El CLAUDE.md del proyecto ya define:
- Controladores delgados
- Compiler Passes
- Service tags
- REST best practices
- DDD layers

---

### 3. Skills de Testing/Migrations

| Criterio | Evaluación |
|----------|------------|
| Problema Real | ❌ SNAAPI tiene 63 tests, MSI 79% |
| Alternativa Simple | ✅ Ya existe `make tests`, `make test_unit` |

**Veredicto**: 🔴 **DESCARTAR** - No hay evidencia de problema.

---

### 4. Mejoras al Loop de Automatización

| Criterio | Evaluación |
|----------|------------|
| Problema Real | ❌ No hay datos de fallos |
| Alternativa Simple | ✅ El loop actual ya tiene manejo de errores |

**Veredicto**: 🔴 **DESCARTAR** - Optimización prematura.

---

### 5. Skill de Detección de Violaciones

**Descripción**: Detectar automáticamente clases >200 líneas, métodos >20 líneas.

| Criterio | Evaluación |
|----------|------------|
| Problema Real | ✅ SNAAPI tiene clases de 536 líneas violando sus propias reglas |
| Frecuencia | ✅ Cada refactorización |
| Alternativa Simple | ⚠️ Puede integrarse en `/code-simplifier` |

**Veredicto**: 🟡 **SIMPLIFICAR** - Integrar en `/code-simplifier` en lugar de skill separado.

---

## Resumen de Decisiones (Post-Análisis)

| Propuesta | Veredicto | Razón |
|-----------|-----------|-------|
| Corregir `/code-simplifier` | 🟢 IMPLEMENTAR | No funciona actualmente |
| Skills Symfony | 🔴 DESCARTAR | CLAUDE.md ya es suficiente |
| Skills Testing | 🔴 DESCARTAR | Tests ya funcionan bien |
| Mejoras Loop | 🔴 DESCARTAR | Sin datos de fallos |
| Detección violaciones | 🟡 SIMPLIFICAR | Integrar en code-simplifier |

---

## Plan de Implementación

### Fase 1: Única Mejora Necesaria

1. **Crear `/php-simplifier`** o corregir `/code-simplifier`:
   - Adaptado para PHP 8.1+
   - Detectar clases > 200 líneas
   - Detectar métodos > 20 líneas
   - Detectar constructores con > 5 dependencias
   - Sugerir extracción de clases/métodos
   - Seguir patrones DDD/SOLID del CLAUDE.md del proyecto

### Fase 2: Backlog con Tareas Reales

Crear `reports/backlog.md` con tareas de refactorización detectadas:

```markdown
1. Refactorizar EditorialOrchestrator.php (536 → <200 líneas)
2. Extraer método execute() en métodos pequeños
3. Eliminar código duplicado insertedNews/recommendedEditorials
4. Resolver @phpstan-ignore comments
```

---

## Registro de Decisiones

| Fecha | Decisión | Razón | Resultado |
|-------|----------|-------|-----------|
| 2026-01-29 | Crear framework de evaluación | Evitar sobreingeniería | ✅ Creado |
| 2026-01-29 | Analizar proyecto SNAAPI | Obtener evidencia real | ✅ Completado |
| 2026-01-29 | Descartar skills Symfony | CLAUDE.md ya suficiente | ✅ Descartado |
| 2026-01-29 | Descartar skills testing | Tests ya funcionan | ✅ Descartado |
| 2026-01-29 | Implementar `/php-simplifier` | Skill actual no funciona | 🔄 Pendiente |

---

## Lecciones Aprendidas

1. **Analizar antes de proponer**: Sin ver SNAAPI, habríamos propuesto skills innecesarios
2. **El proyecto ya tiene lo que necesita**: Su CLAUDE.md es completo
3. **El problema real era simple**: Un skill mal adaptado
4. **La refactorización es el trabajo real**: No el plugin

---

## Notas

- Este documento se actualiza conforme se toman decisiones
- Cada implementación debe referenciar este análisis
- Si no hay entrada aquí, no se implementa
- **Principio**: Preferir mejorar documentación existente sobre crear nuevos skills

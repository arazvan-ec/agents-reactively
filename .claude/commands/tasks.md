# Tasks Skill

## Descripción

Esta habilidad convierte PRDs en tareas ejecutables y gestiona el progreso de implementación.

## Instrucciones

### Convertir PRD a Tareas

Cuando el usuario ejecute `/tasks [ruta-prd]`:

1. **Leer el PRD** especificado
2. **Extraer tareas** de los requisitos y criterios de aceptación
3. **Ordenar por dependencias** (tareas sin dependencias primero)
4. **Generar archivo JSON** con las tareas

### Formato de Tareas

Crear archivo `scripts/compound/prd.json`:

```json
{
  "prd": "tasks/prd-nombre.md",
  "created_at": "2024-01-15T10:00:00Z",
  "total_tasks": 12,
  "completed_tasks": 0,
  "tasks": [
    {
      "id": 1,
      "title": "Crear migración para tabla cache_entries",
      "description": "Crear migración con campos: key, value, expiration, tags",
      "type": "migration",
      "status": "pending",
      "dependencies": [],
      "files": [
        "database/migrations/xxxx_create_cache_entries_table.php"
      ],
      "acceptance_criteria": [
        "Migración ejecuta sin errores",
        "Tabla tiene índice en campo 'key'",
        "Campo 'expiration' permite null"
      ],
      "estimated_complexity": "low"
    },
    {
      "id": 2,
      "title": "Crear modelo CacheEntry",
      "description": "Modelo Eloquent con casts y scopes necesarios",
      "type": "model",
      "status": "pending",
      "dependencies": [1],
      "files": [
        "app/Models/CacheEntry.php"
      ],
      "acceptance_criteria": [
        "Modelo tiene cast correcto para 'value' (json)",
        "Scope 'notExpired' filtra entradas válidas"
      ],
      "estimated_complexity": "low"
    }
  ]
}
```

### Tipos de Tareas

- `migration`: Migraciones de base de datos
- `model`: Modelos y relaciones
- `repository`: Repositorios y acceso a datos
- `service`: Servicios y lógica de negocio
- `controller`: Controladores y rutas
- `test`: Tests unitarios e integración
- `refactor`: Refactorización de código existente
- `config`: Configuración y environment

### Complejidad

- `low`: < 30 minutos, cambios simples
- `medium`: 30-60 minutos, lógica moderada
- `high`: > 60 minutos, múltiples archivos o lógica compleja

## Gestión de Tareas

### Ver Estado

```
Usuario: /tasks status

Agente:
📋 Estado del PRD: Cache System

Progreso: ████████░░ 8/12 (67%)

✅ Completadas: 8
🔄 En progreso: 1
⏳ Pendientes: 3

Próxima tarea: #9 - Implementar invalidación por tags
```

### Marcar Completada

```
Usuario: /tasks complete 5

Agente: ✅ Tarea #5 marcada como completada
       Progreso: 9/12 (75%)
```

### Ver Detalles

```
Usuario: /tasks show 9

Agente:
📌 Tarea #9: Implementar invalidación por tags

Descripción: Crear método que invalide todas las entradas
             con un tag específico

Tipo: service
Complejidad: medium
Dependencias: #6, #7

Archivos:
- app/Services/CacheService.php

Criterios de aceptación:
- [ ] Método invalidateByTag(string $tag)
- [ ] Batch delete para eficiencia
- [ ] Logging de entradas eliminadas
```

## Integración con Loop

El archivo `prd.json` es leído por `scripts/compound/loop.sh` para ejecutar tareas automáticamente:

1. Loop lee `prd.json`
2. Encuentra primera tarea pendiente sin dependencias incompletas
3. Ejecuta la tarea con Claude
4. Actualiza status en `prd.json`
5. Repite hasta completar o alcanzar límite

## Ejemplo Completo

```
Usuario: /tasks tasks/prd-cache-system.md

Agente: Analizando PRD...

📋 Tareas generadas para: Cache System

Total: 12 tareas
- 3 migraciones
- 2 modelos
- 2 servicios
- 2 controladores
- 3 tests

Orden de ejecución:
1. [migration] Crear tabla cache_entries
2. [model] Crear modelo CacheEntry
3. [migration] Crear tabla cache_tags
...

Archivo guardado: scripts/compound/prd.json

¿Iniciar implementación automática con el loop?
```

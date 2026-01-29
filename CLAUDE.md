# PHP Development Agent - Compound Engineering

Este agente está configurado para desarrollo y refactorización de código PHP con aprendizaje continuo.

## Identidad del Agente

Soy un agente especializado en desarrollo PHP que:
- Aprende de cada sesión de trabajo y persiste ese conocimiento
- Sigue las mejores prácticas de PHP moderno (PSR-12, PSR-4)
- Refactoriza código legacy hacia patrones modernos
- Mantiene un registro de aprendizajes en este archivo

## Habilidades Disponibles

Carga estas habilidades usando `/compound`, `/prd`, `/tasks`, o `/php-refactor`:

- **compound**: Extraer y persistir aprendizajes de la sesión actual
- **prd**: Crear Product Requirement Documents estructurados
- **tasks**: Convertir PRDs en tareas ejecutables
- **php-refactor**: Patrones específicos de refactorización PHP

## Stack Técnico

- **PHP**: 8.1+ con tipado estricto
- **Framework**: Laravel/Symfony (adaptar según proyecto)
- **Testing**: PHPUnit, Pest
- **Análisis**: PHPStan nivel 8, PHP CS Fixer
- **Dependencias**: Composer

## Convenciones de Código PHP

### Estructura de Clases
```php
<?php

declare(strict_types=1);

namespace App\Domain\Entity;

use App\Domain\ValueObject\EntityId;

final class Example
{
    public function __construct(
        private readonly EntityId $id,
        private readonly string $name,
    ) {}

    public function name(): string
    {
        return $this->name;
    }
}
```

### Patrones Preferidos

1. **Inmutabilidad**: Usar `readonly` y clases `final`
2. **Value Objects**: Para IDs, emails, dinero, etc.
3. **DTOs**: Para transferencia de datos entre capas
4. **Repository Pattern**: Para acceso a datos
5. **Service Classes**: Lógica de negocio aislada
6. **Action Classes**: Una acción = una clase

### Evitar

- Arrays asociativos para datos estructurados (usar DTOs)
- Herencia profunda (preferir composición)
- Métodos con más de 20 líneas
- Clases con más de 200 líneas
- Dependencias circulares

## Patrones de Refactorización

### Legacy a Moderno

```php
// ANTES: Array asociativo
$user = ['name' => 'John', 'email' => 'john@example.com'];

// DESPUÉS: DTO
final readonly class UserData
{
    public function __construct(
        public string $name,
        public Email $email,
    ) {}
}
```

### Controladores Delgados

```php
// ANTES: Lógica en controlador
public function store(Request $request)
{
    // 50 líneas de lógica...
}

// DESPUÉS: Delegado a Action
public function store(Request $request, CreateUserAction $action)
{
    return $action->execute(CreateUserData::fromRequest($request));
}
```

---

## Aprendizajes Acumulados

<!-- Los aprendizajes se agregan automáticamente aquí -->

### Patrones Descubiertos

_Aún no hay patrones registrados. Usa el comando `/compound` al final de cada sesión._

### Errores Comunes Evitados

_Aún no hay errores registrados._

### Optimizaciones Aplicadas

_Aún no hay optimizaciones registradas._

---

## Contexto del Proyecto

<!-- Actualizar según el proyecto específico -->

### Estructura de Directorios

```
src/
├── Domain/           # Entidades, Value Objects, Interfaces
├── Application/      # Use Cases, DTOs, Services
├── Infrastructure/   # Repositorios, APIs externas
└── Presentation/     # Controllers, Views, API Resources
```

### Comandos Útiles

```bash
# Tests
composer test
./vendor/bin/phpunit

# Análisis estático
composer analyse
./vendor/bin/phpstan analyse

# Formateo
composer format
./vendor/bin/php-cs-fixer fix

# Todos los checks
composer check
```

---

## Flujo de Trabajo

1. **Al iniciar**: Revisar este archivo para contexto
2. **Durante desarrollo**: Seguir convenciones establecidas
3. **Al terminar**: Ejecutar `/compound` para persistir aprendizajes
4. **Noche**: El sistema automático revisa y actualiza

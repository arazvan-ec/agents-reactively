# PHP Refactor Skill

## Descripción

Habilidad especializada en refactorización de código PHP legacy hacia patrones modernos.

## Instrucciones

Cuando el usuario ejecute `/php-refactor [archivo o directorio]`:

1. **Analizar** el código existente
2. **Identificar** code smells y oportunidades de mejora
3. **Proponer** refactorizaciones específicas
4. **Ejecutar** las mejoras aprobadas
5. **Verificar** que los tests sigan pasando

## Catálogo de Refactorizaciones

### 1. Array a DTO

**Detectar:**
```php
// Code smell: Array asociativo para datos estructurados
$user = [
    'name' => $name,
    'email' => $email,
    'created_at' => now(),
];
```

**Refactorizar a:**
```php
final readonly class UserData
{
    public function __construct(
        public string $name,
        public Email $email,
        public DateTimeImmutable $createdAt,
    ) {}

    public static function create(string $name, string $email): self
    {
        return new self(
            name: $name,
            email: Email::fromString($email),
            createdAt: new DateTimeImmutable(),
        );
    }
}

$user = UserData::create($name, $email);
```

### 2. God Class a Servicios

**Detectar:**
- Clase con más de 500 líneas
- Múltiples responsabilidades
- Muchas dependencias

**Refactorizar:**
1. Identificar responsabilidades distintas
2. Extraer cada responsabilidad a su propia clase
3. Usar inyección de dependencias
4. La clase original delega a servicios

### 3. Controlador Gordo a Action

**Detectar:**
```php
public function store(Request $request)
{
    // Validación...
    // Lógica de negocio...
    // Envío de emails...
    // Logging...
    // Response...
    // 100+ líneas
}
```

**Refactorizar a:**
```php
public function store(
    StoreUserRequest $request,
    CreateUserAction $action
): JsonResponse {
    $user = $action->execute($request->toDto());

    return UserResource::make($user)
        ->response()
        ->setStatusCode(201);
}
```

### 4. Herencia a Composición

**Detectar:**
```php
class AdminUser extends User extends BaseModel
{
    // Herencia profunda
}
```

**Refactorizar a:**
```php
final class User
{
    public function __construct(
        private readonly UserId $id,
        private readonly Role $role,
        private readonly Permissions $permissions,
    ) {}
}
```

### 5. Static a Dependency Injection

**Detectar:**
```php
class OrderService
{
    public function calculate(): Money
    {
        $tax = TaxCalculator::calculate($this->total);
        $discount = DiscountService::apply($this->items);
    }
}
```

**Refactorizar a:**
```php
final class OrderService
{
    public function __construct(
        private readonly TaxCalculator $taxCalculator,
        private readonly DiscountService $discountService,
    ) {}

    public function calculate(): Money
    {
        $tax = $this->taxCalculator->calculate($this->total);
        $discount = $this->discountService->apply($this->items);
    }
}
```

### 6. Query en Loop a Eager Loading

**Detectar:**
```php
$users = User::all();
foreach ($users as $user) {
    echo $user->posts->count(); // N+1 query!
}
```

**Refactorizar a:**
```php
$users = User::with('posts')->get();
foreach ($users as $user) {
    echo $user->posts->count();
}
```

### 7. String a Value Object

**Detectar:**
```php
public function setEmail(string $email): void
{
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        throw new InvalidArgumentException();
    }
    $this->email = $email;
}
```

**Refactorizar a:**
```php
final readonly class Email
{
    private function __construct(
        private string $value
    ) {}

    public static function fromString(string $email): self
    {
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new InvalidEmailException($email);
        }
        return new self($email);
    }

    public function toString(): string
    {
        return $this->value;
    }
}
```

### 8. Magic Methods a Typed Properties

**Detectar:**
```php
class User
{
    protected $fillable = ['name', 'email'];

    public function __get($key) { ... }
    public function __set($key, $value) { ... }
}
```

**Refactorizar a:**
```php
final class User
{
    public function __construct(
        private string $name,
        private Email $email,
    ) {}

    public function name(): string
    {
        return $this->name;
    }
}
```

## Proceso de Refactorización

```
Usuario: /php-refactor app/Services/OrderService.php

Agente: Analizando OrderService.php...

🔍 Code Smells Detectados:

1. [HIGH] God Class: 450 líneas, 8 responsabilidades
2. [MEDIUM] Static calls: 12 llamadas estáticas
3. [MEDIUM] Array returns: 5 métodos retornan arrays
4. [LOW] Missing types: 3 parámetros sin tipo

📋 Plan de Refactorización:

1. Extraer OrderCalculator (cálculos de precios)
2. Extraer OrderValidator (validaciones)
3. Extraer OrderNotifier (emails/notificaciones)
4. Convertir arrays a DTOs
5. Inyectar dependencias

Archivos a crear:
- app/Services/Order/OrderCalculator.php
- app/Services/Order/OrderValidator.php
- app/Services/Order/OrderNotifier.php
- app/DTOs/OrderData.php
- app/DTOs/OrderItemData.php

¿Proceder con la refactorización? (s/n)
```

## Verificación Post-Refactor

Después de cada refactorización:

1. **Ejecutar tests**: `./vendor/bin/phpunit`
2. **Análisis estático**: `./vendor/bin/phpstan analyse`
3. **Formateo**: `./vendor/bin/php-cs-fixer fix`
4. **Verificar tipos**: Sin errores de PHPStan

## Notas

- Siempre crear tests antes de refactorizar código sin cobertura
- Hacer commits pequeños y frecuentes
- Un refactor = un commit
- Si los tests fallan, revertir y analizar

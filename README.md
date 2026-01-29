# PHP Development Plugin for Claude Code

Plugin de desarrollo PHP con aprendizaje continuo y automatización nocturna para Claude Code.

## Características

- **Compound Engineering**: Extrae y persiste aprendizajes de cada sesión de trabajo
- **PRD Generation**: Crea documentos de requisitos estructurados
- **Task Management**: Convierte PRDs en tareas ejecutables con dependencias
- **PHP Refactoring**: Catálogo de patrones de refactorización PHP modernos
- **Nightly Automation**: Scripts para que tu agente trabaje mientras duermes

## Requisitos

- [Claude Code](https://github.com/anthropics/claude-code) instalado y configurado
- Git
- Python 3 (para scripts de automatización)
- `gh` CLI (opcional, para crear PRs automáticamente)
- macOS (para launchd) o cron (para Linux)

## Instalación

### 1. Clonar/Copiar el plugin

```bash
# Opción A: Clonar directamente
git clone <repo-url> mi-proyecto-php
cd mi-proyecto-php

# Opción B: Copiar archivos a proyecto existente
cp -r .claude/ /tu-proyecto/
cp CLAUDE.md /tu-proyecto/
cp -r scripts/ /tu-proyecto/
mkdir -p /tu-proyecto/{tasks,reports,logs}
```

### 2. Hacer scripts ejecutables

```bash
chmod +x scripts/*.sh
chmod +x scripts/compound/*.sh
```

### 3. Verificar instalación

```bash
# Verificar que Claude Code está instalado
claude --version

# Probar comando compound
claude -p "Carga /compound y muestra instrucciones"
```

## Uso Manual

### Comandos Disponibles

Los comandos se cargan escribiendo `/nombre-comando` en Claude Code:

| Comando | Descripción |
|---------|-------------|
| `/compound` | Extrae aprendizajes de la sesión y actualiza CLAUDE.md |
| `/prd [descripción]` | Crea un PRD para una nueva funcionalidad |
| `/tasks [ruta-prd]` | Convierte un PRD en tareas ejecutables |
| `/php-refactor [archivo]` | Analiza código PHP y propone refactorizaciones |

### Ejemplo de Flujo de Trabajo

```bash
# 1. Iniciar sesión de desarrollo
claude

# 2. Crear PRD para nueva feature
> /prd Implementar sistema de caché con Redis

# 3. Convertir PRD a tareas
> /tasks tasks/prd-cache-redis.md

# 4. Al terminar, extraer aprendizajes
> /compound
```

## Automatización Nocturna

### El Loop de Dos Partes

El sistema ejecuta dos jobs en secuencia cada noche:

1. **22:30 - Compound Review**: Revisa threads del día, extrae aprendizajes, actualiza CLAUDE.md
2. **23:00 - Auto Compound**: Implementa item #1 del backlog y crea PR

### Configuración en macOS (launchd)

```bash
# 1. Copiar templates de plist
cp launchd/*.plist ~/Library/LaunchAgents/

# 2. Editar cada plist para actualizar rutas
# Reemplazar YOUR_USERNAME y rutas del proyecto
nano ~/Library/LaunchAgents/com.phpdev.daily-compound-review.plist
nano ~/Library/LaunchAgents/com.phpdev.auto-compound.plist
nano ~/Library/LaunchAgents/com.phpdev.caffeinate.plist

# 3. Cargar los jobs
launchctl load ~/Library/LaunchAgents/com.phpdev.daily-compound-review.plist
launchctl load ~/Library/LaunchAgents/com.phpdev.auto-compound.plist
launchctl load ~/Library/LaunchAgents/com.phpdev.caffeinate.plist

# 4. Verificar
launchctl list | grep phpdev
```

### Configuración en Linux (cron)

```bash
# Editar crontab
crontab -e

# Agregar estas líneas:
30 22 * * * cd /ruta/proyecto && ./scripts/daily-compound-review.sh >> logs/compound-review.log 2>&1
0 23 * * * cd /ruta/proyecto && ./scripts/compound/auto-compound.sh >> logs/auto-compound.log 2>&1
```

### Ejecutar Manualmente

```bash
# Revisión de compound (extrae aprendizajes)
./scripts/daily-compound-review.sh

# Auto compound completo (PRD → Tasks → Implementación → PR)
./scripts/compound/auto-compound.sh

# Solo el loop de ejecución
./scripts/compound/loop.sh 25  # 25 iteraciones máximo

# Dry run (sin cambios reales)
./scripts/compound/auto-compound.sh --dry-run
```

## Estructura del Proyecto

```
.
├── .claude/
│   └── commands/
│       ├── compound.md       # Skill de compound engineering
│       ├── prd.md            # Skill de creación de PRDs
│       ├── tasks.md          # Skill de gestión de tareas
│       └── php-refactor.md   # Skill de refactorización PHP
├── scripts/
│   ├── daily-compound-review.sh  # Revisión diaria de aprendizajes
│   └── compound/
│       ├── auto-compound.sh      # Pipeline completo automatizado
│       ├── analyze-report.sh     # Analiza backlog y extrae prioridad
│       └── loop.sh               # Loop de ejecución de tareas
├── launchd/                      # Templates de configuración macOS
│   ├── com.phpdev.daily-compound-review.plist
│   ├── com.phpdev.auto-compound.plist
│   └── com.phpdev.caffeinate.plist
├── tasks/                        # PRDs generados
├── reports/                      # Backlog priorizado
├── logs/                         # Logs de ejecución
├── CLAUDE.md                     # Instrucciones del agente
└── README.md                     # Este archivo
```

## Crear Backlog Priorizado

Para que auto-compound funcione, necesitas un archivo de backlog en `reports/`:

```markdown
# Backlog Priorizado

## Prioridad Alta

1. **Refactorizar UserService** - Extraer lógica de autenticación
2. **Implementar Value Objects** - Email, UserId, Money
3. **Agregar tests unitarios** - 80% cobertura Domain layer

## Prioridad Media

4. **Optimizar queries N+1** - OrderRepository
5. **Documentar API** - OpenAPI spec

## Prioridad Baja

6. **Actualizar dependencias**
7. **Limpiar código deprecado**
```

El script `analyze-report.sh` extraerá automáticamente el item #1.

## Debugging

### Ver logs

```bash
# Logs de compound review
tail -f logs/compound-review.log

# Logs de auto-compound
tail -f logs/auto-compound.log
```

### Verificar jobs en launchd

```bash
# Listar jobs
launchctl list | grep phpdev

# Ver detalles de un job
launchctl print gui/$(id -u)/com.phpdev.auto-compound

# Ejecutar manualmente un job
launchctl start com.phpdev.daily-compound-review
```

### Errores Comunes

| Error | Solución |
|-------|----------|
| `claude: command not found` | Asegurar que Claude Code está en PATH |
| `Permission denied` | Ejecutar `chmod +x scripts/**/*.sh` |
| `No se pudo hacer pull` | Verificar permisos de git y conexión |
| `gh: command not found` | Instalar GitHub CLI o crear PR manual |

## Convenciones PHP

El agente sigue estas convenciones (definidas en CLAUDE.md):

- **PHP 8.1+** con `declare(strict_types=1)`
- **PSR-12** para estilo de código
- **PSR-4** para autoloading
- Clases `final` y propiedades `readonly` por defecto
- Value Objects para datos con significado (Email, Money, etc.)
- DTOs para transferencia de datos
- Action classes para operaciones específicas
- Repository pattern para acceso a datos

## Extender el Plugin

### Agregar Nueva Skill

1. Crear archivo en `.claude/commands/mi-skill.md`
2. Seguir formato de skills existentes
3. Documentar en CLAUDE.md

### Personalizar Comportamiento

Editar `CLAUDE.md` para:
- Cambiar convenciones de código
- Agregar patrones específicos del proyecto
- Documentar decisiones arquitectónicas
- Registrar aprendizajes manualmente

## Contribuir

1. Fork el repositorio
2. Crear rama feature (`git checkout -b feature/mi-mejora`)
3. Commit cambios (`git commit -am 'feat: agregar mejora'`)
4. Push a la rama (`git push origin feature/mi-mejora`)
5. Crear Pull Request

## Licencia

MIT

## Créditos

Inspirado en:
- [Compound Engineering](https://x.com/ryancarson) por Ryan Carson
- [Claude Code](https://github.com/anthropics/claude-code) por Anthropic

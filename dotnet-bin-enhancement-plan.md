# 📋 План добавления функциональности глобальных инструментов в dotnet-bin

## 🎯 Цель
Добавить в фичу `dotnet-bin` те же опции для установки глобальных инструментов, что есть в основной фиче `dotnet`:
- `installEntityFramework` 
- `installAspNetCodeGenerator`
- `installDevCerts`
- `installGlobalTools`

## 📝 Анализ текущего состояния

### Текущие ограничения dotnet-bin:
- В строке 139 NOTES.md указано: "**No Global Tools**: This feature focuses on basic .NET installation only"
- Отсутствуют опции для глобальных инструментов в `src/dotnet-bin/devcontainer-feature.json`
- В `src/dotnet-bin/install.sh` нет логики установки глобальных инструментов

### Что уже есть:
- Настройка PATH для dotnet tools (строки 208-227 в install.sh)
- Функция `run_yay()` для установки AUR пакетов
- Базовая структура для расширения функциональности

## 🔧 Изменения в devcontainer-feature.json

### Добавить новые опции:
```json
{
    "installEntityFramework": {
        "type": "boolean",
        "default": false,
        "description": "Install Entity Framework Core CLI (dotnet-ef)"
    },
    "installAspNetCodeGenerator": {
        "type": "boolean", 
        "default": false,
        "description": "Install ASP.NET Core Code Generator"
    },
    "installDevCerts": {
        "type": "boolean",
        "default": false,
        "description": "Install development certificates tool"
    },
    "installGlobalTools": {
        "type": "string",
        "default": "",
        "description": "Comma-separated list of additional global tools to install"
    }
}
```

## 🛠️ Изменения в install.sh

### 1. Добавить переменные окружения (после строки 13):
```bash
INSTALL_ENTITY_FRAMEWORK="${INSTALLENTITYFRAMEWORK:-"false"}"
INSTALL_ASPNET_CODEGENERATOR="${INSTALLASPNETCODEGENERATOR:-"false"}"
INSTALL_DEV_CERTS="${INSTALLDEVCERTS:-"false"}"
INSTALL_GLOBAL_TOOLS="${INSTALLGLOBALTOOLS:-""}"
```

### 2. Добавить функции (после строки 143):
- `check_tool_availability()` - проверка доступности инструментов в NuGet
- `run_as_user()` - выполнение команд от имени пользователя

### 3. Добавить логику установки глобальных инструментов (после строки 227):
- Сбор списка инструментов для установки
- Проверка доступности через NuGet API
- Установка через `dotnet tool install --global`
- Обработка ошибок и отчетность

### 4. Обновить installation summary (строки 232-250):
- Добавить информацию об установленных глобальных инструментах
- Показать список установленных tools через `dotnet tool list --global`

## 📄 Изменения в NOTES.md

### Основные изменения:
1. **Строка 9**: Изменить "🔧 Simplified installation without complex options" на "🌍 Optionally installs Entity Framework CLI, Code Generator, and custom tools"
2. **Строка 139**: Удалить "**No Global Tools**: This feature focuses on basic .NET installation only"
3. **Добавить новые примеры конфигураций** с глобальными инструментами
4. **Обновить таблицу опций** - добавить 4 новые опции
5. **Добавить секцию "🛠️ Global Tools"** с примерами использования

### Новые примеры конфигураций:
```json
// Advanced Configuration with Global Tools
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/yay:1": {},
        "ghcr.io/zyrakq/arch-devcontainer-features/dotnet-bin:1": {
            "installEntityFramework": true,
            "installAspNetCodeGenerator": true,
            "installDevCerts": true,
            "installGlobalTools": "dotnet-format"
        }
    }
}

// Web Development Setup
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/yay:1": {},
        "ghcr.io/zyrakq/arch-devcontainer-features/dotnet-bin:1": {
            "installEntityFramework": true,
            "installAspNetCodeGenerator": true,
            "installDevCerts": true
        }
    }
}
```

### Обновленная таблица опций:
| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `dotnetVersion` | string | `"latest"` | .NET version to install (AUR packages provide latest versions) |
| `installEntityFramework` | boolean | `false` | Install Entity Framework Core CLI (dotnet-ef) |
| `installAspNetCodeGenerator` | boolean | `false` | Install ASP.NET Core Code Generator |
| `installDevCerts` | boolean | `false` | Install development certificates tool |
| `installGlobalTools` | string | `""` | Comma-separated list of additional global tools to install |

## 🧪 Тестирование

### Создать новые тестовые сценарии:
1. `test/dotnet-bin/with_entity_framework.sh` - тест установки EF Core CLI
2. `test/dotnet-bin/with_code_generator.sh` - тест установки ASP.NET Code Generator  
3. `test/dotnet-bin/with_dev_certs.sh` - тест установки dev certificates
4. `test/dotnet-bin/with_custom_tools.sh` - тест установки пользовательских инструментов
5. `test/dotnet-bin/all_tools.sh` - тест установки всех инструментов

### Обновить scenarios.json:
```json
{
    "basic": {
        "dotnetVersion": "latest"
    },
    "with_global_tools": {
        "installEntityFramework": true,
        "installAspNetCodeGenerator": true, 
        "installDevCerts": true,
        "installGlobalTools": "dotnet-format"
    },
    "web_development": {
        "installEntityFramework": true,
        "installAspNetCodeGenerator": true,
        "installDevCerts": true
    },
    "minimal_tools": {
        "installEntityFramework": true
    }
}
```

## 🔄 Последовательность реализации

1. **Обновить devcontainer-feature.json** - добавить новые опции
2. **Добавить переменные в install.sh** - считать новые параметры
3. **Добавить вспомогательные функции** - скопировать из основной фичи dotnet
4. **Добавить логику установки инструментов** - основная функциональность
5. **Обновить NOTES.md** - документация и примеры
6. **Создать тесты** - проверить работоспособность
7. **Проверить совместимость** - убедиться, что старые конфигурации работают

## ⚠️ Важные моменты

1. **Совместимость с AUR**: Глобальные инструменты устанавливаются через `dotnet tool install`, а не через AUR
2. **Зависимости**: Требуется рабочая установка .NET SDK из AUR пакетов
3. **Права доступа**: Инструменты устанавливаются в пользовательскую директорию `~/.dotnet/tools`
4. **Обратная совместимость**: Существующие конфигурации должны продолжать работать
5. **Документация**: Обновить примечание о том, что фича больше не ограничивается базовой установкой

## 🎯 Ожидаемый результат

После реализации `dotnet-bin` будет поддерживать:
- ✅ Все те же опции глобальных инструментов, что и основная фича `dotnet`
- ✅ Установку Entity Framework CLI, ASP.NET Code Generator, Dev Certificates
- ✅ Установку пользовательских глобальных инструментов
- ✅ Проверку доступности инструментов через NuGet API
- ✅ Правильную обработку прав доступа и PATH
- ✅ Обратную совместимость с существующими конфигурациями

## 📋 Детальные изменения кода

### Функции для копирования из src/dotnet/install.sh:

#### check_tool_availability() (строки 324-337):
```bash
check_tool_availability() {
    local tool_name="$1"
    echo "Checking availability of tool: $tool_name"
    
    # Try to get package info from NuGet API
    local nuget_url="https://api.nuget.org/v3-flatcontainer/${tool_name}/index.json"
    if curl -s --fail "$nuget_url" >/dev/null 2>&1; then
        echo "✓ Tool $tool_name is available in NuGet"
        return 0
    else
        echo "✗ Tool $tool_name is not available in NuGet"
        return 1
    fi
}
```

#### run_as_user() (строки 109-116):
```bash
run_as_user() {
    COMMAND="$*"
    if [ "$(id -u)" = "0" ] && [ "${USERNAME}" != "root" ]; then
        sudo -u "${USERNAME}" bash -c "$COMMAND"
    else
        bash -c "$COMMAND"
    fi
}
```

#### Логика установки глобальных инструментов (строки 339-412):
- Сбор списка инструментов на основе опций
- Проверка доступности каждого инструмента
- Установка доступных инструментов
- Обработка ошибок и отчетность

Этот план обеспечивает полную функциональную совместимость между `dotnet` и `dotnet-bin` фичами при сохранении специфики AUR-установки для базовых компонентов .NET.
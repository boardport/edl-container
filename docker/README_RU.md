# 🐳 Контекст и руководство по каталогу `docker/`

Каталог содержит конфигурационные файлы для сборки, настройки и низкоуровневого запуска изолированного Docker-контейнера
для утилиты [bkerler/edl](https://github.com/bkerler/edl).

Данный документ предназначен для разработчиков, которым необходимо понимать архитектуру образа, настраивать параметры окружения
или использовать контейнер напрямую через Docker CLI (например, в CI/CD-пайплайнах или скриптах автоматизации без GNU Make).

---

## 1. Содержимое каталога

| Файл | Описание |
| :--- | :--- |
| `Dockerfile.debian` | Рецепт сборки production-образа на базе Debian 12 (Bookworm) Slim и Python 3.11 |
| `docker-entrypoint.sh` | Скрипт инициализации, выполнения хуков и нормализации прав на созданные файлы |
| `.gitignore` | Исключения локальных артефактов и томов (каталоги дампов, кэши) |

---

## 2. Архитектура образа и параметры сборки

- **Базовый дистрибутив:** `python:3.11-slim` (Debian 12 Bookworm).
- **Поддержка платформ (Multi-Arch):** `linux/amd64` (x86_64 рабочие станции и серверы) и `linux/arm64` (Apple Silicon, ARM64-одноплатники).
- **Системные зависимости:** `libusb-1.0-0`, `liblzma-dev`, `adb`, `fastboot`, `git`, `build-essential`.
- **Апстрим:** Утилита `bkerler/edl` клонируется с фиксацией на релизном теге (сабмодули `Loaders` инициализируются рекурсивно).
- **Локальная сборка образа:**

  ```bash
  make docker-build
  # либо напрямую через docker buildx
  docker build -f docker/Dockerfile.debian -t ghcr.io/boardport/edl .
  ```

---

## 3. Переменные окружения

| Переменная | По умолчанию | Описание |
| :--- | :--- | :--- |
| `EDL_DUMP_UID` | `1000` | UID пользователя хоста для автоматического назначения прав на выгруженные файлы |
| `EDL_DUMP_GID` | `1000` | GID группы пользователя хоста |
| `EDL_DIR` | `/opt/edl` | Рабочий каталог с исходным кодом и скриптами `edl` в контейнере |
| `EDL_DUMP_DIR` | `/opt/edl/dumps` | Целевой каталог для сохранения создаваемых дампов |

---

## 4. Тома и директории монтирования

| Путь на хосте | Точка монтирования в контейнере | Назначение |
| :--- | :--- | :--- |
| `/dev/bus/usb` | `/dev/bus/usb` | Прямой доступ к физической шине USB хоста (требуется `--privileged`) |
| `./dumps` | `/opt/edl/dumps` | Каталог для сохранения дампов разделов, прошивок и логов |
| `./loaders` | `/opt/edl/custom_loaders` | Опциональный каталог со сторонними/кастомными Firehose-загрузчиками |
| `./custom_scripts` | `/docker-entrypoint.d` | Опциональные скрипты инициализации (`*.sh`), выполняемые перед запуском |

---

## 5. Точка входа и модель прав (`docker-entrypoint.sh`)

При запуске контейнера точка входа выполняет следующие шаги:

1. **Хуки инициализации:** Исполняет любые скрипты с расширением `.sh` из каталога `/docker-entrypoint.d/` (если каталог смонтирован).
2. **Маршрутизация команд:**
   - Если переданная команда — системная утилита (`bash`, `sh`, `adb`, `fastboot`), она исполняется напрямую.
   - Во всех остальных случаях параметры передаются главному CLI-модулю: `python3 /opt/edl/edl.py "$@"`.
3. **Нормализация прав:** После завершения операции скрипт выполняет `chown -R "${EDL_DUMP_UID}:${EDL_DUMP_GID}" "$EDL_DUMP_DIR"`.
   Благодаря этому все созданные файлы дампов принадлежат текущему пользователю хоста, а не `root`.

---

## 6. Примеры прямого запуска через Docker CLI

Если в вашей среде не используется GNU Make, все операции можно выполнять через стандартную команду `docker run`:

### Чтение таблицы разделов (GPT)

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  ghcr.io/boardport/edl printgpt
```

### Снятие дампа одного раздела (например, boot)

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$(pwd)/dumps:/opt/edl/dumps" \
  -e EDL_DUMP_UID=$(id -u) \
  ghcr.io/boardport/edl r boot dumps/boot.img
```

### Полный дамп всех разделов (Raw Backup)

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$(pwd)/dumps:/opt/edl/dumps" \
  -e EDL_DUMP_UID=$(id -u) \
  ghcr.io/boardport/edl rl dumps
```

### Запись образа в раздел

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$(pwd)/dumps:/opt/edl/dumps" \
  ghcr.io/boardport/edl w boot dumps/boot_new.img
```

### Стирание раздела

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  ghcr.io/boardport/edl e userdata
```

### Использование внешнего Firehose-загрузчика

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$(pwd)/loaders:/opt/edl/custom_loaders" \
  ghcr.io/boardport/edl --loader=/opt/edl/custom_loaders/prog_emmc_firehose_8916.mbn printgpt
```

### Интерактивная командная оболочка

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$(pwd)/dumps:/opt/edl/dumps" \
  ghcr.io/boardport/edl bash
```

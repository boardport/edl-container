# Руководство разработчика

Руководство по сборке Docker-образа, низкоуровневому вызову через Docker CLI,
настройке точек монтирования, работе с модульной системой GNU Make и стандартам качества кода.

---

## 1. Сборка Docker-образа

Проект использует образ на базе **Debian 12 Slim** и **Python 3.11**.

### Локальная сборка

Сборка локального образа выполняется командой:

```bash
make docker-build
```

Либо напрямую через Docker CLI:

```bash
docker build -f docker/Dockerfile.debian -t ghcr.io/boardport/edl .
```

Рецепт сборки описан в файле
[docker/Dockerfile.debian](https://github.com/boardport/edl-container/blob/main/docker/Dockerfile.debian).
Образ включает:

- Системные пакеты: `libusb-1.0-0`, `liblzma-dev`, `adb`, `fastboot`, `build-essential`, `git`.
- Репозиторий `bkerler/edl` с базой загрузчиков в каталоге `/opt/edl`.
- Скрипт точки входа [docker/docker-entrypoint.sh](https://github.com/boardport/edl-container/blob/main/docker/docker-entrypoint.sh).

---

## 2. Переменные окружения и тома монтирования

### Переменные окружения

| Переменная | По умолчанию | Описание |
| :--- | :--- | :--- |
| `EDL_DUMP_UID` | `1000` | UID пользователя хоста для автоматического назначения прав на выгруженные файлы |
| `EDL_DUMP_GID` | `1000` | GID группы пользователя хоста |
| `EDL_DIR` | `/opt/edl` | Рабочий каталог с исходным кодом утилиты `edl` в контейнере |
| `EDL_DUMP_DIR` | `/opt/edl/dumps` | Каталог внутри контейнера для сохранения создаваемых дампов |

### Тома монтирования

| Путь на хосте | Точка в контейнере | Назначение |
| :--- | :--- | :--- |
| `/dev/bus/usb` | `/dev/bus/usb` | Физическая шина USB хоста (требуется флаг `--privileged`) |
| `./dumps` | `/opt/edl/dumps` | Каталог для сохранения дампов разделов и логов |
| `./loaders` | `/opt/edl/custom_loaders` | Опциональный каталог со сторонними Firehose-загрузчиками |
| `./custom_scripts` | `/docker-entrypoint.d` | Опциональные скрипты инициализации (`*.sh`), выполняемые перед стартом |

---

## 3. Точка входа и хуки инициализации

Скрипт `docker-entrypoint.sh` управляет средой выполнения:

1. **Хуки `/docker-entrypoint.d`:** если смонтирован каталог с исполняемыми скриптами `.sh`, они выполняются по алфавитному порядку.
2. **Маршрутизация команд:**
   - Системные бинарники (`bash`, `sh`, `adb`, `fastboot`, `python`) исполняются напрямую.
   - Команды `edl` передаются скрипту `python /opt/edl/edl.py "$@"`.
3. **Нормализация прав:** при выходе вызывается `chown -R "${EDL_DUMP_UID}:${EDL_DUMP_UID}" "$EDL_DUMP_DIR"`,
   гарантируя доступность файлов хостовому пользователю без `sudo`.

---

## 4. Прямой запуск через Docker CLI (без GNU Make)

В окружениях без GNU Make (например, в CI-раннерах) контейнер можно вызывать напрямую:

### Чтение таблицы разделов (GPT)

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  ghcr.io/boardport/edl printgpt
```

### Снятие дампа одного раздела (boot)

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$(pwd)/dumps:/opt/edl/dumps" \
  -e EDL_DUMP_UID=$(id -u) \
  ghcr.io/boardport/edl r boot dumps/boot.img
```

### Полный дамп всех разделов устройства

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
  -e EDL_DUMP_UID=$(id -u) \
  ghcr.io/boardport/edl w boot dumps/boot_new.img
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

---

## 5. Make-инструментарий (.make/)

Автоматизация построена на модульном GNU Make фреймворке:

- Корневой файл [Makefile](https://github.com/boardport/edl-container/blob/main/Makefile) является диспетчером
  и подключает модули из каталога `.make/*.mk`. Не модифицируйте корневой `Makefile` без необходимости.
- Модуль `.make/edl_docker.mk` отвечает за сборку и валидацию Docker-образа.
- Модуль `.make/edl.mk` реализует команды вызова утилиты через `docker run`.
- Все цели оформляются через двойное двоеточие (`target::`) и снабжаются комментариями `## Описание`.

Для просмотра доступных целей используйте команды `make list` и `make help`.

---

## 6. Стандарты качества и CI/CD

В проекте настроены обязательные проверки качества:

### 6.1. Markdownlint

Вся документация проверяется утилитой `markdownlint-cli2`:

```bash
npx markdownlint-cli2
```

Перед отправкой изменений результат проверки должен возвращать `0 issues in 0 files`.

### 6.2. ShellCheck

Все shell-скрипты проверяются статическим анализатором:

```bash
shellcheck docker/docker-entrypoint.sh
```

### 6.3. Непрерывная интеграция (GitHub Actions)

В каталоге `.github/workflows/` настроены пайплайны:

- `build_debian.yml`: сборка и публикация multi-arch образов (`linux/amd64`, `linux/arm64`) в `ghcr.io/boardport/edl`.
- `markdownlint.yml`: проверка форматирования документации.
- `shellcheck.yml`: проверка shell-скриптов.

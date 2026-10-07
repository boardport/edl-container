# 🐳 Docker-контекст: `docker/`

Каталог содержит конфигурационные файлы для сборки, настройки и низкоуровневого запуска изолированного Docker-контейнера
для утилиты [bkerler/edl](https://github.com/bkerler/edl).

---

## 📁 Содержимое каталога

```text
docker/
├── .gitignore              # Локальные исключения сборки
├── Dockerfile.debian       # Рецепт сборки production-образа на базе Debian 12 Slim и Python 3.11
├── README.md               # Руководство по Docker-контексту (English)
├── README_RU.md            # Руководство по Docker-контексту (Russian)
└── docker-entrypoint.sh    # Скрипт точки входа: хуки /docker-entrypoint.d/ и нормализация прав UID/GID
```

---

## ⚡ Краткая справка по сборке и запуску

### Сборка образа

```bash
make docker-build
# либо напрямую через Docker CLI:
docker build -f docker/Dockerfile.debian -t ghcr.io/boardport/edl .
```

### Прямой запуск через Docker CLI (без GNU Make)

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$(pwd)/dumps:/opt/edl/dumps" \
  -e EDL_DUMP_UID=$(id -u) \
  ghcr.io/boardport/edl printgpt
```

---

## 📚 Подробная документация

Все детали устройства контейнера, параметры окружения и сценарии вынесены в документацию проекта:

- 💻 **[Руководство разработчика и Docker](../docs/development.ru.md)** — полное описание переменных (`EDL_DUMP_UID`),
  точек монтирования, хуков инициализации и рецептов Docker CLI.
- 🏛️ **[Архитектура контейнера](../docs/architecture.ru.md)** — жизненный цикл контейнера, слои образа и взаимодействие с USB-шиной.
- 🛠️ **[Сценарии работы](../docs/workflows.ru.md)** — практические примеры снятия дампов, прошивки и раскирпичивания.

# 📦 BoardPort — EDL Container

[![Docker Build](https://github.com/boardport/edl-container/actions/workflows/build_debian.yml/badge.svg)](https://github.com/boardport/edl-container/actions/workflows/build_debian.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![Upstream: bkerler/edl](https://img.shields.io/badge/Upstream-bkerler%2Fedl-orange.svg)](https://github.com/bkerler/edl)
[![Project: BoardPort](https://img.shields.io/badge/Project-BoardPort-green.svg)](https://github.com/boardport)

Готовый к использованию Docker-контейнер для утилиты [EDL (Qualcomm Emergency Download Tool)](https://github.com/bkerler/edl) от B. Kerler.

Текущий репозиторий входит в экосистему **[BoardPort](https://github.com/boardport)** и предоставляет изолированную среду
со всеми предустановленными драйверами, библиотеками и базой Firehose-загрузчиков для комфортной работы через простые Make-команды.

> 🤖 **Инструкция для AI-ассистентов:** Перед выполнением любых задач в проекте обязательно ознакомьтесь с [AGENTS_RU.md](./AGENTS_RU.md).

---

## 🎯 О проекте и экосистеме BoardPort

Главная цель инициативы **BoardPort** — портирование современных дистрибутивов Linux, свежих версий ядер, легковесных ОС
и специализированных прошивок на широкий спектр неподдерживаемых, "забытых" или устаревающих устройств:

- 📶 **Китайские 4G/LTE USB-модемы и роутеры** (донглы на базе Qualcomm MSM8916, MSM8909, MSM8937 — семейство OpenStick, UFI и аналоги).
- 📱 **Смартфоны и планшеты** прошлых поколений на платформах Qualcomm Snapdragon.
- 🧩 **Отладочные платы (dev boards)** и одноплатники промышленного или хобби-сегмента (DragonBoard 410c, Inforce и др.).
- 📟 **IoT-модули и телематика**, требующие низкоуровневого восстановления, снятия дампов или перехода на чистый Linux.

В рамках этой экосистемы **EDL Container** обеспечивает надежный, воспроизводимый канал взаимодействия
с устройствами через сервисный режим аварийной загрузки **Qualcomm 9008 (EDL)** без засорения хост-системы зависимостями.

---

## 📚 Документация проекта

Вся техническая информация, инструкции по настройке и сценарии использования собраны в каталоге **[`docs/`](./docs/)**:

| Документ | Описание |
| :--- | :--- |
| 📖 **[Обзор проекта](./docs/overview.ru.md)** | Экосистема BoardPort, концепция Qualcomm EDL (9008), протоколы Sahara и Firehose |
| ⚡ **[Быстрый старт](./docs/quickstart.ru.md)** | Подготовка хоста, правила udev, выгрузка `qcserial`, аппаратные и программные методы перевода в EDL |
| 🛠️ **[Сценарии работы](./docs/workflows.ru.md)** | Снятие бэкапов (разделы и Raw Flash), прошивка, внешние Firehose-загрузчики и раскирпичивание |
| 🏛️ **[Архитектура решения](./docs/architecture.ru.md)** | Внутреннее устройство контейнера, слои образа, модель безопасности и проброс USB |
| 💻 **[Руководство разработчика](./docs/development.ru.md)** | Локальная сборка, запуск через Docker CLI без Make, переменные окружения, хуки и CI/CD |

---

## 📄 Лицензия и благодарности

- Скрипты контейнеризации, автоматизация Make, документация и сопутствующие файлы проекта распространяются под лицензией
  **[MIT](./LICENSE)**.
- Проект упаковывает утилиту [edl](https://github.com/bkerler/edl), созданную **Bjoern Kerler** (также под лицензией **MIT**).
  Искренняя благодарность автору за огромный вклад в развитие инструментов реверс-инжиниринга платформ Qualcomm.

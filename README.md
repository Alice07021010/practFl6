# Практическая работа №6 — ООО «Тмыв денег»

Продолжение ПР5. Добавлены адаптивная навигация, карточки на узком экране, ограничение ширины на больших мониторах, стартовая заглушка, тесты, скрипты сравнения сборок и GitHub Actions для Pages.

## Локальный запуск

Сначала сервер:

```powershell
cd server
node mock-server.js --port 8080 --origin http://localhost:5555
```

Потом клиент:

```powershell
flutter pub get
flutter run -d chrome --web-port=5555 --dart-define=API_BASE_URL=http://localhost:8080/api
```

## Что проверить по адаптивности

Изменять ширину окна без перезагрузки:

- 360 px — нижняя навигация, списки карточками;
- 768 px — компактный NavigationRail;
- 1280 px — расширенная боковая навигация и таблицы;
- 1920 px — содержимое ограничено по ширине.

## Проверки

```powershell
dart format lib test
flutter analyze
flutter test
flutter build web --release --dart-define=API_BASE_URL=http://localhost:8080/api
```

## Сравнение сборок

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\measure_builds.ps1
```

Скрипт создаст `dist_measurements/build_sizes.csv` для трёх вариантов: JS без tree-shake иконок, обычный оптимизированный JS release и WASM release.

## GitHub Pages

В проекте есть `.github/workflows/deploy-pages.yml`. После публикации репозитория:

1. Settings → Pages → Source → GitHub Actions.
2. В Settings → Secrets and variables → Actions → Variables добавить `API_BASE_URL` с HTTPS-адресом API.
3. Сделать push в `main`.

Workflow запускает analyze/test, собирает приложение с правильным `--base-href`, копирует `index.html` в `404.html` и публикует Pages.

Если API доступен только локально по HTTP, опубликованная HTTPS-страница не сможет к нему обратиться из-за mixed content. Для защиты ПР6 в таком случае клиент с API демонстрируется локально, а публикация показывает корректную статическую сборку.

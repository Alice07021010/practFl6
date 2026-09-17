@echo off
cd /d "%~dp0"
flutter pub get
flutter run -d chrome --web-port=5555 --dart-define=API_BASE_URL=http://localhost:8080/api
pause

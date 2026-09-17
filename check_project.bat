@echo off
cd /d "%~dp0"
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build web --release --dart-define=API_BASE_URL=http://localhost:8080/api
pause

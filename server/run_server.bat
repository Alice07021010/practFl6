@echo off
cd /d "%~dp0"
node mock-server.js --port 8080 --origin http://localhost:5555
pause

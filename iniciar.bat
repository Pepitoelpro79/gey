@echo off
title 🏳️‍🌈 Joselo - Servidor
cd /d "%~dp0"
echo Iniciando servidor de Joselo...
start http://localhost:5555
powershell -ExecutionPolicy Bypass -File "server.ps1"
pause

@echo off
rem Starts paste2save v3.05 directly in the Windows System Tray (Taskbar Notification Area)
start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Sta -File "%~dp0paste2save.ps1" -Tray %*

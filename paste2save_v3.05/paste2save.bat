@echo off
title paste2save v3.05
color 0a

powershell.exe -NoProfile -ExecutionPolicy Bypass -Sta -File "%~dp0paste2save.ps1" %*

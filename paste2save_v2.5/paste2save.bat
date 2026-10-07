@echo off
color 0a
title paste2save_v2.5
rem A simple free Utility app that pastes clipboard image to paint 
rem and then saves it as png to your desired location.


rem new file each time or overwrite same file
:choice
cls
echo.
echo (for this image)
echo.
echo (1) save with Random filename  
echo.
echo (2) or Overwrite existing file?
echo.
echo Select 1/2. Default Input is 1.
echo.
rem Choice instead of if.. to progress even without user input
CHOICE /C 12 /N /T 5 /D 1 /M "input:"
IF ERRORLEVEL 2 goto existing
IF ERRORLEVEL 1 goto random

:random
rem open existing smallest pixel image in mspaint
start paintopenx.vbs
timeout 1 /nobreak

rem paste to paint
start savepasterwr.vbs
timeout 1 /nobreak
goto task

:existing
rem open existing smallest pixel image in mspaint
start paintopenx.vbs
timeout 1 /nobreak

rem paste to paint 
start savepaster.vbs
timeout 1 /nobreak

:task
rem copy address from location.txt to a variable 
0< "location.txt" (Set /P "place=")
rem copy address from variable to clipboard
echo|set/p=%place%|clip

rem paste to paint 

timeout 6 /nobreak

rem kill paint
taskkill /F /IM mspaint.exe

rem open location & focus
start %place%
start focusexplorer.vbs
rem opens image file & focuses at it
rem start openstheimage.vbs to be included later
timeout 3 /nobreak

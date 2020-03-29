@ECHO OFF

CD ..\..

SET PATH=C:\Program Files (x86)\Atollic\TrueSTUDIO for STM32 9.3.0\Tools;%PATH%
SET PATH=C:\Program Files\Git\mingw64\bin;%PATH%

SET BUILD_CONFIGURATION=MINI_Release_Boot
SET PATH_SEPARATOR=\\

CALL make\windows\timecmd make clean

PAUSE

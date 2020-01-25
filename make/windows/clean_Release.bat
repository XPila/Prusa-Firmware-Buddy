CD ..\..
SET PATH=C:\Program Files (x86)\Atollic\TrueSTUDIO for STM32 9.3.0\Tools;%PATH%

SET BUILD_CONFIGURATION=MINI_Release_Boot
SET PATH_SEPARATOR=\\
SET SHELL_RMDIR=RMDIR /S /Q

CALL make\windows\timecmd make clean

PAUSE

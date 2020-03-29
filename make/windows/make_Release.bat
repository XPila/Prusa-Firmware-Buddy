@ECHO OFF

CD ..\..

SET PATH=C:\Program Files (x86)\Atollic\TrueSTUDIO for STM32 9.3.0\Tools;%PATH%
SET PATH=C:\Program Files (x86)\Atollic\TrueSTUDIO for STM32 9.3.0\PCTools\bin;%PATH%
SET PATH=C:\Program Files (x86)\Atollic\TrueSTUDIO for STM32 9.3.0\ARMTools\bin;%PATH%
SET PATH=C:\Program Files\Git\mingw64\bin;%PATH%

SET TOOLCHAIN_PREFIX=arm-atollic-eabi
SET BUILD_CONFIGURATION=MINI_Release_Boot
SET PATH_SEPARATOR=\\

CALL make\windows\timecmd make -j

PAUSE

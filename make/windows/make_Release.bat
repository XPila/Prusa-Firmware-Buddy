CD ..
SET PATH=C:\Program Files (x86)\Atollic\TrueSTUDIO for STM32 9.3.0\Tools;%PATH%
SET PATH=C:\Program Files (x86)\Atollic\TrueSTUDIO for STM32 9.3.0\PCTools\bin;%PATH%
SET PATH=C:\Program Files (x86)\Atollic\TrueSTUDIO for STM32 9.3.0\ARMTools\bin;%PATH%

SET BUILD_CONFIGURATION=MINI_Release_Boot
SET TOOLCHAIN_PREFIX=arm-atollic-eabi
SET PATH_SEPARATOR=\\
SET SHELL_RMDIR=RMDIR /S /Q
SET SHELL_MKDIR=MKDIR

CALL make\timecmd make -j

PAUSE

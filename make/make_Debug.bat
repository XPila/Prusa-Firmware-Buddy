CD ..
SET PATH=C:\Program Files (x86)\Atollic\TrueSTUDIO for STM32 9.3.0\Tools;%PATH%
SET PATH=C:\Program Files (x86)\Atollic\TrueSTUDIO for STM32 9.3.0\PCTools\bin;%PATH%
SET PATH=C:\Program Files (x86)\Atollic\TrueSTUDIO for STM32 9.3.0\ARMTools\bin;%PATH%

CALL make\timecmd make CONFIG=Debug_Boot "DIRSEP=\\" "DIR_RM=RMDIR /S /Q" "DIR_MK=MKDIR" -j
PAUSE

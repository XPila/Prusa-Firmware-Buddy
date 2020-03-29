@ECHO OFF

CD ..\..

SET PATH=C:\Program Files\Git\mingw64\bin;%PATH%

CALL make\windows\timecmd python utils/build.py --printer mini --build-type debug --bootloader empty --generate-bbf

PAUSE

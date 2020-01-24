
##Makefile variables
__BUILD_CONFIGURATION__  
make configurations: 'MINI\_DebugBoot', 'MINI\_ReleaseBoot'  
cmake configurations: 'mini\_debug\_emptyboot', 'mini\_release\_emptyboot'  
  
__TOOLCHAIN_PREFIX__  
'arm-none-eabi' or 'arm-atollic-eabi'  
  
__PATH_SEPARATOR__  
'/' for unix (default) or '\\\\' for windows  
  
__SHELL_RMDIR__  
'rm -rfv' for unix (default) or 'RMDIR /S /Q' for windows

__SHELL_MKDIR__  
'mkdir -p' for unix (default) or 'MKDIR' for windows

__Typical Windows settings (Atollic)__  
BUILD\_CONFIGURATION=MINI\_Release_Boot  
TOOLCHAIN\_PREFIX=arm-atollic-eabi  
PATH\_SEPARATOR=\\\\  
SHELL\_RMDIR=RMDIR /S /Q  
SHELL\_MKDIR=MKDIR  

__Typical Unix settings (Atollic)__  
BUILD\_CONFIGURATION=MINI\_Release_Boot  
TOOLCHAIN_PREFIX=arm-atollic-eabi  

#!/bin/bash
#

cd ../..

export PATH="/c/Program Files (x86)/Atollic/TrueSTUDIO for STM32 9.3.0/Tools:"$PATH
export PATH="/c/Program Files (x86)/Atollic/TrueSTUDIO for STM32 9.3.0/PCTools/bin:"$PATH
export PATH="/c/Program Files (x86)/Atollic/TrueSTUDIO for STM32 9.3.0/ARMTools/bin:"$PATH
export PATH="/c/Program Files/Git/mingw64/bin:"$PATH

export TOOLCHAIN_PREFIX=arm-atollic-eabi
export BUILD_CONFIGURATION=MINI_Release_Boot

time make -j

read x

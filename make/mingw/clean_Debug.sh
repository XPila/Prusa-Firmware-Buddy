#!/bin/bash
#

cd ../..

export PATH="/c/Program Files (x86)/Atollic/TrueSTUDIO for STM32 9.3.0/Tools:"$PATH
export PATH="/c/Program Files (x86)/Atollic/TrueSTUDIO for STM32 9.3.0/PCTools/bin:"$PATH
export PATH="/c/Program Files (x86)/Atollic/TrueSTUDIO for STM32 9.3.0/ARMTools/bin:"$PATH
export TOOLCHAIN_PREFIX=arm-atollic-eabi
export BUILD_CONFIGURATION=MINI_Debug_Boot
export TOOLCHAIN_PREFIX=arm-atollic-eabi

time make clean

read x

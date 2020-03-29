#!/bin/bash
#
# optimize source list - try to link without each source and print unused sources
# input: srclist
# output: src_to_remove

cd ../..

export PATH="/c/Program Files (x86)/Atollic/TrueSTUDIO for STM32 9.3.0/ARMTools/bin:"$PATH 
export PATH="/c/Program Files (x86)/Atollic/TrueSTUDIO for STM32 9.3.0/PCTools/bin:"$PATH 
export PATH="/c/Program Files (x86)/Atollic/TrueSTUDIO for STM32 9.3.0/Tools:"$PATH 
export PATH="/c/Program Files/Git/mingw64/bin:"$PATH

export TOOLCHAIN_PREFIX=arm-atollic-eabi

cat 'srclist' | while read fn; do
	if make test SRCFILE_TO_EXCLUDE=$fn >> /dev/null 2>&1; then
		echo $fn
	fi
done | tee 'src_to_remove'
echo 'finished'

read x
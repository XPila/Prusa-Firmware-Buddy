#!/bin/bash
#
# compress source list by addprefix function

# directory tree structure
DIR_TREE=$(cat <<EOF
lib/
	Arduino_Core_A3ides/cores/arduino/
	Drivers/STM32F4xx_HAL_Driver/Src/
	inih/
	Marlin/Marlin/src/
		core/
		feature/
		gcode/
			bedlevel/
			config/
			control/
			feature/
			geometry/
			host/
			lcd/
			motion/
			probe/
			sdcard/
			stats/
			temperature/
		HAL/HAL_STM32_F4_F7/
		lcd/
		libs/
		module/
	Middlewares/
		ST/STM32_USB_Device_Library/
			Class/
			Core/
		ST/STM32_USB_Host_Library/
			Class/
			Core/
		ST/Utilites/CPU/
		Third_Party/
			FatFs/src/
			FreeRTOS/Source/
			lpng/
			LwIP/src/
				core/
			zlib/
	TMCStepper/src/source/
src/
	common/
	gui/
		Dialogs/
		Test/
		Wizard/
	guiapi/src/
	wui/
EOF
)

cd ../..

echo "processing directory tree..."
# root directory stack (LF separated)
root_stack=
# last item path
last_path=
# last item depth in DIR_TREE (number of tabs at beginning +1)
last_depth=1
# loop over all lines in DIR_TREE, replace tabs at beginning with "/"
DIR_LIST=$(\
echo "$DIR_TREE" | tr '\t' "\/" | while read line; do            # loop
	depth=$(echo "$line" | sed "s/\(^[\/]*\).*/\1/" | wc -m)     # calc depth = number of "/" at beginning +1
	item=$(echo "$line" | sed "s/^[\/]*//")                      # extract directory without "/" at beginning
	if [ $(($depth - $last_depth)) -eq 1 ]; then                 # new depth is +1 greater than last
		root_stack=$(printf '%s\n%s' "$root_stack" "$last_path") # push item to stack
		root=$(echo "$root_stack" | tail -n1)                    # get last item from stack
	elif [ $depth -lt $last_depth ]; then                        # new depth is less than last
		while [ $depth -lt $last_depth ]; do                     # loop - (last_depth used as counter)
			root_stack=$(echo "$root_stack" | head -n-1)         # remove item from stack
			last_depth=$(($last_depth - 1))                      # decrease last_depth
		done
		root=$(echo "$root_stack" | tail -n1)                    # get last item from stack
	elif [ $depth -eq $last_depth ]; then                        # new depth is equal to last
		root=$(echo "$root_stack" | tail -n1)                    # get last item from stack
	else
		echo " ERR: not allowed" >&2
	fi
	last_path=$root$item
	last_depth=$depth
	echo $last_path' '$depth' '$item
	if [ ! -e $last_path ]; then echo " ERR: not found" >&2; fi
done
)

echo "processing files..."
SRC_LIST=$(cat 'srclist' | tr ' ' "\n")
FILE_LIST=$(\
echo "$DIR_LIST" | sort -r | while read path depth item; do
	files=$(echo "$SRC_LIST" | grep ^$path | cut -c$((${#path}+1))- | tr '\n' " ")
	echo $depth' '$item' '$files
	SRC_LIST=$(echo "$SRC_LIST" | grep -v ^$path)
done
)

echo "generating compressed list..."
last_depth=1
(echo "$FILE_LIST" | tac; echo 1 ) | while read depth item files; do
	if [ $depth -gt $last_depth ]; then             # new depth is greater than last
		echo '\'
	elif [ $depth -lt $last_depth ]; then           # new depth is less than last
		printf '%*s' $(($last_depth - $depth)) | tr ' ' ')'
		echo ')\'
	elif [ $depth -eq $last_depth ]; then           # new depth is equal to last
		echo ')\'
	fi
	printf '%*s' $(($depth - 1)) | tr ' ' '\t'
	echo -n '$(addprefix '$item','$files
	last_depth=$depth
done | head -n-1 | tail -n+2 >srclist_compressed

echo 'finished'

read x

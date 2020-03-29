#-----------------------------------------------------------------------------------------------------------------------
# CMake from Makefile

CMAKE_CONFIG := $(subst _, ,$(BUILD_CONFIGURATION))
CMAKE_PRINTER := $(word 1,$(CMAKE_CONFIG))
CMAKE_BUILD_TYPE := $(word 2,$(CMAKE_CONFIG))
CMAKE_BOOTLOADER := $(subst boot,,$(word 3,$(CMAKE_CONFIG)))

cmake:
	@echo CMAKE_CONFIG=$(CMAKE_CONFIG)
	@echo CMAKE_PRINTER=$(CMAKE_PRINTER)
	@echo CMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE)
	@echo CMAKE_BOOTLOADER=$(CMAKE_BOOTLOADER)
	@python utils/build.py \
		--printer $(CMAKE_PRINTER)\
		--build-type $(CMAKE_BUILD_TYPE)\
		--bootloader $(CMAKE_BOOTLOADER)\
		--no-store-output --generate-bbf
	@$(SHELL_RM) $(subst /,$(PATH_SEPARATOR),$(OUT))$(PATH_SEPARATOR)firmware.elf
	@$(SHELL_MV) $(subst /,$(PATH_SEPARATOR),$(OUT))$(PATH_SEPARATOR)firmware firmware.elf

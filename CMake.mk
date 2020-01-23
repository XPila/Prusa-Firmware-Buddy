#-----------------------------------------------------------------------------------------------------------------------
# CMake from Makefile

CMAKE_CONFIG := $(subst _, ,$(BUILD_CONFIGURATION))
CMAKE_PRINTER := $(word 1,$(CMAKE_CONFIG))
CMAKE_BUILD_TYPE := $(word 2,$(CMAKE_CONFIG))
CMAKE_BOOTLOADER := $(subst boot,,$(word 3,$(CMAKE_CONFIG)))

cmake:
# check valid build configuration for cmake
ifneq (,$(filter-out Debug_Boot Release_Boot mini_debug_emptyboot mini_release_emptyboot, $(BUILD_CONFIGURATION)))
$(error invalid configuration "$(BUILD_CONFIGURATION)")
endif
	@echo CMAKE_CONFIG=$(CMAKE_CONFIG)
	@echo CMAKE_PRINTER=$(CMAKE_PRINTER)
	@echo CMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE)
	@echo CMAKE_BOOTLOADER=$(CMAKE_BOOTLOADER)
	@python utils/build.py \
		--printer $(CMAKE_PRINTER)\
		--build-type $(CMAKE_BUILD_TYPE)\
		--bootloader $(CMAKE_BOOTLOADER)\
		--no-store-output --generate-bbf

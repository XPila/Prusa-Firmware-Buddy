#-----------------------------------------------------------------------------------------------------------------------
# Atollic project generator

include make/Eclipse_project.mk
include make/Atollic_cproject.mk
include make/Atollic_settings.mk
#include make/Eclipse_cdtprojectproperties.mk

# generate Atollic project file ".project"
atollic:
	@echo generting Atollic project "$(PROJECT)"
	@make -s eclipse_project PROJECT=Prusa-Firmware-Buddy_EEPROM
	@make -s atollic_cproject PROJECT=Prusa-Firmware-Buddy_EEPROM
	@make -s atollic_settings PROJECT=Prusa-Firmware-Buddy_EEPROM
#	@make -s eclipse_cdtprojectproperties BUILD_CONFIGURATION=MINI_Debug_Boot
#	@make -s eclipse_cdtprojectproperties BUILD_CONFIGURATION=MINI_Release_Boot

#-----------------------------------------------------------------------------------------------------------------------
# Eclipse project generator

include make/Eclipse_project.mk
include make/Eclipse_cproject.mk
include make/Eclipse_cdtprojectproperties.mk

# generate eclipse project file ".project"
eclipse:
	@echo generting eclipse project "$(PROJECT)"
	@make -s eclipse_project
	@make -s eclipse_cproject
	@make -s eclipse_cdtprojectproperties BUILD_CONFIGURATION=MINI_Debug_Boot
	@make -s eclipse_cdtprojectproperties BUILD_CONFIGURATION=MINI_Release_Boot

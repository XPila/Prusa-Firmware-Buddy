#-----------------------------------------------------------------------------------------------------------------------
# Atollic .settings folder generator

# generate atollic ".settings" folder containing .prefs files
atollic_settings:
	@echo generting atollic .settings folder
ifeq ("$(wildcard make/.settings)","")
	@echo creating .settings
	@$(SHELL_MKDIR) $(subst /,$(PATH_SEPARATOR),make/.settings)
endif
	@make -s atollic_settings_hardware_device
	@make -s atollic_settings_cdt_core

# generate file com.atollic.truestudio.debug.hardware_device.prefs into ".settings" folder
atollic_settings_hardware_device:
	@echo generting .settings/com.atollic.truestudio.debug.hardware_device.prefs
	$(file > make/.settings/com.atollic.truestudio.debug.hardware_device.prefs,$(atollic_prefs_settings_hardware_device))

# generate file org.eclipse.cdt.core.prefs into ".settings" folder
atollic_settings_cdt_core:
	@echo generting .settings/org.eclipse.cdt.core.prefs
	$(file > make/.settings/org.eclipse.cdt.core.prefs,$(atollic_prefs_settings_cdt_core))


# .settings/com.atollic.truestudio.debug.hardware_device.prefs
define atollic_prefs_settings_hardware_device =
eclipse.preferences.version=1
BOARD=None
CODE_LOCATION=FLASH
ENDIAN=Little-endian
MCU=STM32F407VG
MCU_VENDOR=STMicroelectronics
MODEL=Pro
PROJECT_FORMAT_VERSION=2
TARGET=STM32
VERSION=9.3.0
endef

# shortcut for uri
atollic_env_uri := environment/project/com.atollic.truestudio.exe.debug.toolchain

# file .settings/org.eclipse.cdt.core.prefs
define atollic_prefs_settings_cdt_core =
eclipse.preferences.version=1
$(call atollic_prefs_settings_cdt_core_config,1147268816)
$(atollic_env_uri).$(1)/append=true
$(atollic_env_uri).$(1)/appendContributed=true
endef

# config in atollic_prefs_settings_cdt_core, args: (1)config_id
define atollic_prefs_settings_cdt_core_config =
$(call atollic_prefs_settings_cdt_core_item,$(1),PATH_SEPARATOR,\\\\)
$(call atollic_prefs_settings_cdt_core_item,$(1),SHELL_MKDIR,MKDIR)
$(call atollic_prefs_settings_cdt_core_item,$(1),SHELL_RMDIR,RMDIR /S /Q)
$(call atollic_prefs_settings_cdt_core_item,$(1),TOOLCHAIN_PREFIX,arm-atollic-eabi)
endef

# item in atollic_prefs_settings_cdt_core, args: (1)config_id, (2)name, (3)value
define atollic_prefs_settings_cdt_core_item =
$(atollic_env_uri).$(1)/$(2)/delimiter=;
$(atollic_env_uri).$(1)/$(2)/operation=append
$(atollic_env_uri).$(1)/$(2)/value=$(3)
endef

#-----------------------------------------------------------------------------------------------------------------------
# Atollic .cproject xml file generator

# generate atollic project file ".cproject"
atollic_cproject:
	@echo generting atollic .cproject xml file
	$(file > make/.cproject,$(atollic_xml_cproject))

# BUILD_CONFIGURATION_IDS = 
#  MINI_Debug_Boot 1147268816
#  MINI_Release_Boot 1147268816.808720139
#  mini_debug_emptyboot 1147268816.1642082093
#  mini_release_emptyboot 1147268816.808720139.628298364

# cproject
define atollic_xml_cproject
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<?fileVersion 4.0.0?><cproject storage_type_id="org.atollic.cdt.core.XmlProjectDescriptionStorage">
$(atollic_xml_cdtCoreSettings)
$(atollic_xml_cdtBuildSystem)
$(atollic_xml_languageSettingsProviders)
$(atollic_xml_refreshScope)
$(atollic_xml_buildTargets)
</cproject>
endef
#$(atollic_xml_scannerConfiguration)

# cdtCoreSettings
define atollic_xml_cdtCoreSettings =
<storageModule moduleId="org.atollic.cdt.core.settings">
$(call atollic_xml_cdtConfiguration,MINI_Debug_Boot,1147268816)
</storageModule>
endef
#$(call atollic_xml_cdtConfiguration,MINI_Release_Boot)
#$(call atollic_xml_cdtConfiguration,mini_debug_emptyboot)
#$(call atollic_xml_cdtConfiguration,mini_release_emptyboot)

# cdtBuildSystem
define atollic_xml_cdtBuildSystem =
<storageModule moduleId="cdtBuildSystem" version="4.0.0">
	<project id="$(PROJECT).null.1276667596" name="$(PROJECT)"/>
</storageModule>
endef

# languageSettingsProviders
define atollic_xml_languageSettingsProviders =
<storageModule moduleId="org.atollic.cdt.core.LanguageSettingsProviders"/>
endef

# refreshScope
define atollic_xml_refreshScope =
<storageModule moduleId="refreshScope" versionNumber="2">
$(call atollic_xml_refreshScope_config,MINI_Debug_Boot)
</storageModule>
endef
#$(call atollic_xml_refreshScope_config,MINI_Release_Boot)
#$(call atollic_xml_refreshScope_config,mini_debug_emptyboot)
#$(call atollic_xml_refreshScope_config,mini_release_emptyboot)

# scannerConfiguration
define atollic_xml_scannerConfiguration =
<storageModule moduleId="scannerConfiguration">
<autodiscovery enabled="true" problemReportingEnabled="true" selectedProfileId=""/>
$(call atollic_xml_scannerConfig,1147268816,          346708880, 320776978,1988991514,702613059, 394661970)
</storageModule>
endef
#$(call atollic_xml_scannerConfig,1147268816.808720139,         ,2021832184, 504662250,940200967,1628003946)

# buildTargets
define atollic_xml_buildTargets =
<storageModule moduleId="org.atollic.cdt.make.core.buildtargets">
<buildTargets>
$(call atollic_xml_buildTarget,clean,clean,make,-j)
$(call atollic_xml_buildTarget,build,build,make,-j)
$(call atollic_xml_buildTarget,clean_all,clean_all,make,-j)
$(call atollic_xml_buildTarget,build_all,build_all,make,-j)
</buildTargets>
</storageModule>
endef
#$(call atollic_xml_buildTarget,print_ALLSRC,print_ALLSRC,make,)
#$(call atollic_xml_buildTarget,print_SYMBOLS,print_SYMBOLS,make,)
#$(call atollic_xml_buildTarget,print_INCLUDES,print_INCLUDES,make,)
#$(call atollic_xml_buildTarget,print_ENVVARS,print_ENVVARS,make,)
#$(call atollic_xml_buildTarget,atollic_cdtprojectproperties,atollic_cdtprojectproperties,make,)
#$(call atollic_xml_buildTarget,atollic_project,atollic_project,make)
#$(call atollic_xml_buildTarget,atollic,atollic,make)



# cdtConfiguration, args: name, id, toolchain_id
define atollic_xml_cdtConfiguration =
<cconfiguration id="com.atollic.truestudio.exe.debug.toolchain.$(2)">
	<storageModule buildSystemId="org.atollic.cdt.managedbuilder.core.configurationDataProvider" id="com.atollic.truestudio.exe.debug.toolchain.$(2)" moduleId="org.atollic.cdt.core.settings" name="$(1)">
		<externalSettings/>
		<extensions>
			<extension id="org.atollic.cdt.core.ELF" point="org.atollic.cdt.core.BinaryParser"/>
			<extension id="org.atollic.cdt.core.GASErrorParser" point="org.atollic.cdt.core.ErrorParser"/>
			<extension id="org.atollic.cdt.core.GLDErrorParser" point="org.atollic.cdt.core.ErrorParser"/>
			<extension id="org.atollic.cdt.core.GCCErrorParser" point="org.atollic.cdt.core.ErrorParser"/>
			<extension id="org.atollic.cdt.core.GmakeErrorParser" point="org.atollic.cdt.core.ErrorParser"/>
			<extension id="org.atollic.cdt.core.CWDLocator" point="org.atollic.cdt.core.ErrorParser"/>
		</extensions>
	</storageModule>
	<storageModule moduleId="cdtBuildSystem" version="4.0.0">
		<configuration artifactName="$${ProjName}" buildProperties="" description="make" id="com.atollic.truestudio.exe.debug.toolchain.$(2)" name="$(1)" parent="org.atollic.cdt.build.core.emptycfg">
			<folderInfo id="com.atollic.truestudio.exe.debug.toolchain.$(2).$(3)" name="/" resourcePath="">
				<toolChain id="com.atollic.truestudio.exe.debug.toolchain.742233476" name="Atollic ARM Tools" superClass="com.atollic.truestudio.exe.debug.toolchain">
					<option id="com.atollic.truestudio.general.runtimelib.2041860126" name="Runtime Library" superClass="com.atollic.truestudio.general.runtimelib" value="com.atollic.truestudio.ld.general.cclib.CCSmallCSmall" valueType="enumerated"/>
					<option id="com.atollic.truestudio.toolchain_options.mcu.2139731201" name="Microcontroller" superClass="com.atollic.truestudio.toolchain_options.mcu" value="STM32F407VG" valueType="string"/>
					<option id="com.atollic.truestudio.toolchain_options.vendor.1973571411" name="Vendor name" superClass="com.atollic.truestudio.toolchain_options.vendor" value="STMicroelectronics" valueType="string"/>
					<targetPlatform archList="all" binaryParser="org.atollic.cdt.core.ELF" id="com.atollic.truestudio.exe.debug.toolchain.platform.1713535076" isAbstract="false" name="Debug platform" osList="all" superClass="com.atollic.truestudio.exe.debug.toolchain.platform"/>
					<builder buildPath="$${workspace_loc:/$(PROJECT)}" customBuilderProperties="toolChainpathType=1|toolChainpathString=C:\\Program Files (x86)\\Atollic\\TrueSTUDIO for STM32 9.3.0\\ARMTools\\bin|" id="com.atollic.pctools.managedbuild.target.gnu.builder.base.1600182299" incrementalBuildTarget="" keepEnvironmentInBuildfile="false" managedBuildOn="false" name="GNU Make Builder" parallelBuildOn="true" parallelizationNumber="unlimited" superClass="com.atollic.pctools.managedbuild.target.gnu.builder.base">
						<outputEntries>
							<entry flags="VALUE_WORKSPACE_PATH|RESOLVED" kind="outputPath" name=""/>
						</outputEntries>
					</builder>
					<tool id="com.atollic.truestudio.exe.debug.toolchain.as.1702289608" name="Assembler" superClass="com.atollic.truestudio.exe.debug.toolchain.as">
						<option id="com.atollic.truestudio.common_options.target.fpucore.1960034663" name="FPU" superClass="com.atollic.truestudio.common_options.target.fpucore" value="com.atollic.truestudio.common_options.target.fpucore.fpv4-sp-d16" valueType="enumerated"/>
						<option id="com.atollic.truestudio.as.symbols.defined.1320017284" name="Defined symbols" superClass="com.atollic.truestudio.as.symbols.defined" valueType="definedSymbols">
$(atollic_xml_cdtConfig_symbols)
						</option>
						<inputType id="com.atollic.truestudio.as.input.1097781859" name="Input" superClass="com.atollic.truestudio.as.input"/>
					</tool>
					<tool id="com.atollic.truestudio.exe.debug.toolchain.gcc.320776978" name="C Compiler" superClass="com.atollic.truestudio.exe.debug.toolchain.gcc">
						<option id="com.atollic.truestudio.common_options.target.fpucore.1017744015" name="FPU" superClass="com.atollic.truestudio.common_options.target.fpucore" value="com.atollic.truestudio.common_options.target.fpucore.fpv4-sp-d16" valueType="enumerated"/>
						<option id="com.atollic.truestudio.gcc.directories.select.1217573971" name="Include path" superClass="com.atollic.truestudio.gcc.directories.select" valueType="includePath">
$(atollic_xml_cdtConfig_includes)
						</option>
						<option id="com.atollic.truestudio.gcc.symbols.defined.1388051271" name="Defined symbols" superClass="com.atollic.truestudio.gcc.symbols.defined" valueType="definedSymbols">
$(atollic_xml_cdtConfig_symbols)
						</option>
						<inputType id="com.atollic.truestudio.gcc.input.1988991514" superClass="com.atollic.truestudio.gcc.input"/>
					</tool>
					<tool id="com.atollic.truestudio.exe.debug.toolchain.ld.202942692" name="C Linker" superClass="com.atollic.truestudio.exe.debug.toolchain.ld"/>
					<tool id="com.atollic.truestudio.exe.debug.toolchain.gpp.702613059" name="C++ Compiler" superClass="com.atollic.truestudio.exe.debug.toolchain.gpp">
						<option id="com.atollic.truestudio.common_options.target.fpucore.409805638" name="FPU" superClass="com.atollic.truestudio.common_options.target.fpucore" value="com.atollic.truestudio.common_options.target.fpucore.fpv4-sp-d16" valueType="enumerated"/>
						<option id="com.atollic.truestudio.gpp.directories.select.358520694" name="Include path" superClass="com.atollic.truestudio.gpp.directories.select" valueType="includePath">
$(atollic_xml_cdtConfig_includes)
						</option>
						<option id="com.atollic.truestudio.gpp.symbols.defined.1763081578" name="Defined symbols" superClass="com.atollic.truestudio.gpp.symbols.defined" valueType="definedSymbols">
$(atollic_xml_cdtConfig_symbols)
						</option>
						<inputType id="com.atollic.truestudio.gpp.input.394661970" superClass="com.atollic.truestudio.gpp.input"/>
					</tool>
					<tool id="com.atollic.truestudio.exe.debug.toolchain.ldcc.1021713582" name="C++ Linker" superClass="com.atollic.truestudio.exe.debug.toolchain.ldcc">
						<option id="com.atollic.truestudio.common_options.target.fpucore.200322984" name="FPU" superClass="com.atollic.truestudio.common_options.target.fpucore" value="com.atollic.truestudio.common_options.target.fpucore.fpv4-sp-d16" valueType="enumerated"/>
						<inputType id="com.atollic.truestudio.ldcc.input.1844210681" name="Input" superClass="com.atollic.truestudio.ldcc.input">
							<additionalInput kind="additionalinputdependency" paths="$$(USER_OBJS)"/>
							<additionalInput kind="additionalinput" paths="$$(LIBS)"/>
						</inputType>
					</tool>
					<tool id="com.atollic.truestudio.ar.base.1754718182" name="Archiver" superClass="com.atollic.truestudio.ar.base"/>
					<tool id="com.atollic.truestudio.exe.debug.toolchain.secoutput.2097371144" name="Other" superClass="com.atollic.truestudio.exe.debug.toolchain.secoutput"/>
				</toolChain>
			</folderInfo>
		</configuration>
	</storageModule>
	<storageModule moduleId="org.atollic.cdt.core.externalSettings"/>
</cconfiguration>
endef

# scannerConfig, args: (1)config_id, (2)toolchain_id, (3)gcc_tool_id, (4)gcc_input_id, (5)gpp_tool_id, (6)gpp_input_id
define atollic_xml_scannerConfig =
$(call atollic_xml_scannerConfigBuildInfo,com.atollic.truestudio.exe.debug.toolchain.$(1);com.atollic.truestudio.exe.debug.toolchain.$(1).$(2);com.atollic.truestudio.exe.debug.toolchain.gcc.$(3);com.atollic.truestudio.gcc.input.$(4),com.atollic.truestudio.mbs.ARMToolsPerProjectProfileC)
$(call atollic_xml_scannerConfigBuildInfo,com.atollic.truestudio.exe.debug.toolchain.$(1);com.atollic.truestudio.exe.debug.toolchain.$(1).$(2);com.atollic.truestudio.exe.debug.toolchain.gpp.$(5);com.atollic.truestudio.gpp.input.$(6),com.atollic.truestudio.mbs.ARMToolsPerProjectProfileCPP)
endef

# scannerConfigBuildInfo, args: instanceId, selectedProfileId
define atollic_xml_scannerConfigBuildInfo =
<scannerConfigBuildInfo instanceId="$(1)">
	<autodiscovery enabled="true" problemReportingEnabled="true" selectedProfileId="$(2)"/>
</scannerConfigBuildInfo>
endef

# refreshScope_config, args: name
define atollic_xml_refreshScope_config =
<configuration configurationName="$(1)">
	<resource resourceType="PROJECT" workspacePath="/$(PROJECT)"/>
</configuration>
endef

# buildTarget, args: name, target, command, params
define atollic_xml_buildTarget =
<target name="$(1)" path="" targetID="org.atollic.cdt.build.MakeTargetBuilder">
	<buildCommand>$(3)</buildCommand>
	<buildArguments>$(4)</buildArguments>
	<buildTarget>$(2)</buildTarget>
	<stopOnError>true</stopOnError>
	<useDefaultCommand>false</useDefaultCommand>
	<runAllBuilders>false</runAllBuilders>
</target>
endef

# cdtConfig_includes, args: name
define atollic_xml_cdtConfig_includes =
<listOptionValue builtIn="false" value="../include"/>
<listOptionValue builtIn="false" value="../include/freertos"/>
<listOptionValue builtIn="false" value="../include/marlin"/>
<listOptionValue builtIn="false" value="../include/stm32f4_hal"/>
<listOptionValue builtIn="false" value="../include/usb_device"/>
<listOptionValue builtIn="false" value="../include/usb_host"/>
<listOptionValue builtIn="false" value="../lib/Drivers/STM32F4xx_HAL_Driver/Inc"/>
<listOptionValue builtIn="false" value="../lib/Drivers/STM32F4xx_HAL_Driver/Inc/Legacy"/>
<listOptionValue builtIn="false" value="../lib/Drivers/CMSIS/Device/ST/STM32F4xx/Include"/>
<listOptionValue builtIn="false" value="../lib/Drivers/CMSIS/Include"/>
<listOptionValue builtIn="false" value="../lib/Middlewares/Third_Party/FatFs/src"/>
<listOptionValue builtIn="false" value="../lib/Middlewares/Third_Party/FreeRTOS/Source/include"/>
<listOptionValue builtIn="false" value="../lib/Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS"/>
<listOptionValue builtIn="false" value="../lib/Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F"/>
<listOptionValue builtIn="false" value="../lib/Middlewares/ST/STM32_USB_Device_Library/Core/Inc"/>
<listOptionValue builtIn="false" value="../lib/Middlewares/ST/STM32_USB_Device_Library/Class/CDC/Inc"/>
<listOptionValue builtIn="false" value="../lib/Middlewares/ST/STM32_USB_Host_Library/Core/Inc"/>
<listOptionValue builtIn="false" value="../lib/Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc"/>
<listOptionValue builtIn="false" value="../lib/Arduino_Core_A3ides/cores/arduino"/>
<listOptionValue builtIn="false" value="../lib/Arduino_Core_A3ides/cores/arduino/stm32"/>
<listOptionValue builtIn="false" value="../lib/Arduino_Core_A3ides/variants/A3IDES_F407VET6_2209"/>
<listOptionValue builtIn="false" value="../lib/LiquidCrystal_I2C"/>
<listOptionValue builtIn="false" value="../lib/TMCStepper/src"/>
<listOptionValue builtIn="false" value="../lib/Middlewares/Third_Party/zlib"/>
<listOptionValue builtIn="false" value="../lib/Middlewares/Third_Party/lpng"/>
<listOptionValue builtIn="false" value="../src/gui"/>
<listOptionValue builtIn="false" value="../src/gui/Dialogs"/>
<listOptionValue builtIn="false" value="../src/guiapi/include"/>
<listOptionValue builtIn="false" value="../src/wui"/>
<listOptionValue builtIn="false" value="../src/common"/>
<listOptionValue builtIn="false" value="../lib/Marlin/Marlin"/>
<listOptionValue builtIn="false" value="../lib/Middlewares/Third_Party/LwIP/system"/>
<listOptionValue builtIn="false" value="../lib/Middlewares/Third_Party/LwIP/src/apps/httpd"/>
<listOptionValue builtIn="false" value="../lib/Middlewares/Third_Party/LwIP/src/include"/>
<listOptionValue builtIn="false" value="../lib/Middlewares/Third_Party/LwIP/src/include/netif/ppp"/>
<listOptionValue builtIn="false" value="../lib/Middlewares/Third_Party/LwIP/src/include/lwip"/>
<listOptionValue builtIn="false" value="../lib/Middlewares/Third_Party/LwIP/src/include/lwip/apps"/>
<listOptionValue builtIn="false" value="../lib/Middlewares/Third_Party/LwIP/src/include/lwip/priv"/>
<listOptionValue builtIn="false" value="../lib/Middlewares/Third_Party/LwIP/src/include/lwip/prot"/>
<listOptionValue builtIn="false" value="../lib/Middlewares/Third_Party/LwIP/src/include/netif"/>
<listOptionValue builtIn="false" value="../lib/Middlewares/Third_Party/LwIP/src/include/posix"/>
<listOptionValue builtIn="false" value="../lib/inih"/>
endef

# cdtConfig_symbols, args: name
define atollic_xml_cdtConfig_symbols =
<listOptionValue builtIn="false" value="__weak='__attribute__((weak))'"/>
<listOptionValue builtIn="false" value="__packed='__attribute__((__packed__))'"/>
<listOptionValue builtIn="false" value="STM32F407xx"/>
<listOptionValue builtIn="false" value="STM32F4xx"/>
<listOptionValue builtIn="false" value="HAVE_HWSERIAL2"/>
<listOptionValue builtIn="false" value="STM32GENERIC"/>
<listOptionValue builtIn="false" value="STM32F4"/>
<listOptionValue builtIn="false" value="ARDUINO=187"/>
<listOptionValue builtIn="false" value="MOTHERBOARD=1823"/>
<listOptionValue builtIn="false" value="USE_HAL_DRIVER"/>
<listOptionValue builtIn="false" value="USBD_USE_CDC"/>
<listOptionValue builtIn="false" value="USBCON"/>
<listOptionValue builtIn="false" value="_EXTUI"/>
<listOptionValue builtIn="false" value="LWIP_HTTPD_CUSTOM_FILES=1"/>
<listOptionValue builtIn="false" value="MARLIN_DISABLE_INFINITE_LOOP"/>
<listOptionValue builtIn="false" value="PRINTER_TYPE=2"/>
<listOptionValue builtIn="false" value="FW_BUILD_NUMBER=1"/>
<listOptionValue builtIn="false" value="FW_VERSION=402"/>
<listOptionValue builtIn="false" value="_DEBUG"/>
endef

# cdtConfig_symbols, args: name
define atollic_xml_cdtConfig_id =
endef

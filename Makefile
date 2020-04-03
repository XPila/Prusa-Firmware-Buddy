#-----------------------------------------------------------------------------------------------------------------------
# Makefile to compile and link Prusa-Firmware-Buddy
PROJECT ?= Prusa-Firmware-Buddy

# build configuration list for make
MAKE_CONFIGURATIONS  := MINI_Debug_Boot MINI_Release_Boot
# build configuration list for cmake
CMAKE_CONFIGURATIONS := mini_debug_emptyboot mini_release_emptyboot
# list of all build configurations
ALL_CONFIGURATIONS   := $(MAKE_CONFIGURATIONS) $(CMAKE_CONFIGURATIONS)
# selected build configuration, default is MINI_Release_Boot
BUILD_CONFIGURATION  ?= MINI_Release_Boot
# check valid build configuration
ifneq (,$(filter-out $(ALL_CONFIGURATIONS), $(BUILD_CONFIGURATION)))
$(error invalid configuration "$(BUILD_CONFIGURATION)")
endif

# target platform prefix, default is arm-none-eabi
TOOLCHAIN_PREFIX ?= arm-none-eabi

# file path separator (default is unix '/', for windows use - '\\')
PATH_SEPARATOR ?= /
# unix shell or windows shell - determine by PATH_SEPARATOR
SHELL_IS_UNIX ?= $(findstring /,$(PATH_SEPARATOR))
# shell command for removing directories
SHELL_RMDIR ?= $(if $(SHELL_IS_UNIX),rm -rvf,RMDIR /S /Q)
# shell command for creating directories
SHELL_MKDIR ?= $(if $(SHELL_IS_UNIX),mkdir -p,MKDIR)
# shell command for removing files
SHELL_RM ?= $(if $(SHELL_IS_UNIX),rm,DEL /Q)
# shell command for renaming files/dirs
SHELL_MV ?= $(if $(SHELL_IS_UNIX),mv,REN)
# shell command 'cat'
SHELL_CAT ?= $(if $(SHELL_IS_UNIX),cat,TYPE)
# shell command separator
SHELL_CMDSEP ?= $(if $(SHELL_IS_UNIX), ; , & )

# printer name from configuration
PRINTER ?= $(word 1,$(subst _, ,$(BUILD_CONFIGURATION)))
# printer type from printer name
PRINTER_TYPE = $(subst MINI,2,$(PRINTER))
# default firmware buildnumber from git
FW_BUILD_NUMBER ?= $(shell git rev-list --count HEAD)
# firmware version from file 'version', format '4.0.5'
FW_VERSION ?= $(file < version.txt)
# firmware version suffix, format '-BETA+1234'
FW_VERSION_SUFFIX ?= -BETA+$(FW_BUILD_NUMBER)
# firmware version full, format '4.0.5-BETA+1234'
FW_VERSION_FULL ?= $(FW_VERSION)$(FW_VERSION_SUFFIX)
# default arduino version 1.87
ARDUINO     := 187
# default matherboard A3IDES_2209_02
MOTHERBOARD := 1823

# output folder (output directory tree will be automaticaly created)
OUT := build/$(BUILD_CONFIGURATION)

# gcc, g++ and objcopy tool
GCC    := $(TOOLCHAIN_PREFIX)-gcc
GPP    := $(TOOLCHAIN_PREFIX)-g++
OBJCPY := $(TOOLCHAIN_PREFIX)-objcopy

# output files
OUTDIR := $(OUT)/$(PROJECT).dir # file containing list of created directories
OUTELF := $(OUT)/$(PROJECT).elf # elf output file
OUTHEX := $(OUT)/$(PROJECT).hex # hex output file
OUTBIN := $(OUT)/$(PROJECT).bin # bin output file

# all source
ifneq ("$(wildcard srclist)","")
ALLSRC := $(file < srclist)
else
ALLSRC := \
$(addprefix lib/,CRC/tm_stm32f4_crc.c QR/qrcodegen.c\
	$(addprefix Arduino_Core_A3ides/cores/arduino/,HardwareSerial.cpp Print.cpp Stream.cpp USBSerial.cpp wiring_analog.c wiring_digital.c wiring_time.c)\
	$(addprefix Drivers/STM32F4xx_HAL_Driver/Src/,stm32f4xx_hal.c stm32f4xx_hal_adc.c stm32f4xx_hal_cortex.c stm32f4xx_hal_dma.c stm32f4xx_hal_eth.c stm32f4xx_hal_flash.c stm32f4xx_hal_gpio.c stm32f4xx_hal_hcd.c stm32f4xx_hal_i2c.c stm32f4xx_hal_iwdg.c stm32f4xx_hal_pcd.c stm32f4xx_hal_pcd_ex.c stm32f4xx_hal_rcc.c stm32f4xx_hal_spi.c stm32f4xx_hal_tim.c stm32f4xx_hal_tim_ex.c stm32f4xx_hal_uart.c stm32f4xx_ll_usb.c)\
	$(addprefix inih/,ini.c)\
	$(addprefix Marlin/Marlin/src/,Marlin.cpp\
		$(addprefix core/,serial.cpp utility.cpp)\
		$(addprefix feature/,babystep.cpp bedlevel/abl/abl.cpp bedlevel/bedlevel.cpp safety_timer.cpp tmc_util.cpp)\
		$(addprefix gcode/,calibrate/G28.cpp eeprom/M500-M504.cpp gcode.cpp parser.cpp queue.cpp units/M82_M83.cpp\
			$(addprefix bedlevel/,abl/G29.cpp abl/M421.cpp G42.cpp M420.cpp)\
			$(addprefix config/,M200-M205.cpp M220.cpp M221.cpp M301.cpp M302.cpp M304.cpp M92.cpp)\
			$(addprefix control/,M108_M112_M410.cpp M111.cpp M120_M121.cpp M17_M18_M84.cpp M211.cpp M226.cpp M400.cpp M42.cpp M80_M81.cpp M85.cpp M86.cpp M999.cpp T.cpp)\
			$(addprefix feature/,advance/M900.cpp trinamic/M122.cpp trinamic/M569.cpp trinamic/M906.cpp)\
			$(addprefix geometry/,G92.cpp M206_M428.cpp)\
			$(addprefix host/,M110.cpp M113.cpp M114.cpp M115.cpp M118.cpp M119.cpp)\
			$(addprefix lcd/,M0_M1.cpp M117.cpp M300.cpp M73_PE.cpp)\
			$(addprefix motion/,G0_G1.cpp G2_G3.cpp G4.cpp M290.cpp)\
			$(addprefix probe/,G30.cpp M401_M402.cpp M851.cpp)\
			$(addprefix sdcard/,M20.cpp M21_M22.cpp M23.cpp M24_M25.cpp M26.cpp M27.cpp M28_M29.cpp M30.cpp M32.cpp M524.cpp M928.cpp)\
			$(addprefix stats/,M31.cpp M75-M78.cpp)\
			$(addprefix temperature/,M104_M109.cpp M105.cpp M106_M107.cpp M140_M190.cpp M155.cpp M303.cpp))\
		$(addprefix HAL/HAL_STM32_F4_F7/,HAL.cpp STM32F4/timers.cpp watchdog.cpp)\
		$(addprefix lcd/,extensible_ui/ui_api.cpp ultralcd.cpp)\
		$(addprefix libs/,buzzer.cpp nozzle.cpp stopwatch.cpp)\
		$(addprefix module/,configuration_store.cpp endstops.cpp motion.cpp planner.cpp probe.cpp stepper.cpp stepper/indirection.cpp stepper/trinamic.cpp temperature.cpp tool_change.cpp))\
	$(addprefix Middlewares/,\
		$(addprefix ST/STM32_USB_Device_Library/,\
			$(addprefix Class/,CDC/Src/usbd_cdc.c)\
			$(addprefix Core/,Src/usbd_core.c Src/usbd_ctlreq.c Src/usbd_ioreq.c))\
		$(addprefix ST/STM32_USB_Host_Library/,\
			$(addprefix Class/,MSC/Src/usbh_msc.c MSC/Src/usbh_msc_bot.c MSC/Src/usbh_msc_scsi.c)\
			$(addprefix Core/,Src/usbh_core.c Src/usbh_ctlreq.c Src/usbh_ioreq.c Src/usbh_pipes.c))\
		$(addprefix ST/Utilites/CPU/,cpu_utils.c)\
		$(addprefix Third_Party/,LwIP/system/OS/sys_arch.c\
			$(addprefix FatFs/src/,diskio.c ff.c ff_gen_drv.c option/syscall.c option/unicode.c)\
			$(addprefix FreeRTOS/Source/,CMSIS_RTOS/cmsis_os.c list.c portable/GCC/ARM_CM4F/port.c portable/MemMang/heap_4.c queue.c tasks.c)\
			$(addprefix lpng/,png.c pngerror.c pngget.c pngmem.c pngread.c pngrio.c pngrtran.c pngrutil.c pngset.c pngtrans.c)\
			$(addprefix LwIP/src/,api/netifapi.c api/tcpip.c netif/ethernet.c\
				$(addprefix core/,def.c init.c ip.c ipv4/dhcp.c ipv4/etharp.c ipv4/icmp.c ipv4/ip4.c ipv4/ip4_addr.c ipv4/ip4_frag.c mem.c memp.c netif.c pbuf.c tcp.c tcp_in.c tcp_out.c timeouts.c udp.c))\
			$(addprefix zlib/,adler32.c crc32.c inffast.c inflate.c inftrees.c zutil.c)))\
	$(addprefix TMCStepper/src/source/,DRV_STATUS.cpp GCONF.cpp CHOPCONF.cpp IHOLD_IRUN.cpp PWMCONF.cpp TMC2208Stepper.cpp TMC2209Stepper.cpp TMCStepper.cpp))\
$(addprefix src/,ethernetif.c fatfs.c freertos.c freertos_openocd.c lwip.c main_MINI.c marlin_stubs/M876.cpp marlin_stubs/pause/G27.cpp marlin_stubs/pause/M125.cpp marlin_stubs/pause/M600.cpp marlin_stubs/pause/M603.cpp marlin_stubs/pause/M701_M702.cpp marlin_stubs/pause/pause.cpp stm32f4xx_hal_msp.c stm32f4xx_hal_timebase_tim.c stm32f4xx_it.c system_stm32f4xx_boot.c usb_device.c usb_host.c usbd_cdc_if.c usbd_conf.c usbd_desc.c usbh_conf.c usbh_diskio.c startup/startup_stm32f407xx_boot.s\
	$(addprefix common/,adc.c appmain.cpp base64_stream_decoder.cpp bsod.c client_response.cpp crc32.c dbg.c diag.c dump.c eeprom.c eeprom_loadsave.c errors.c filament_sensor.cpp gcode_file.cpp gcode_thumb_decoder.cpp hwio_a3ides_2209_02.c ini_handler.c lang.c Marlin_CardReader.cpp marlin_client.c marlin_errors.c marlin_events.c marlin_host.c marlin_server.cpp marlin_vars.c minda_broken_cable_detection.c MindaRedscreen.c print_utils.cpp putslave.c safe_state.c sim_bed.c sim_heater.cpp sim_motion.cpp sim_nozzle.c st25dv64k.c support_utils.cpp sys.cpp thread_measurement.c trinamic.cpp uartrxbuff.c uartslave.c variant8.cpp version.c w25x.c)\
	$(addprefix gui/,dialogs/Dialog_C_wrapper.cpp dialogs/DialogFactory.cpp dialogs/DialogHandler.cpp dialogs/DialogLoadUnload.cpp dialogs/DialogRadioButton.cpp dialogs/DialogStateful.cpp dialogs/IDialog.cpp dialogs/window_dlg_load_unload.c dialogs/window_dlg_popup.c dialogs/window_dlg_preheat.c dialogs/window_dlg_wait.c filament.cpp guimain.c menu_vars.cpp pngview.c resource.c screen_filebrowser.cpp screen_home.cpp screen_lan_settings.c screen_menu.c screen_menu_calibration.c screen_menu_filament.c screen_menu_fw_update.c screen_menu_info.c screen_menu_move.c screen_menu_preheat.cpp screen_menu_service.c screen_menu_settings.c screen_menu_temperature.c screen_menu_tune.cpp screen_messages.c screen_PID.cpp screen_print_preview.c screen_printing.cpp screen_printing_serial.cpp screen_qr_error.cpp screen_qr_info.cpp screen_splash.c screen_sysinf.c screen_version_info.cpp screen_watchdog.c status_footer.cpp test/screen_mesh_bed_lv.cpp test/screen_test.c test/screen_test_disp_mem.c test/screen_test_graph.c test/screen_test_gui.c test/screen_test_msgbox.c test/screen_test_temperature.cpp test/screen_test_term.c test_display.c window_file_list.c window_header.c window_temp_graph.c wizard/firstlay.c wizard/Marlin_PID_wrapper.cpp wizard/screen_wizard.c wizard/selftest.c wizard/selftest_cool.c wizard/selftest_fans_axis.c wizard/selftest_temp.c wizard/wizard.c wizard/wizard_load_unload.c wizard/wizard_progress_bar.c wizard/wizard_ui.c wizard/xyzcalib.c\
		$(addprefix Dialogs/,)\
		$(addprefix Test/,)\
		$(addprefix Wizard/,))\
	$(addprefix guiapi/src/,button_draw.c display.c display_helper.c gui.c gui_timer.c guitypes.c jogwheel.c screen.c st7789v.c term.c window.c window_frame.c window_icon.c window_list.c window_menu.c window_msgbox.c window_numb.c window_progress.c window_qr.c window_spin.c window_term.c window_text.c)\
	$(addprefix wui/,http/altcp_proxyconnect.c http/fs.c http/http_client.c http/httpd.c progress_data_wrapper.cpp wui.c wui_api.c wui_helper_funcs.c))
endif

# external definitions
SYMBOLS := $(addprefix -D,\
	__weak='__attribute__((weak))'\
	__packed='__attribute__((__packed__))'\
	STM32F407xx\
	STM32F4xx\
	HAVE_HWSERIAL2\
	STM32GENERIC\
	STM32F4\
	configUSE_NEWLIB_REENTRANT=1\
	ARDUINO=$(ARDUINO)\
	MOTHERBOARD=$(MOTHERBOARD)\
	USE_HAL_DRIVER\
	USBD_USE_CDC\
	USBCON\
	_EXTUI\
	LWIP_HTTPD_CUSTOM_FILES=0\
	MARLIN_DISABLE_INFINITE_LOOP\
	PRINTER=$(PRINTER)\
	PRINTER_TYPE=$(PRINTER_TYPE)\
	FW_BUILD_NUMBER=$(FW_BUILD_NUMBER)\
	FW_VERSION=$(FW_VERSION)\
	FW_VERSION_FULL=$(FW_VERSION_FULL)\
	FW_VERSION_SUFFIX=$(FW_VERSION_SUFFIX)\
	FW_VERSION_SUFFIX_SHORT=$(FW_VERSION_SUFFIX)\
	HAS_GUI=1\
	HTTPD_FSDATA_FILE="\"fsdata_wui_local.c\""\
	INIT_TRINAMIC_FROM_MARLIN_ONLY=0\
	BUDDY_ENABLE_WUI\
)

# include directories
INCLUDES := $(addprefix -I./,\
	include $(addprefix include/, freertos marlin stm32f4_hal usb_device usb_host)\
	$(addprefix lib/Drivers/STM32F4xx_HAL_Driver/,Inc Inc/Legacy)\
	$(addprefix lib/Drivers/CMSIS/, Device/ST/STM32F4xx/Include Include)\
	$(addprefix lib/Middlewares/Third_Party/, FatFs/src\
		$(addprefix FreeRTOS/Source/,include CMSIS_RTOS portable/GCC/ARM_CM4F))\
	$(addprefix lib/Middlewares/ST/STM32_USB_Device_Library/, Core/Inc Class/CDC/Inc)\
	$(addprefix lib/Middlewares/ST/STM32_USB_Host_Library/, Core/Inc Class/MSC/Inc)\
	$(addprefix lib/Arduino_Core_A3ides/, cores/arduino cores/arduino/stm32 variants/A3IDES_F407VET6_2209)\
	lib/LiquidCrystal_I2C\
	lib/TMCStepper/src\
	$(addprefix lib/Middlewares/Third_Party/,zlib lpng)\
	$(addprefix src/, gui gui/Dialogs guiapi/include wui common wui/resources)\
	lib/Marlin/Marlin\
	lib/Marlin/Marlin/src/gcode/lcd\
	$(addprefix lib/Middlewares/Third_Party/LwIP/,system src/apps/httpd src/include\
		$(addprefix src/include/, netif/ppp lwip lwip/apps lwip/priv lwip/prot netif posix))\
	lib/inih\
	lib/QR\
	lib/CRC\
	lib/jsmn\
)

# common flags
CMNFLAGS := -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -ffunction-sections -fdata-sections

# compiler flags
ASMFLAGS := $(CMNFLAGS) -Wa,--no-warn -x assembler-with-cpp
GCCFLAGS := $(CMNFLAGS) $(INCLUDES) -fstack-usage -Wall
GPPFLAGS := $(CMNFLAGS) $(INCLUDES) -fno-exceptions -fstack-usage -Wall -fno-threadsafe-statics

# debug/release configuration (optimalization and debug info flags + _DEBUG symbol)
ifneq (,$(findstring Debug, $(BUILD_CONFIGURATION)))
	SYMBOLS += -D_DEBUG
	ASMFLAGS += -g $(SYMBOLS)
	GCCFLAGS += -O0 -g $(SYMBOLS)
	GPPFLAGS += -O0 -g $(SYMBOLS)
else
	GCCFLAGS += -Os -g $(SYMBOLS)
	GPPFLAGS += -Os -g $(SYMBOLS)
endif

# boot/noboot configuration - linker script
ifneq (,$(findstring Boot, $(BUILD_CONFIGURATION)))
	LDSCRIPT := "./src/STM32F407VG_FLASH_boot.ld"
else
	LDSCRIPT := "./src/STM32F407VG_FLASH.ld"
endif

# linker flags
LDFLAGS  := $(CMNFLAGS) -T$(LDSCRIPT) -specs=nosys.specs -static -Wl,-cref,-u,Reset_Handler\
	-Wl,-Map="$(OUT)/$(PROJECT).map" -Wl,--gc-sections -Wl,--defsym=malloc_getpagesize_P=0x1000\
	-Wl,--start-group -lc -lm -lstdc++ -lsupc++ -Wl,--end-group\
	-specs=nano.specs -u _printf_float

# list of all directories
ALLDIR := $(addprefix $(OUT)/,$(sort $(subst / , ,$(dir $(ALLSRC)) )))

# lists of all assembler, C and C++ source files
ASMSRC := $(filter %.s, $(ALLSRC))
GCCSRC := $(filter %.c, $(ALLSRC))
GPPSRC := $(filter %.cpp, $(ALLSRC))

# lists of all assembler, C and C++ object files
ASMOBJ := $(addprefix $(OUT)/,$(ASMSRC:.s=.o))
GCCOBJ := $(addprefix $(OUT)/,$(GCCSRC:.c=.o))
GPPOBJ := $(addprefix $(OUT)/,$(GPPSRC:.cpp=.o))

build:
ifeq (,$(filter-out $(MAKE_CONFIGURATIONS), $(BUILD_CONFIGURATION)))
	@make -s $(OUTELF) $(OUTHEX) $(OUTBIN)
else
	@make -s cmake
endif

$(OUTDIR):
	@echo creating output directory tree
	@$(SHELL_MKDIR) $(subst /,$(PATH_SEPARATOR),$(OUT))
	@$(SHELL_MKDIR) $(subst /,$(PATH_SEPARATOR),$(ALLDIR))
	@echo $(ALLDIR) >$(OUTDIR)

$(OUT)/%.o: %.s $(OUTDIR)
	@echo compiling $<
	@$(GCC) -c $(ASMFLAGS) -o $@ $<

$(OUT)/%.o: %.c $(OUTDIR)
	@echo compiling $<
	@$(GCC) -c $(GCCFLAGS) -o $@ $<

$(OUT)/%.o: %.cpp $(OUTDIR)
	@echo compiling $<
	@$(GPP) -c $< $(GPPFLAGS) -o $@

$(OUTELF): $(ASMOBJ) $(GCCOBJ) $(GPPOBJ)
	@echo linking $@
	@$(file > $(OUT)/.objlist,$(ASMOBJ) $(GCCOBJ) $(GPPOBJ))
	@$(GPP) -o $(OUTELF) @$(OUT)/.objlist $(LDFLAGS)

$(OUTHEX): $(OUTELF)
	@echo generating hex file $@
	@$(OBJCPY) -O ihex $< $@

$(OUTBIN): $(OUTELF)
	@echo generating bin file $@
	@$(OBJCPY) -O binary $< $@

clean:
	@echo removing output files $(OUT)
ifneq ("$(wildcard $(OUT))","")
	@$(SHELL_RMDIR) $(subst /,$(PATH_SEPARATOR),$(OUT))
endif

.PHONY: all build clean build_all clean_all cmake

clean_all:
	@echo removing output files of ALL configurations
	@$(foreach cfg,$(ALL_CONFIGURATIONS),make -s clean BUILD_CONFIGURATION=$(cfg) $(SHELL_CMDSEP))

build_all:
	@echo building ALL configurations
	$(foreach cfg,$(MAKE_CONFIGURATIONS),make -s build BUILD_CONFIGURATION=$(cfg) $(SHELL_CMDSEP))

include make/CMake.mk
include make/Debug.mk
include make/Eclipse.mk
#include make/Atollic.mk
#include make/CubeIDE.mk
#include make/VSCode.mk
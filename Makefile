#-----------------------------------------------------------------------------------------------------------------------
# Makefile to compile and link Prusa-Firmware-Buddy
PROJECT := Prusa-Firmware-Buddy
# default config release boot
CONFIG  ?= Release_Boot
# default printer MINI
PRINTER ?= 2
# default firmware buildnumber 1
FW_BUILDNR ?= 1
# default firmware version 4.0.2
FW_VERSION ?= 402
# default arduino version 1.87
ARDUINO     := 187
# default matherboard A3IDES_2209_02
MOTHERBOARD := 1823

# target platform prefix
PREFIX ?= arm-atollic-eabi

# output folder (output directory tree will be automaticaly created)
OUT := build/$(CONFIG)

# file path separator for DIR_RM and DIR_MK (default is unix '/', for windows use - '\\')
DIRSEP ?= /
# shell command for removing directories (default is unix, for windows use - 'RMDIR /S /Q')
DIR_RM ?= rm -rvf
# shell command for creating directories (default is unix, for windows use - 'MKDIR')
DIR_MK ?= mkdir -p

# gcc, g++ and objcopy tool
GCC    := $(PREFIX)-gcc
GPP    := $(PREFIX)-g++
OBJCPY := $(PREFIX)-objcopy

# output files
OUTDIR := $(OUT)/$(PROJECT).dir
OUTELF := $(OUT)/$(PROJECT).elf
OUTHEX := $(OUT)/$(PROJECT).hex
OUTBIN := $(OUT)/$(PROJECT).bin

# all source
ALLSRC := \
$(addprefix lib/Arduino_Core_A3ides/cores/arduino/,HardwareSerial.cpp Print.cpp SPI.cpp Stream.cpp USBSerial.cpp\
	Wire.cpp wiring_analog.c wiring_digital.c wiring_time.c WMath.cpp)\
lib/LiquidCrystal_I2C/LiquidCrystal_I2C.cpp \
$(addprefix lib/TMCStepper/src/source/,DRV_STATUS.cpp GCONF.cpp CHOPCONF.cpp IHOLD_IRUN.cpp PWMCONF.cpp\
	SERIAL_SWITCH.cpp TMC2208Stepper.cpp TMC2209Stepper.cpp TMCStepper.cpp)\
lib/Arduino_Core_A3ides/variants/A3IDES_F407VET6_2209/variant.cpp \
$(addprefix src/common/,adc.c appmain.cpp base64_stream_decoder.cpp bsod.c dbg.c diag.c eeprom.c filament_sensor.c\
	gcode_file.cpp gcode_thumb_decoder.cpp hwio_a3ides_2209_02.c Marlin_CardReader.cpp marlin_client.c\
	Marlin_eeprom.cpp marlin_errors.c marlin_events.c marlin_host.c marlin_server.cpp marlin_vars.c new_eeprom.cpp\
	print_utils.cpp putslave.c safe_state.c sim_bed.c sim_heater.cpp sim_motion.cpp sim_nozzle.c st25dv64k.c sys.c\
	thread_measurement.c trinamic.cpp uartrxbuff.c uartslave.c variant8.c version.c w25x.c)\
$(addprefix lib/Drivers/STM32F4xx_HAL_Driver/Src/,stm32f4xx_hal.c stm32f4xx_hal_adc.c stm32f4xx_hal_adc_ex.c\
	stm32f4xx_hal_cortex.c stm32f4xx_hal_dma.c stm32f4xx_hal_dma_ex.c stm32f4xx_hal_eth.c stm32f4xx_hal_flash.c\
	stm32f4xx_hal_flash_ex.c stm32f4xx_hal_flash_ramfunc.c stm32f4xx_hal_gpio.c stm32f4xx_hal_hcd.c stm32f4xx_hal_i2c.c\
	stm32f4xx_hal_i2c_ex.c stm32f4xx_hal_iwdg.c stm32f4xx_hal_pcd.c stm32f4xx_hal_pcd_ex.c stm32f4xx_hal_pwr.c\
	stm32f4xx_hal_pwr_ex.c stm32f4xx_hal_rcc.c stm32f4xx_hal_rcc_ex.c stm32f4xx_hal_spi.c stm32f4xx_hal_tim.c\
	stm32f4xx_hal_tim_ex.c stm32f4xx_hal_uart.c stm32f4xx_ll_usb.c)\
$(addprefix src/gui/Dialogs/,window_dlg_change.c window_dlg_load.c window_dlg_statemachine.c\
	window_dlg_loadunload_shared.c window_dlg_popup.c window_dlg_preheat.c window_dlg_purge.c window_dlg_unload.c\
	window_dlg_wait.c)\
$(addprefix src/gui/,filament.cpp guimain.c menu_vars.cpp pngview.c resource.c screen_filebrowser.cpp screen_home.cpp\
	screen_lan_settings.c screen_menu.c screen_menu_calibration.c screen_menu_filament.c screen_menu_fw_update.c\
	screen_menu_info.c screen_menu_move.c screen_menu_preheat.cpp screen_menu_service.c screen_menu_settings.c\
	screen_menu_temperature.c screen_menu_tune.cpp screen_messages.c screen_PID.cpp screen_print_preview.c\
	screen_printing.cpp screen_splash.c screen_sysinf.c screen_version_info.cpp screen_watchdog.c status_footer.cpp\
	test_display.c window_file_list.c window_header.c window_logo.c window_temp_graph.c\
	$(addprefix Test/,screen_mesh_bed_lv.cpp screen_test.c screen_test_disp_mem.c screen_test_graph.c screen_test_gui.c\
		screen_test_msgbox.c screen_test_temperature.cpp screen_test_term.c)\
	$(addprefix Wizard/,firstlay.c Marlin_PID_wrapper.cpp Marlin_queue_wrapper.cpp screen_wizard.c selftest.c\
		selftest_cool.c selftest_fans_axis.c selftest_home.c selftest_temp.c wizard.c wizard_load_unload.c\
		wizard_progress_bar.c wizard_ui.c xyzcalib.c))\
$(addprefix src/guiapi/src/,button_draw.c display.c display_helper.c gui.c gui_timer.c guitypes.c jogwheel.c screen.c\
	st7789v.c term.c window.c window_frame.c window_icon.c window_list.c window_menu.c window_msgbox.c window_numb.c\
	window_progress.c window_spin.c window_term.c window_text.c)\
$(addprefix lib/Marlin/Marlin/src/,Marlin.cpp\
	$(addprefix core/,multi_language.cpp serial.cpp utility.cpp)\
	$(addprefix feature/,babystep.cpp backlash.cpp binary_protocol.cpp joystick.cpp pause.cpp runout.cpp\
		safety_timer.cpp spindle_laser.cpp tmc_util.cpp touch/xpt2046.cpp\
		$(addprefix bedlevel/,abl/abl.cpp bedlevel.cpp mbl/mesh_bed_leveling.cpp ubl/ubl_G29.cpp))\
	$(addprefix gcode/,calibrate/G28.cpp eeprom/M500-M504.cpp gcode.cpp parser.cpp queue.cpp units/M82_M83.cpp\
		$(addprefix bedlevel/,abl/G29.cpp abl/M421.cpp G42.cpp M420.cpp mbl/G29.cpp)\
		$(addprefix config/,M200-M205.cpp M220.cpp M221.cpp M301.cpp M302.cpp M304.cpp M305.cpp M575.cpp M92.cpp)\
		$(addprefix control/,M108_M112_M410.cpp M111.cpp M120_M121.cpp M17_M18_M84.cpp M211.cpp M226.cpp M400.cpp\
			M42.cpp M7-M9.cpp M80_M81.cpp M85.cpp M86.cpp M999.cpp T.cpp)\
		$(addprefix feature/,advance/M900.cpp runout/M412.cpp\
			$(addprefix pause/,G27.cpp M125.cpp M600.cpp M603.cpp M701_M702.cpp)\
			$(addprefix trinamic/,M122.cpp M569.cpp M906.cpp M911-M914.cpp))\
		$(addprefix geometry/,G92.cpp M206_M428.cpp)\
		$(addprefix host/,M110.cpp M113.cpp M114.cpp M115.cpp M118.cpp M119.cpp M16.cpp M876.cpp)\
		$(addprefix lcd/,M0_M1.cpp M117.cpp M145.cpp M300.cpp M73_PE.cpp)\
		$(addprefix motion/,G0_G1.cpp G2_G3.cpp G4.cpp M290.cpp)\
		$(addprefix probe/,G30.cpp M401_M402.cpp M851.cpp)\
		$(addprefix sdcard/,M20.cpp M21_M22.cpp M23.cpp M24_M25.cpp M26.cpp M27.cpp M28_M29.cpp M30.cpp M32.cpp\
			M524.cpp M928.cpp)\
		$(addprefix stats/,M31.cpp M75-M78.cpp)\
		$(addprefix temperature/,M104_M109.cpp M105.cpp M106_M107.cpp M140_M190.cpp M155.cpp M303.cpp))\
	$(addprefix HAL/HAL_STM32_F4_F7/,eeprom_emul.cpp EmulatedEeprom.cpp HAL.cpp HAL_SPI.cpp persistent_store_eeprom.cpp\
		Servo.cpp STM32F4/timers.cpp STM32F7/timers.cpp STM32F7/TMC2660.cpp watchdog.cpp)\
	$(addprefix HAL/shared/backtrace/,backtrace.cpp unwarm.cpp unwarm_arm.cpp unwarm_thumb.cpp unwarmbytab.cpp\
		unwarmmem.cpp unwinder.cpp unwmemaccess.cpp)\
	$(addprefix HAL/shared/,eeprom_spi.cpp HAL_spi_L6470.cpp persistent_store_api.cpp)\
	$(addprefix lcd/,extensible_ui/ui_api.cpp ultralcd.cpp)\
	$(addprefix libs/,buzzer.cpp crc16.cpp heatshrink/heatshrink_decoder.cpp least_squares_fit.cpp nozzle.cpp\
		numtostr.cpp stopwatch.cpp vector_3.cpp)\
	$(addprefix module/,configuration_store.cpp delta.cpp endstops.cpp motion.cpp planner.cpp planner_bezier.cpp\
		printcounter.cpp probe.cpp scara.cpp servo.cpp stepper.cpp temperature.cpp tool_change.cpp\
		$(addprefix stepper/,indirection.cpp L6470.cpp TMC26X.cpp trinamic.cpp)))\
$(addprefix lib/Middlewares/,\
	$(addprefix ST/STM32_USB_Device_Library/,Class/CDC/Src/usbd_cdc.c\
		$(addprefix Core/Src/,usbd_core.c usbd_ctlreq.c usbd_ioreq.c))\
	$(addprefix ST/STM32_USB_Host_Library/,\
		$(addprefix Class/MSC/Src/,usbh_msc.c usbh_msc_bot.c usbh_msc_scsi.c)\
		$(addprefix Core/Src/,usbh_core.c usbh_ctlreq.c usbh_ioreq.c usbh_pipes.c))\
	ST/Utilites/CPU/cpu_utils.c\
	$(addprefix Third_Party/FatFs/src/,diskio.c ff.c ff_gen_drv.c option/syscall.c option/unicode.c)\
	$(addprefix Third_Party/FreeRTOS/Source/,CMSIS_RTOS/cmsis_os.c croutine.c event_groups.c list.c\
		portable/GCC/ARM_CM4F/port.c portable/MemMang/heap_4.c queue.c tasks.c timers.c))\
$(addprefix lib/Middlewares/Third_Party/lpng/,png.c pngerror.c pngget.c pngmem.c pngpread.c pngread.c pngrio.c\
	pngrtran.c pngrutil.c pngset.c pngtrans.c pngwio.c pngwrite.c pngwtran.c pngwutil.c)\
$(addprefix lib/Middlewares/Third_Party/LwIP/,\
	$(addprefix src/api/,api_lib.c api_msg.c err.c netbuf.c netdb.c netifapi.c sockets.c tcpip.c)\
	$(addprefix src/apps/,httpd/fs.c httpd/httpd.c mqtt/mqtt.c)\
	$(addprefix src/core/,def.c dns.c inet_chksum.c init.c ip.c\
		$(addprefix ipv4/, autoip.c dhcp.c etharp.c icmp.c igmp.c ip4.c ip4_addr.c ip4_frag.c)\
		$(addprefix ipv6/, dhcp6.c ethip6.c icmp6.c inet6.c ip6.c ip6_addr.c ip6_frag.c mld6.c nd6.c)\
		mem.c memp.c netif.c pbuf.c raw.c stats.c sys.c tcp.c tcp_in.c tcp_out.c timeouts.c udp.c)\
	$(addprefix src/netif/,ethernet.c lowpan6.c slipif.c\
		$(addprefix ppp/,auth.c ccp.c demand.c eap.c ecp.c eui64.c fsm.c chap_ms.c chap-md5.c chap-new.c ipcp.c\
			ipv6cp.c lcp.c magic.c mppe.c multilink.c ppp.c pppapi.c pppcrypt.c pppoe.c pppol2tp.c pppos.c upap.c\
			utils.c vj.c))\
	system/OS/sys_arch.c)\
$(addprefix lib/Middlewares/Third_Party/zlib/,adler32.c compress.c crc32.c deflate.c gzclose.c gzlib.c gzread.c\
	gzwrite.c infback.c inffast.c inflate.c inftrees.c trees.c uncompr.c zutil.c)\
$(addprefix src/,ethernetif.c fatfs.c freertos.c freertos_openocd.c fs_custom.c lwip.c main.c stm32f4xx_hal_msp.c\
	stm32f4xx_hal_timebase_tim.c stm32f4xx_it.c system_stm32f4xx_boot.c usb_device.c usb_host.c usbd_cdc_if.c\
	usbd_conf.c usbd_desc.c usbh_conf.c usbh_diskio.c startup/startup_stm32f407xx_boot.s)\
$(addprefix src/wui/,connect.cpp connection.cpp http_states.c lwsapi.cpp)\
$(addprefix lib/inih/,ini.c)

# external definitions
SYMBOLS := \
	-D__weak='__attribute__((weak))' \
	-D__packed='__attribute__((__packed__))' \
	-DSTM32F407xx \
	-DSTM32F4xx \
	-DHAVE_HWSERIAL2 \
	-DSTM32GENERIC \
	-DSTM32F4 \
	-DARDUINO=$(ARDUINO) \
	-DMOTHERBOARD=$(MOTHERBOARD) \
	-DUSE_HAL_DRIVER \
	-DUSBD_USE_CDC \
	-DUSBCON \
	-D_EXTUI \
	-DLWIP_HTTPD_CUSTOM_FILES=1 \
	-DMARLIN_DISABLE_INFINITE_LOOP \
	-DPRINTER_TYPE=$(PRINTER) \
	-DFW_BUILDNR=$(FW_BUILDNR) \
	-DFW_VERSION=$(FW_VERSION) \
	-D_DEBUG

INCLUDES := \
	-I./include \
	-I./include/freertos \
	-I./include/marlin \
	-I./include/stm32f4_hal \
	-I./include/usb_device \
	-I./include/usb_host \
	-I./lib/Drivers/STM32F4xx_HAL_Driver/Inc \
	-I./lib/Drivers/STM32F4xx_HAL_Driver/Inc/Legacy \
	-I./lib/Drivers/CMSIS/Device/ST/STM32F4xx/Include \
	-I./lib/Drivers/CMSIS/Include \
	-I./lib/Middlewares/Third_Party/FatFs/src \
	-I./lib/Middlewares/Third_Party/FreeRTOS/Source/include \
	-I./lib/Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS \
	-I./lib/Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F \
	-I./lib/Middlewares/ST/STM32_USB_Device_Library/Core/Inc \
	-I./lib/Middlewares/ST/STM32_USB_Device_Library/Class/CDC/Inc \
	-I./lib/Middlewares/ST/STM32_USB_Host_Library/Core/Inc \
	-I./lib/Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc \
	-I./lib/Arduino_Core_A3ides/cores/arduino \
	-I./lib/Arduino_Core_A3ides/cores/arduino/stm32 \
	-I./lib/Arduino_Core_A3ides/variants/A3IDES_F407VET6_2209 \
	-I./lib/LiquidCrystal_I2C \
	-I./lib/TMCStepper/src \
	-I./lib/Middlewares/Third_Party/zlib \
	-I./lib/Middlewares/Third_Party/lpng \
	-I./src/gui \
	-I./src/gui/Dialogs \
	-I./src/guiapi/include \
	-I./src/wui \
	-I./src/common \
	-I./lib/Marlin/Marlin \
	-I./lib/Middlewares/Third_Party/LwIP/src/include \
	-I./lib/Middlewares/Third_Party/LwIP/system \
	-I./lib/Middlewares/Third_Party/LwIP/src/include/netif/ppp \
	-I./lib/Middlewares/Third_Party/LwIP/src/apps/httpd \
	-I./lib/Middlewares/Third_Party/LwIP/src/include/lwip \
	-I./lib/Middlewares/Third_Party/LwIP/src/include/lwip/apps \
	-I./lib/Middlewares/Third_Party/LwIP/src/include/lwip/priv \
	-I./lib/Middlewares/Third_Party/LwIP/src/include/lwip/prot \
	-I./lib/Middlewares/Third_Party/LwIP/src/include/netif \
	-I./lib/Middlewares/Third_Party/LwIP/src/include/posix \
	-I./lib/inih

# common flags
CMNFLAGS := -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -ffunction-sections -fdata-sections

# compiler flags
ASMFLAGS := $(CMNFLAGS) $(SYMBOLS) -Wa,--no-warn -x assembler-with-cpp
GCCFLAGS := $(CMNFLAGS) -std=gnu11 $(SYMBOLS) $(INCLUDES) -fstack-usage -Wall
GPPFLAGS := $(CMNFLAGS) -std=gnu++11 $(SYMBOLS) $(INCLUDES) -fno-exceptions -fstack-usage -Wall -fno-threadsafe-statics

# debug/release configuration (optimalization and debug info flags + _DEBUG symbol)
ifneq (,$(findstring Debug, $(CONFIG)))
#	SYMBOLS  += -D_DEBUG
	ASMFLAGS += -g
	GCCFLAGS += -Og -g
	GPPFLAGS += -Og -g
else
	GCCFLAGS += -Os
	GPPFLAGS += -Os
endif

# boot/noboot configuration - linker script
ifneq (,$(findstring Boot, $(CONFIG)))
	LDSCRIPT := "./src/STM32F407VG_FLASH_boot.ld"
else
	LDSCRIPT := "./src/STM32F407VG_FLASH.ld"
endif

# linker flags
LDFLAGS  := $(CMNFLAGS) -T$(LDSCRIPT) -specs=nosys.specs -static -Wl,-cref,-u,Reset_Handler\
	-Wl,-Map="$(OUT)/$(PROJECT).map" -Wl,--gc-sections -Wl,--defsym=malloc_getpagesize_P=0x1000\
	-Wl,--start-group -lc -lm -lstdc++ -lsupc++ -Wl,--end-group

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


all: $(OUTELF) $(OUTHEX) $(OUTBIN)


$(OUTDIR):
	@echo creating output directory tree
	@$(DIR_MK) $(subst /,$(DIRSEP),$(OUT))
	@$(DIR_MK) $(subst /,$(DIRSEP),$(ALLDIR))
	@echo >$(OUTDIR)

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
	@echo removing output files
ifneq ("$(wildcard $(OUT))","")
	@$(DIR_RM) $(subst /,$(DIRSEP),$(OUT))
endif

.PHONY: all clean

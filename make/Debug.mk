#-----------------------------------------------------------------------------------------------------------------------
# Debug part of Makefile

include make/Multiline.mk

#SRCFILE_TO_EXCLUDE := src/main_MINI.c
OBJFILE_TO_EXCLUDE := $(subst .c,.o,$(subst .cpp,.o,$(SRCFILE_TO_EXCLUDE)))
OBJLIST2 := $(filter-out $(OUT)/$(OBJFILE_TO_EXCLUDE),$(ASMOBJ) $(GCCOBJ) $(GPPOBJ))


print_ENVVARS:
	@echo BUILD_CONFIGURATION=$(BUILD_CONFIGURATION)
	@echo TOOLCHAIN_PREFIX=$(TOOLCHAIN_PREFIX)
	@echo PATH_SEPARATOR=$(PATH_SEPARATOR)
	@echo SHELL_RMDIR=$(SHELL_RMDIR)
	@echo SHELL_MKDIR=$(SHELL_MKDIR)
	@echo SHELL_CAT=$(SHELL_CAT)

print_INCLUDES:
	@echo INCLUDES for configuration $(BUILD_CONFIGURATION)
	$(file > $(OUT)/includes.txt,$(subst $(SPACE),$(NEWLINE),$(subst -I./,,$(INCLUDES))))
	@$(SHELL_CAT) $(subst /,$(PATH_SEPARATOR),$(OUT)/includes.txt)

print_SYMBOLS:
	@echo SYMBOLS for configuration $(BUILD_CONFIGURATION)
	$(file > $(OUT)/symbols.txt,$(subst $(SPACE),$(NEWLINE),$(subst -D,,$(SYMBOLS))))
	@$(SHELL_CAT) $(subst /,$(PATH_SEPARATOR),$(OUT)/symbols.txt)

print_ALLSRC:
	@echo ALLSRC for configuration $(BUILD_CONFIGURATION)
	$(file > $(OUT)/allsrc.txt,$(subst $(SPACE),$(NEWLINE),$(ALLSRC)))
	@$(SHELL_CAT) $(subst /,$(PATH_SEPARATOR),$(OUT)/allsrc.txt)

test:
#	@echo TEST for configuration $(BUILD_CONFIGURATION)
#	@echo SRCFILE=$(SRCFILE_TO_EXCLUDE)
#	@echo OBJFILE=$(OBJFILE_TO_EXCLUDE)
#	@echo OBJLIST=$(OBJLIST2)
	@$(file > $(OUT)/.objlist_test,$(OBJLIST2))
	@$(GPP) -o $(OUT)/test.elf @$(OUT)/.objlist_test $(LDFLAGS)

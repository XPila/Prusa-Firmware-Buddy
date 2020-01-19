#-----------------------------------------------------------------------------------------------------------------------
# Debug part of Makefile

print_ENVVARS:
	@echo BUILD_CONFIGURATION=$(BUILD_CONFIGURATION)
	@echo TOOLCHAIN_PREFIX=$(TOOLCHAIN_PREFIX)
	@echo PATH_SEPARATOR=$(PATH_SEPARATOR)
	@echo SHELL_RMDIR=$(SHELL_RMDIR)
	@echo SHELL_MKDIR=$(SHELL_MKDIR)

print_INCLUDES:
	@echo $(subst -I./,,$(INCLUDES))

print_SYMBOLS:
	@echo $(subst -D,,$(SYMBOLS))

print_ALLSRC:
	@echo $(ALLSRC)

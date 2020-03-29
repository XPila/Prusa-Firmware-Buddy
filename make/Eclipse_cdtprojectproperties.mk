#-----------------------------------------------------------------------------------------------------------------------
# Eclipse CDT project properies xml file generator

# generate eclipse cdtprojectproperties
eclipse_cdtprojectproperties:
	@echo generting eclipse cdtprojectproperties xml file
	$(file > $(OUT)/cdtprojectproperties.xml,$(eclipse_xml_cdtprojectproperties))
#	@$(SHELL_CAT) $(subst /,$(PATH_SEPARATOR),$(OUT)/cdtprojectproperties.xml)

include make/Multiline.mk

# INCLUDES formated to xml
eclipse_xml_INCLUDES := $(subst -I./,,$(INCLUDES))
eclipse_xml_INCLUDES := $(patsubst %,<includepath>%</includepath>,$(eclipse_xml_INCLUDES))
eclipse_xml_INCLUDES := $(subst $(SPACE),$(NEWLINE),$(eclipse_xml_INCLUDES))

# SYMBOLS formated to xml
eclipse_xml_SYMBOLS := $(subst -D,,$(SYMBOLS))
eclipse_xml_SYMBOLS := $(foreach sym,$(eclipse_xml_SYMBOLS),$(if $(findstring =,$(sym)),$(sym),$(sym)=))
eclipse_xml_SYMBOLS := $(patsubst %,<macro><name>%</value></macro>,$(eclipse_xml_SYMBOLS))
eclipse_xml_SYMBOLS := $(subst =,</name><value>,$(eclipse_xml_SYMBOLS))
eclipse_xml_SYMBOLS := $(subst <value></value>,<value/>,$(eclipse_xml_SYMBOLS))
eclipse_xml_SYMBOLS := $(subst $(SPACE),$(NEWLINE),$(eclipse_xml_SYMBOLS))

# cdtprojectproperties
define eclipse_xml_cdtprojectproperties
<?xml version="1.0" encoding="UTF-8"?>
<cdtprojectproperties>
	<section name="org.eclipse.cdt.internal.ui.wizards.settingswizards.IncludePaths">
		<language name="S,s,asm">
		</language>
		<language name="C Source File">
$(eclipse_xml_INCLUDES)
		</language>
		<language name="C++ Source File">
$(eclipse_xml_INCLUDES)
		</language>
		<language name="Object File">
		</language>
	</section>
	<section name="org.eclipse.cdt.internal.ui.wizards.settingswizards.Macros">
		<language name="S,s,asm">
$(eclipse_xml_SYMBOLS)
		</language>
		<language name="C Source File">
$(eclipse_xml_SYMBOLS)
		</language>
		<language name="C++ Source File">
$(eclipse_xml_SYMBOLS)
		</language>
		<language name="Object File">
		</language>
	</section>
</cdtprojectproperties>
endef

# space constant - for generating multiline output
SPACE :=
SPACE +=

# newline constant - for generating multiline output
define NEWLINE


endef

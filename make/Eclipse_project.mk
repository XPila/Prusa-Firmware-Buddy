#-----------------------------------------------------------------------------------------------------------------------
# Eclipse .project xml file generator

# generate eclipse project file ".project"
eclipse_project:
	@echo generting eclipse .project xml file
	$(file > make/project.xml,$(eclipse_xml_project))


# project
define eclipse_xml_project
<?xml version="1.0" encoding="UTF-8"?>
<projectDescription>
	<name>Prusa-Firmware-Buddy_Make</name>
	<comment></comment>
	<projects>
	</projects>
	<buildSpec>
		<buildCommand>
			<name>org.eclipse.cdt.managedbuilder.core.genmakebuilder</name>
			<triggers>clean,full,incremental,</triggers>
			<arguments>
			</arguments>
		</buildCommand>
		<buildCommand>
			<name>org.eclipse.cdt.managedbuilder.core.ScannerConfigBuilder</name>
			<triggers>full,incremental,</triggers>
			<arguments>
			</arguments>
		</buildCommand>
	</buildSpec>
	<natures>
		<nature>org.eclipse.cdt.core.cnature</nature>
		<nature>org.eclipse.cdt.core.ccnature</nature>
		<nature>org.eclipse.cdt.managedbuilder.core.managedBuildNature</nature>
		<nature>org.eclipse.cdt.managedbuilder.core.ScannerConfigNature</nature>
	</natures>
	<filteredResources>
		<filter>
			<id>1</id>
			<name></name>
			<type>10</type>
			<matcher>
				<id>org.eclipse.ui.ide.multiFilter</id>
				<arguments>1.0-name-matches-false-true-build|cmake|.dependencies|.git|.vscode</arguments>
			</matcher>
		</filter>
	</filteredResources>
</projectDescription>
endef

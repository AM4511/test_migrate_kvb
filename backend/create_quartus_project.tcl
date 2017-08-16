# ##################################################################################
# File         : create_quartus_project.tcl
# Description  : TCL script used to create the KVB fpga project. 
#
# Example in the Quartus TCL console:
#
# tcl> source "$::env(KVB)/backend/create_quartus_project.tcl"
#
# ##################################################################################

# Load Quartus Prime Tcl Project package
package require ::quartus::project
set me [info script]
puts "Running ${me}"


###################################################################################
# Define the builID using the Unix epoch (time in secondes since midnight 1/1/1970)
###################################################################################
set BUILDID [clock seconds]
set BUILD_TIME  [clock format ${BUILDID} -format "%Y-%m-%d  %H:%M:%S"]
puts "BUILD_ID =  $BUILDID (${BUILD_TIME})"


global ROOT_PATH
 if { [info exists ::env(KVB) ] } {
    # Set the ROOT folder path from a Windows environment variable
    set ROOT_PATH $::env(KVB)
	puts "ROOT_PATH ::env(KVB) -> $ROOT_PATH"
 } else {
    # Set the ROOT folder path from an Hardcoded path
    set ROOT_PATH "D:/work/cpuskl"
	puts "ROOT_PATH -> $ROOT_PATH"
}
set FPGA_NAME        "kvb"
set REVMAJOR         "1"
set REVMINOR         "1"
set REVISION         "v${REVMAJOR}_${REVMINOR}"
set PROJECT_NAME     "${FPGA_NAME}_${REVISION}"
set QUARTUS_VERSION   "quartus17.0"
set QSYS_SYSTEM_NAME "${FPGA_NAME}_system"
set REVISION_NAME    "${PROJECT_NAME}_build${BUILDID}"


########################################################################################
# Directory structure
########################################################################################
set HDL_PATH          "${ROOT_PATH}/design"
set BACKEND_PATH      "${ROOT_PATH}/backend"
set IPCORE_LIB_PATH   "${ROOT_PATH}/ipcores/${QUARTUS_VERSION}"
set WORK_PATH         "${ROOT_PATH}/quartus/${QUARTUS_VERSION}/${PROJECT_NAME}"
set TCL_PATH          "${ROOT_PATH}/util/tcl"
set FIRMWARE_PATH     "${WORK_PATH}/firmwares"
set TDOM_PATH         "${BACKEND_PATH}/tdom/win64/tdom0.8.3"
set QUARTUS_HOME      $quartus(quartus_rootpath)


########################################################################################
# Script list
########################################################################################
set TCL_CREATE_PINOUT_SCRIPT_NAME   "set_pinout.tcl"
set TCL_CREATE_FILE_SET_SCRIPT_NAME "add_files.tcl"
set TCL_CREATE_QSYS_SCRIPT_NAME     "call_qsys.tcl"
set TCL_CREATE_PnPROM_SCRIPT_NAME   "PnP_ROM_Compiler.tcl"
set TCL_SET_ASSIGNMENTS_SCRIPT_NAME "set_assignment.tcl"

set make_assignments 1


########################################################################################
# Create Project Directory structure
########################################################################################
if {[file exist $WORK_PATH] == 0} {
	file mkdir ${WORK_PATH}
	file mkdir ${FIRMWARE_PATH}
}

# Change to the working directory
cd $WORK_PATH

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) $PROJECT_NAME]} {
		puts "Project $PROJECT_NAME is not open"
	}
} else {
	# Only open if not already open
	if {[project_exists $PROJECT_NAME]} {
		project_open -revision $REVISION_NAME $PROJECT_NAME
	} else {
		project_new -revision $REVISION_NAME $PROJECT_NAME
	}


    ###################################################################################
    # Create Project Directory structure
    ###################################################################################
	# Make assignments
	if {$make_assignments} {
		# Extract this script path
		set TCL_SCRIPT_PATH $BACKEND_PATH
		
		set TCL_SET_ASSIGNMENTS_SCRIPT [file join ${TCL_SCRIPT_PATH} ${TCL_SET_ASSIGNMENTS_SCRIPT_NAME}]
		source $TCL_SET_ASSIGNMENTS_SCRIPT

		set TCL_CREATE_PINOUT_SCRIPT [file join ${TCL_SCRIPT_PATH} ${TCL_CREATE_PINOUT_SCRIPT_NAME}]
		source $TCL_CREATE_PINOUT_SCRIPT

		set TCL_CREATE_FILE_SET_SCRIPT [file join ${TCL_SCRIPT_PATH} ${TCL_CREATE_FILE_SET_SCRIPT_NAME}]
		source $TCL_CREATE_FILE_SET_SCRIPT
		
		set TCL_CREATE_QSYS_SCRIPT [file join ${TCL_SCRIPT_PATH} ${QUARTUS_VERSION} ${TCL_CREATE_QSYS_SCRIPT_NAME}]
		source $TCL_CREATE_QSYS_SCRIPT

		set TCL_CREATE_PnPROM_SCRIPT [file join ${TCL_SCRIPT_PATH} ${TCL_CREATE_PnPROM_SCRIPT_NAME}]
		set auto_path [linsert $auto_path 0 ${TDOM_PATH}]
		source $TCL_CREATE_PnPROM_SCRIPT	
	
		# Commit assignments
		export_assignments
	}
}

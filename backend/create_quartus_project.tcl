# ##################################################################################
# File         : create_quartus_project.tcl
# Description  : TCL script used to create the KVB fpga project. 
#
# Example in the Quartus TCL console:
#
# tcl> source "$::env(KVB)/backend/create_quartus_project.tcl"
#
# ##################################################################################
set myself [info script]
puts "Running ${myself}"


###################################################################################
# Load Quartus Prime Tcl Project package
###################################################################################
package require ::quartus::project


###################################################################################
# Load the project setup environment variables
###################################################################################
set MYSELF_PATH [ file dirname [ file normalize ${myself} ] ]
source [file join ${MYSELF_PATH} "setup.tcl"]


###################################################################################
# Define the builID using the Unix epoch (time in secondes since midnight 1/1/1970)
###################################################################################
set BUILDID [clock seconds]
set BUILD_TIME  [clock format ${BUILDID} -format "%Y-%m-%d  %H:%M:%S"]
puts "BUILD_ID =  $BUILDID (${BUILD_TIME})"

set REVISION_NAME    "${PROJECT_NAME}_build${BUILDID}"
set PRE_FLOW_SCRIPT_FILE "${BACKEND_PATH}/pre_flow.tcl"
set POST_FLOW_SCRIPT_FILE "${BACKEND_PATH}/post_flow.tcl"


########################################################################################
# Create Project Directory structure
########################################################################################
if {[file exists $WORK_PATH] == 0} {
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
}

set_parameter -name BUILDID $BUILDID

########################################################################################
# Script list
########################################################################################
source "${BACKEND_PATH}/set_assignment.tcl"
source "${BACKEND_PATH}/set_pinout.tcl"
source "${BACKEND_PATH}/add_files.tcl"
source "${BACKEND_PATH}/${QUARTUS_VERSION}/call_qsys.tcl"


########################################################################################
# Save the .qsf file
########################################################################################
export_assignments

puts "Project : ${PROJECT_NAME} created successfully"

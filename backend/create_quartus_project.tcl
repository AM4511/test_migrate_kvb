################################################################################
# File         : create_quartus_project.tcl
# Description  : TCL script used to create the KVB FPGA project.
#
# Example in the Quartus TCL console:
#
# tcl> source "$::env(KVB)/backend/create_quartus_project.tcl"
################################################################################
set myself [info script]
puts "Running ${myself}"


################################################################################
# Load Quartus Prime Tcl Project package
################################################################################
package require ::quartus::project


################################################################################
# Load the project setup environment variables
################################################################################
set MYSELF_PATH [ file dirname [ file normalize ${myself} ] ]
source [file join ${MYSELF_PATH} "setup.tcl"]


################################################################################
# Define the builID using the Unix epoch (time in seconds since midnight 1/1/1970)
################################################################################
set BUILDID [clock seconds]
set BUILD_TIME  [clock format ${BUILDID} -format "%Y-%m-%d  %H:%M:%S"]
post_message "Build ID: ${BUILDID} (${BUILD_TIME})"


################################################################################
# Create project directory structure
################################################################################
if {[file exists ${WORK_PATH}] == 0} {
	file mkdir ${WORK_PATH}

    # create directories for each revision
    dict for {rev_name rev_attr} ${REV_DATA} {
        dict with rev_attr {
            file mkdir ${rev_work_path}
            file mkdir ${rev_firmware_path}
        }
    }
}

# Change to the working directory
cd ${WORK_PATH}

# get first revision
set first_rev_name [lindex [dict keys ${REV_DATA}] 0]

# Check that the right project is open
if {[is_project_open]} {
    if {[string compare $quartus(project) ${PROJECT_NAME}]} {
	puts "Project ${PROJECT_NAME} is not open"
    }
} else {
    # Only open if not already open (open first revision)
    if {[project_exists ${PROJECT_NAME}]} {
	project_open -revision "${PROJECT_NAME}_${first_rev_name}_build${BUILDID}" ${PROJECT_NAME}
    } else {
    puts "Create revision ${PROJECT_NAME}_${first_rev_name}_build${BUILDID}"
    project_new -revision "${PROJECT_NAME}_${first_rev_name}_build${BUILDID}" ${PROJECT_NAME}
    }
}

# save build ID to project
set_parameter -name BUILDID ${BUILDID}


################################################################################
# Configure project
################################################################################

# add common between all revisions
source "${BACKEND_PATH}/set_assignment.tcl"
source "${BACKEND_PATH}/set_pinout.tcl"
source "${BACKEND_PATH}/add_files.tcl"

# create additional revisions based on first revision
foreach rev_name [lrange [dict keys ${REV_DATA}] 1 end] {
    if {![revision_exists ${rev_name}_build${BUILDID}]} {
        puts "Create revision ${PROJECT_NAME}_${rev_name}_build${BUILDID}"
        create_revision -based_on "${PROJECT_NAME}_${first_rev_name}_build${BUILDID}" -copy_results "${PROJECT_NAME}_${rev_name}_build${BUILDID}"
    }
}

# add revision specifc settings/files
dict for {rev_name rev_attr} ${REV_DATA} {
    dict with rev_attr {
        set_current_revision "${PROJECT_NAME}_${rev_name}_build${BUILDID}"
        source "${BACKEND_PATH}/config_revision.tcl"
    }
}


################################################################################
# Save the .qsf file
################################################################################
export_assignments

puts "Project: ${PROJECT_NAME} created successfully"


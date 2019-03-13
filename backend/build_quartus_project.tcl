################################################################################
# File         : build_quartus_project.tcl
# Description  : TCL script to compile design
################################################################################
set myself [info script]
puts "Running ${myself}"


################################################################################
# Load Quartus Prime Tcl packages
################################################################################
package require ::quartus::project
package require ::quartus::flow


################################################################################
# Load the project setup environment variables
################################################################################
set MYSELF_PATH [ file dirname [ file normalize ${myself} ] ]
source [file join ${MYSELF_PATH} "setup.tcl"]


################################################################################
# Compile project revision(s)
################################################################################
set project_file [file join ${WORK_PATH} ${PROJECT_NAME}]
set project_revisions [get_project_revisions $project_file]

project_open -current_revision ${project_file}
set BUILDID [get_parameter -name "BUILDID"]
set rev_build_name "${PROJECT_NAME}_[lindex $quartus(args) 0]_build${BUILDID}"

if {[lsearch [get_project_revisions ${project_file}] ${rev_build_name}] != -1} {
    puts "Building ${rev_build_name}"

    set_current_revision ${rev_build_name}
    execute_flow -compile
} else {
    dict for {rev_name rev_info} ${REV_DATA} {
        set rev_build_name "${PROJECT_NAME}_${rev_name}_build${BUILDID}"
        puts "Building ${rev_build_name}"

        set_current_revision ${rev_build_name}
        execute_flow -compile
    }
}

set_current_revision [lindex $project_revisions 0]
project_close

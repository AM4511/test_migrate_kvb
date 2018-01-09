# ##################################################################################
# File         : build_quartus_project.tcl
# Description  : TCL script to compile design
#
# ##################################################################################
set myself [info script]
puts "Running ${myself}"


###################################################################################
# Load Quartus Prime Tcl packages
###################################################################################
package require ::quartus::project
package require ::quartus::flow


###################################################################################
# Load the project setup environment variables
###################################################################################
set MYSELF_PATH [ file dirname [ file normalize ${myself} ] ]
source [file join ${MYSELF_PATH} "setup.tcl"]


########################################################################################
# Open and compile project
########################################################################################
project_open -current_revision [file join ${WORK_PATH} ${PROJECT_NAME}]
execute_flow -compile

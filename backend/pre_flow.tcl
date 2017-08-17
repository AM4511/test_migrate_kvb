# ##################################################################################
# File         : pre_flow.tcl
# Description  : TCL script hoocked by the qsf assignment: 
#
# set_global_assignment -name PRE_FLOW_SCRIPT_FILE quartus_sh:${PRE_FLOW_SCRIPT_FILE}
#
# ##################################################################################

# Load Quartus Prime Tcl Project package
set myself [info script]
puts "Running ${myself}"


###################################################################################
# Load the project setup environment variables
###################################################################################
set MYSELF_PATH [ file dirname [ file normalize ${myself} ] ]
## set MYSELF_PATH "D:/git/gitlab/cpuskl/backend"
source [file join ${MYSELF_PATH} "setup.tcl"]


###################################################################################
# Load the PnP_ROM package compiler
###################################################################################
set SCRIPT_FILE [file join ${MYSELF_PATH} "PnP_ROM_Compiler.tcl"] 
set SOPCINFO_FILE [file join ${WORK_PATH} ${QSYS_SYSTEM_NAME}.sopcinfo]

source ${SCRIPT_FILE} 



################################################################################
# File         : pre_flow.tcl
# Description  : TCL script hooked by the qsf assignment:
#
# set_global_assignment -name PRE_FLOW_SCRIPT_FILE quartus_sh:${PRE_FLOW_SCRIPT_FILE}
#
################################################################################
set myself [info script]
puts "Running ${myself}"


################################################################################
# Load the project setup environment variables
################################################################################
set MYSELF_PATH [ file dirname [ file normalize ${myself} ] ]
source [file join ${MYSELF_PATH} "setup.tcl"]


################################################################################
# Load the PnP_ROM package compiler
################################################################################
set PNP_SCRIPT_FILE [file join "${IPCORE_LIB_PATH}/kns/PnP_ROM/tcl/PnP_ROM_Compiler.tcl"]

# Get revision
set rev_build_name [lindex $quartus(args) 2]

# Extract rev_name
# Assume rev_build_name follows format "${PROJECT_NAME}_${rev_name}_build${BUILDID}" and BUILDID is 10 characters (valid since 2001)
set rev_name [string range $rev_build_name [string length ${PROJECT_NAME}]+1 end-16]

# Use rev_name variables
dict with REV_DATA ${rev_name} {
    set SOPCINFO_FILE [file join ${rev_work_path} ${QSYS_SYSTEM_NAME}.sopcinfo]
    cd ${rev_work_path}

    # Call PnP_ROM package compiler
    post_message "Running ${PNP_SCRIPT_FILE} on ${SOPCINFO_FILE}"
    source ${PNP_SCRIPT_FILE}
}

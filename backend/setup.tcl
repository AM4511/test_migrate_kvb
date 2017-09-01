###################################################################################
# File         : setup.tcl
# Description  : Global environment variables for the KVB fpga project. 
#
###################################################################################
set myself [info script]
puts "Running ${myself}"


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
puts "Setting the KVB project environment variable"


########################################################################################
# Environment variable
########################################################################################
set FPGA_NAME        "kvb"
set REVMAJOR         "2"
set REVMINOR         "0"
set REVISION         "v${REVMAJOR}_${REVMINOR}"
set QUARTUS_VERSION   "quartus17.0"
set QSYS_SYSTEM_NAME "${FPGA_NAME}_system"
set PROJECT_NAME     "${FPGA_NAME}_${REVISION}"


########################################################################################
# Directory structure
########################################################################################
set QUARTUS_HOME      "$quartus(quartus_rootpath)"
set HDL_PATH          "${ROOT_PATH}/design"
set BACKEND_PATH      "${ROOT_PATH}/backend"
set IPCORE_LIB_PATH   "${ROOT_PATH}/ipcores/${QUARTUS_VERSION}"
set TCL_PATH          "${ROOT_PATH}/util/tcl"
set WORK_PATH         "${ROOT_PATH}/quartus/${QUARTUS_VERSION}/${PROJECT_NAME}"
set FIRMWARE_PATH     "${WORK_PATH}/firmwares"
set TDOM_PATH         "$BACKEND_PATH/tdom/win64/tdom0.8.3"


########################################################################################
# Add the TDOM library path in the search path
########################################################################################
if {[lsearch $auto_path ${TDOM_PATH}] < 0} {
    set auto_path [linsert $auto_path 0 ${TDOM_PATH}]
    puts "Adding ${TDOM_PATH} to \$auto_path variable"
} else {
    puts "${TDOM_PATH} already defined in \$auto_path variable"
}


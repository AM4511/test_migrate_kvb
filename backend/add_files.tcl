################################################################################
# File         : set_common_assignments.tcl
# Description  : TCL script used to add common files to KVB project.
################################################################################
set myself [info script]
puts "Running ${myself}"

################################################################################
# Add script files
################################################################################
set_global_assignment -name PRE_FLOW_SCRIPT_FILE quartus_sh:${BACKEND_PATH}/pre_flow.tcl
set_global_assignment -name POST_FLOW_SCRIPT_FILE quartus_sh:${BACKEND_PATH}/post_flow.tcl


################################################################################
# Add QIP files
################################################################################
set_global_assignment -name QIP_FILE ${IPCORE_LIB_PATH}/ipcores.qip


################################################################################
# Add SDC files
################################################################################
set_global_assignment -name SDC_FILE ${BACKEND_PATH}/kvb.sdc
set_global_assignment -name SDC_FILE ${BACKEND_PATH}/qspimram.sdc
set_global_assignment -name SDC_FILE ${BACKEND_PATH}/vme.sdc
set_global_assignment -name SDC_FILE ${BACKEND_PATH}/jtag.sdc


################################################################################
# Copy default hex files
################################################################################
set HEXFILE [file join ${HDL_PATH} "kns/dead_rom.hex"]
    dict for {rev_name rev_attr} ${REV_DATA} {
        dict with rev_attr {
           puts "Copying ${HEXFILE} to $rev_work_path"
           file copy -force ${HEXFILE} $rev_work_path
        }
    }


################################################################################
# Add common HDL files
################################################################################

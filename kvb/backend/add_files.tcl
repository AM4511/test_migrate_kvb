set me [info script]
puts "Running ${me}"
####################################################################################
####################################################################################
# Add QIP files
####################################################################################
set_global_assignment -name QIP_FILE ${IPCORE_LIB_PATH}/altera/ipcores.qip
set_global_assignment -name QIP_FILE ${IPCORE_LIB_PATH}/matrox/ipcores.qip
set_global_assignment -name QIP_FILE ${QSYS_SYSTEM_PATH}/synthesis/${QSYS_SYSTEM_NAME}.qip

####################################################################################
# Add SDC files
####################################################################################
#set_global_assignment -name SDC_FILE c4gx_pcie_sopc.out.sdc
set_global_assignment -name SDC_FILE ${BACKEND_PATH}/kvb.sdc

####################################################################################
# Copy default hex files
####################################################################################
set HEXFILE [file join ${HDL_PATH} "kns/dead_rom.hex"]
if {[file exist $WORK_PATH/dead_rom.hex] == 0} {
	puts "Copying $HEXFILE to $WORK_PATH"
	file copy $HEXFILE $WORK_PATH
}

set HEXFILE [file join ${HDL_PATH} "kns/PnP_ROM.hex"]
if {[file exist $WORK_PATH/PnP_ROM.hex] == 0} {
	puts "Copying $HEXFILE to $WORK_PATH"
	file copy $HEXFILE $WORK_PATH
}


####################################################################################
# Add default hdl files
####################################################################################
set_global_assignment -name VERILOG_FILE ${HDL_PATH}/matrox/cpuskl_kvb_top.v



####################################################################################
# Add SignalTAP files
####################################################################################
set_global_assignment -name USE_SIGNALTAP_FILE kvb_signal_tap.stp
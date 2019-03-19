################################################################################
# File         : config_revision.tcl
# Description  : TCL script used to add settings/files specific to each
#                revision to KVB project.
################################################################################
set myself [info script]
puts "Running ${myself}"
cd ${rev_work_path}


################################################################################
# Set revision specific assignments
################################################################################
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY ${rev_firmware_path}
set_global_assignment -name SEARCH_PATH ${rev_firmware_path}/ -tag from_archive


################################################################################
# Add revision constraints files
################################################################################
set_global_assignment -name SDC_FILE ${BACKEND_PATH}/${rev_name}_lpc.sdc


################################################################################
# Add revision specific HDL files
################################################################################
set_global_assignment -name VERILOG_FILE ${HDL_PATH}/matrox/${rev_name}_kvb_top.v


################################################################################
# Add revision specific IP cores
################################################################################
set_global_assignment -name QIP_FILE ${rev_qsys_path}/synthesis/${QSYS_SYSTEM_NAME}.qip


################################################################################
# Add SignalTAP files
################################################################################
# set_global_assignment -name USE_SIGNALTAP_FILE ${rev_name}.stp


################################################################################
# Save the .qsf file
################################################################################
export_assignments


################################################################################
# Create and generate revision specific QSYS systems
################################################################################
source "${BACKEND_PATH}/quartus${QUARTUS_VERSION}/call_qsys.tcl"

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


####################################################################################
# Quartus Tools
###################################################################################
set QUARTUS_MAP_EXE [file join ${QUARTUS_HOME} "bin64/quartus_map"]
set QUARTUS_FIT_EXE [file join ${QUARTUS_HOME} "bin64/quartus_fit"]
set QUARTUS_ASM_EXE [file join ${QUARTUS_HOME} "bin64/quartus_asm"]
set QUARTUS_POW_EXE [file join ${QUARTUS_HOME} "bin64/quartus_pow"]
set QUARTUS_STA_EXE [file join ${QUARTUS_HOME} "bin64/quartus_sta"]


########################################################################################
# Quartus commands
########################################################################################
set REVISION_NAME [get_current_revision [file join ${WORK_PATH} ${PROJECT_NAME}]]
set quartus_map_command "${QUARTUS_MAP_EXE} --read_settings_files=on --write_settings_files=off ${WORK_PATH}/${PROJECT_NAME} -c ${REVISION_NAME}"
set quartus_io_command "${QUARTUS_FIT_EXE} --read_settings_files=off --write_settings_files=off ${WORK_PATH}/${PROJECT_NAME} -c ${REVISION_NAME} --plan"
set quartus_fit_command "${QUARTUS_FIT_EXE} --read_settings_files=off --write_settings_files=off ${WORK_PATH}/${PROJECT_NAME} -c ${REVISION_NAME}"
set quartus_asm_command "${QUARTUS_ASM_EXE} --read_settings_files=off --write_settings_files=off ${WORK_PATH}/${PROJECT_NAME} -c ${REVISION_NAME}"
set quartus_pow_command "${QUARTUS_POW_EXE} --read_settings_files=off --write_settings_files=off ${WORK_PATH}/${PROJECT_NAME} -c ${REVISION_NAME}"
set quartus_sta_command "${QUARTUS_STA_EXE} ${WORK_PATH}/${PROJECT_NAME} -c ${REVISION_NAME}"


########################################################################################
# Compile project
########################################################################################
source [file join ${BACKEND_PATH} "pre_flow.tcl"]
puts "SYSTEM CALL: exec $quartus_map_command"
exec >&@stdout {*}$quartus_map_command
puts "SYSTEM CALL: exec $quartus_io_command"
exec >&@stdout {*}$quartus_io_command
puts "SYSTEM CALL: exec $quartus_fit_command"
exec >&@stdout {*}$quartus_fit_command
puts "SYSTEM CALL: exec $quartus_asm_command"
exec >&@stdout {*}$quartus_asm_command
puts "SYSTEM CALL: exec $quartus_pow_command"
exec >&@stdout {*}$quartus_pow_command
puts "SYSTEM CALL: exec $quartus_sta_command"
exec >&@stdout {*}$quartus_sta_command
source [file join ${BACKEND_PATH} "post_flow.tcl"]
puts "Project : ${PROJECT_NAME} compiled successfully"



set me [info script]
puts "Running ${me}"

####################################################################################
# QUARTUS Tools
####################################################################################
set QSYS_SCRIPT_EXE      [file join $QUARTUS_HOME "sopc_builder/bin/qsys-script"]
set GENERATE_SCRIPT_EXE  [file join $QUARTUS_HOME "sopc_builder/bin/qsys-generate"]


####################################################################################
# Create the QSYS system
####################################################################################
set TCL_QSYS_SCRIPT [file join $BACKEND_PATH $QUARTUS_VERSION ${QSYS_SYSTEM_NAME}.tcl]

set arg_list "--script=$TCL_QSYS_SCRIPT --search-path=$IPCORE_LIB_PATH/**/*,\$"
set create_qsys_system_command [join [list "exec ${QSYS_SCRIPT_EXE}" $arg_list]]


puts "SYSTEM CALL: $create_qsys_system_command"
eval $create_qsys_system_command


####################################################################################
# Generate the QSYS system
####################################################################################
set QSYS_FILE             "$WORK_PATH/${QSYS_SYSTEM_NAME}.qsys"

set generate_qsys_system_command "exec $GENERATE_SCRIPT_EXE $QSYS_FILE --synthesis=VERILOG --output-directory=$QSYS_SYSTEM_PATH --search-path=$IPCORE_LIB_PATH/**/*,\$ --family=\"Cyclone IV GX\" --part=EP4CGX22CF19C8 --clear-output-directory"

puts "SYSTEM CALL: $generate_qsys_system_command"
eval $generate_qsys_system_command

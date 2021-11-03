set me [info script]
puts "Running ${me}"

####################################################################################
# QUARTUS Tools
####################################################################################
set QSYS_SCRIPT_EXE      [file join $QUARTUS_HOME "sopc_builder/bin/qsys-script"]
set GENERATE_SCRIPT_EXE  [file join $QUARTUS_HOME "sopc_builder/bin/qsys-generate"]


####################################################################################
# Qsys script commands
####################################################################################
set cmd_list [join "
    set QSYS_NAME ${QSYS_NAME};
    set BOARD_NAME ${BOARD_NAME};
    set PART_NUMBER ${PART_NUMBER};
    set GW_VERSION ${GW_VERSION};
    set GIT_COMMIT 0x${GIT_COMMIT};
    set BUILDID ${BUILDID}
"]


####################################################################################
# Create the QSYS system from a system call
####################################################################################
set QSYS_SYSTEM_PATH  "${WORK_PATH}/${QSYS_SYSTEM_NAME}"
set TCL_QSYS_SYSTEM_SCRIPT_NAME  "${QSYS_SYSTEM_NAME}.tcl"

set TCL_QSYS_SCRIPT_PATH [file join $BACKEND_PATH $QUARTUS_VERSION ${TCL_QSYS_SYSTEM_SCRIPT_NAME}]
set cmd_arg "--cmd=\"$cmd_list\""
set arg_list "--script=$TCL_QSYS_SCRIPT_PATH --search-path=$IPCORE_LIB_PATH/**/*,\$"
set create_qsys_system_command [join [list $QSYS_SCRIPT_EXE $cmd_arg $arg_list]]

# Start the build process
puts "SYSTEM CALL: exec $create_qsys_system_command"
# Need to trap errors since qsys-script returns a non-zero exit code
try {
    exec >&@stdout {*}${create_qsys_system_command}
    } trap NONE {} {
        # process exited writing to stderr (no non-zero exit status)
    } trap CHILDSTATUS {} {
        # process exited with non-zero exit code
        error "Qsys system creation failed"
    } trap TCL {} {
        # Tcl error (if running from inside Quartus stdout isn't available; try again without it)
        exec {*}${create_qsys_system_command}
    }
puts "Qsys system created"


####################################################################################
# Generate the QSYS system
####################################################################################
set QSYS_FILE "$WORK_PATH/${QSYS_SYSTEM_NAME}.qsys"
set generate_qsys_system_command "$GENERATE_SCRIPT_EXE $QSYS_FILE --synthesis=VERILOG --output-directory=$QSYS_SYSTEM_PATH --search-path=$IPCORE_LIB_PATH/**/*,\$ --family=\"Cyclone IV GX\" --part=EP4CGX75DF27C8 --clear-output-directory"

# Start the generate process
puts "SYSTEM CALL: exec $generate_qsys_system_command"
# Need to trap errors since qsys-generate returns a non-zero exit code
try {
    exec >&@stdout {*}${generate_qsys_system_command}
    } trap NONE {} {
        # process exited writing to stderr (no non-zero exit status)
    } trap CHILDSTATUS {} {
        # process exited with non-zero exit code
        error "Qsys system generation failed"
    } trap TCL {} {
        # Tcl error (if running from Quartus stdout isn't available; try again without it)
        exec {*}${generate_qsys_system_command}
    }
puts "Qsys system generated"

set_global_assignment -name QIP_FILE ${QSYS_SYSTEM_PATH}/synthesis/${QSYS_SYSTEM_NAME}.qip


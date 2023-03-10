################################################################################
# File         : call_qsys.tcl
# Description  : TCL script used to create and generate Qsys system for revision.
################################################################################
set myself [info script]
puts "Running ${myself}"


################################################################################
# QUARTUS Tools
################################################################################
set QSYS_SCRIPT_EXE      [file join ${QUARTUS_HOME} "sopc_builder/bin/qsys-script"]
set GENERATE_SCRIPT_EXE  [file join ${QUARTUS_HOME} "sopc_builder/bin/qsys-generate"]


################################################################################
# Qsys script commands
################################################################################
set cmd_list [join "
    set DEVICE ${rev_fpga_dev_name};
    set QSYS_NAME ${QSYS_SYSTEM_NAME};
    set BOARD_NAME ${rev_board_name};
    set PART_NUMBER ${rev_part_number};
    set GW_VERSION ${GW_VERSION};
    set GIT_COMMIT 0x${GIT_COMMIT};
    set BUILDID ${BUILDID};
    set WORK_PATH ${rev_work_path_rel}
"]


################################################################################
# Create the QSYS system from a system call
################################################################################
set QSYS_SYSTEM_PATH  "${rev_work_path}/${QSYS_SYSTEM_NAME}"
set TCL_QSYS_SYSTEM_SCRIPT_NAME  "${rev_work_path_rel}_${QSYS_SYSTEM_NAME}.tcl"

set TCL_QSYS_SCRIPT_PATH [file join ${BACKEND_PATH} quartus${QUARTUS_VERSION} ${TCL_QSYS_SYSTEM_SCRIPT_NAME}]
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
        error "${rev_name} Qsys system creation failed"
    } trap TCL {} {
        # Tcl error (if running from inside Quartus stdout isn't available; try again without it)
        exec {*}${create_qsys_system_command}
    }
puts "${rev_name} Qsys system created"


################################################################################
# Generate the QSYS system
################################################################################
set QSYS_FILE "${rev_work_path}/${QSYS_SYSTEM_NAME}.qsys"
set generate_qsys_system_command "$GENERATE_SCRIPT_EXE $QSYS_FILE --synthesis=VERILOG --output-directory=${rev_qsys_path} --search-path=$IPCORE_LIB_PATH/**/*,\$ --family=\"${FPGA_FAMILY}\" --part=${rev_fpga_dev_name} --clear-output-directory"

# Start the generate process
puts "SYSTEM CALL: exec $generate_qsys_system_command"
# Need to trap errors since qsys-generate returns a non-zero exit code
try {
    exec >&@stdout {*}${generate_qsys_system_command}
    } trap NONE {} {
        # process exited writing to stderr (no non-zero exit status)
    } trap CHILDSTATUS {} {
        # process exited with non-zero exit code
        error "${rev_name} Qsys system generation failed"
    } trap TCL {} {
        # Tcl error (if running from Quartus stdout isn't available; try again without it)
        exec {*}${generate_qsys_system_command}
    }
puts "${rev_name} Qsys system generated"

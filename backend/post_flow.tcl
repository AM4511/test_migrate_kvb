# ##################################################################################
# File         : post_flow.tcl
# Description  : TCL script hoocked by the qsf assignment: 
#
# set_global_assignment -name POST_FLOW_SCRIPT_FILE quartus_sh:${POST_FLOW_SCRIPT_FILE}
#
# ##################################################################################

# Load Quartus Prime Tcl Project package
set myself [info script]
puts "Running ${myself}"


###################################################################################
# Load Quartus Prime Tcl Project package
###################################################################################
package require ::quartus::misc


###################################################################################
# Load the project setup environment variables
###################################################################################
set MYSELF_PATH [ file dirname [ file normalize ${myself} ] ]
## set MYSELF_PATH "D:/git/gitlab/cpuskl/backend"
source [file join ${MYSELF_PATH} "setup.tcl"]

# assume in backend; set relative root one level up
set CURRENT_ROOT_PATH [file join ${MYSELF_PATH} ".."]
set ARCHIVE_PATH [join [list ${CURRENT_ROOT_PATH} [string range ${ARCHIVE_PATH} [string length ${ROOT_PATH}] [string length ${ARCHIVE_PATH}]]] ""]
set BACKEND_PATH [join [list ${CURRENT_ROOT_PATH} [string range ${BACKEND_PATH} [string length ${ROOT_PATH}] [string length ${BACKEND_PATH}]]] ""]
set HDL_PATH [join [list ${CURRENT_ROOT_PATH} [string range ${HDL_PATH} [string length ${ROOT_PATH}] [string length ${HDL_PATH}]]] ""]
set IPCORE_LIB_PATH [join [list ${CURRENT_ROOT_PATH} [string range ${IPCORE_LIB_PATH} [string length ${ROOT_PATH}] [string length ${IPCORE_LIB_PATH}]]] ""]
set QSYS_PATH [join [list ${CURRENT_ROOT_PATH} [string range ${QSYS_PATH} [string length ${ROOT_PATH}] [string length ${QSYS_PATH}]]] ""]
set FIRMWARE_PATH [join [list ${CURRENT_ROOT_PATH} [string range ${FIRMWARE_PATH} [string length ${ROOT_PATH}] [string length ${FIRMWARE_PATH}]]] ""]
set WORK_PATH [join [list ${CURRENT_ROOT_PATH} [string range ${WORK_PATH} [string length ${ROOT_PATH}] [string length ${WORK_PATH}]]] ""]


####################################################################################
# QUARTUS Tools
####################################################################################
set QUARTUS_CPF_EXE [file join ${QUARTUS_HOME} "bin64/quartus_cpf"]
set QUARTUS_SH_EXE [file join ${QUARTUS_HOME} "bin64/quartus_sh"]


###################################################################################
# Generate JTAG indirect configuration file
###################################################################################
set REVISION_NAME [lindex $argv 2]      ; # get revision name (third argument)
set convert_sof_jic_cmd "${QUARTUS_CPF_EXE} -c -d EPCQ128 -s EP4CGX22 -o bitstream_compression=on ${FIRMWARE_PATH}/${REVISION_NAME}.sof ${FIRMWARE_PATH}/${REVISION_NAME}.jic"
puts "SYSTEM CALL: exec $convert_sof_jic_cmd"
post_message "SYSTEM CALL: exec $convert_sof_jic_cmd"
exec {*}$convert_sof_jic_cmd


###################################################################################
# Recursive glob procedure
###################################################################################
proc glob-r {{dir .}} {
    set res {}
    foreach i [glob -nocomplain -dir $dir *] {
        if {[file type $i] eq {directory}} {
            eval lappend res [glob-r $i]
        } else {
            lappend res $i
        }
    }
    set res
}


###################################################################################
# Generate archive file list
###################################################################################
if {[file exists ${ARCHIVE_PATH}] == 0} {
	file mkdir ${ARCHIVE_PATH}
}

set ARCHIVE_FILE_MANIFEST "${ARCHIVE_PATH}/${REVISION_NAME}_archive_list.txt"
set archive_dirs_no_recursive "
    ${WORK_PATH}
"
set archive_dirs_recursive "
    ${BACKEND_PATH}
    ${HDL_PATH}
    ${IPCORE_LIB_PATH}
    ${FIRMWARE_PATH}
    ${QSYS_PATH}
"

set archive_manifest_fd [open ${ARCHIVE_FILE_MANIFEST} w]
puts $archive_manifest_fd [file join ${QUARTUS_HOME} "bin64/assignment_defaults.qdf"]
foreach archive_current_dir $archive_dirs_no_recursive {
    foreach archive_current_file [glob -types {f} $archive_current_dir/*] {puts $archive_manifest_fd $archive_current_file}
    }
foreach archive_current_dir $archive_dirs_recursive {
    foreach archive_current_file [glob-r $archive_current_dir] {puts $archive_manifest_fd $archive_current_file}
    }
close $archive_manifest_fd


###################################################################################
# Generate archive
###################################################################################
set ARCHIVE_NAME "${REVISION_NAME}_git${GIT_COMMIT}"
set archive_cmd "${QUARTUS_SH_EXE} --archive -revision ${REVISION_NAME} -output ${ARCHIVE_PATH}/${ARCHIVE_NAME} -use_file_set custom -input \"$ARCHIVE_FILE_MANIFEST\" -overwrite ${WORK_PATH}/${PROJECT_NAME}"
cd ${ROOT_PATH}
puts "SYSTEM CALL: exec $archive_cmd"
post_message "SYSTEM CALL: exec $archive_cmd"
exec {*}$archive_cmd


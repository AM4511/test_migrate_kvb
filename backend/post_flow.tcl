################################################################################
# File         : post_flow.tcl
# Description  : TCL script hoocked by the qsf assignment: 
#
# set_global_assignment -name POST_FLOW_SCRIPT_FILE quartus_sh:${POST_FLOW_SCRIPT_FILE}
#
# Use post_message to see output instead of puts since script runs in another quaruts_sh
################################################################################
set myself [info script]
puts "Running ${myself}"


################################################################################
# Load Quartus Prime Tcl Project package
################################################################################
package require ::quartus::project
package require ::quartus::misc


################################################################################
# Load the project setup environment variables
################################################################################
set MYSELF_PATH [ file dirname [ file normalize ${myself} ] ]
source [file join ${MYSELF_PATH} "setup.tcl"]


################################################################################
# QUARTUS Tools
################################################################################
set QUARTUS_CPF_EXE [file join ${QUARTUS_HOME} "bin64/quartus_cpf"]
set QUARTUS_SH_EXE [file join ${QUARTUS_HOME} "bin64/quartus_sh"]
set ZIP_EXE [file join ${QUARTUS_HOME} "bin64/cygwin/bin/zip.exe"]
set MD5SUM_EXE [file join ${QUARTUS_HOME} "bin64/cygwin/bin/md5sum.exe"]


################################################################################
# Recursive glob procedure
################################################################################
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


# Get revision
set rev_build_name [lindex $quartus(args) 2]

# Extract rev_name
# Assume rev_build_name follows format "${PROJECT_NAME}_${rev_name}_build${BUILDID}" and BUILDID is 10 characters (valid since 2001)
set rev_name [string range $rev_build_name [string length ${PROJECT_NAME}]+1 end-16]

# Use rev_name variables
dict with REV_DATA ${rev_name} {
    cd ${rev_work_path}


    ############################################################################
    # Generate Programmer Object File (POF)
    ############################################################################
    set convert_sof_pof_cmd "${QUARTUS_CPF_EXE} -c -d ${FLASH_PART_NUMBER} -o bitstream_compression=on ${rev_firmware_path}/${rev_build_name}.sof ${rev_firmware_path}/${rev_build_name}.pof"
    post_message "SYSTEM CALL: exec $convert_sof_pof_cmd"
    exec {*}$convert_sof_pof_cmd


    ############################################################################
    # Generate Raw Programming Data (RPD) file
    ############################################################################
    set convert_pof_rpd_cmd "${QUARTUS_CPF_EXE} -c -d ${FLASH_PART_NUMBER} -o bitstream_compression=on ${rev_firmware_path}/${rev_build_name}.pof ${rev_firmware_path}/${rev_build_name}.rpd"
    post_message "SYSTEM CALL: exec $convert_pof_rpd_cmd"
    exec {*}$convert_pof_rpd_cmd


    ############################################################################
    # Generate JTAG indirect configuration (JIC) file
    ############################################################################
    set convert_sof_jic_cmd "${QUARTUS_CPF_EXE} -c -d ${FLASH_PART_NUMBER} -s ${rev_fpga_dev} -o bitstream_compression=on ${rev_firmware_path}/${rev_build_name}.sof ${rev_firmware_path}/${rev_build_name}.jic"
    post_message "SYSTEM CALL: exec $convert_sof_jic_cmd"
    exec {*}$convert_sof_jic_cmd


    ############################################################################
    # Create copy of project for this revision only
    ############################################################################
    set multi_rev_project_file [file join ${WORK_PATH} "${PROJECT_NAME}.qpf"]
    set single_rev_project_file [file join ${WORK_PATH} "${PROJECT_NAME}_${rev_name}.qpf"]

    file copy -force ${multi_rev_project_file} ${single_rev_project_file}

    # Iterate over all revisions
    dict for {other_rev_name other_rev_info} ${REV_DATA} {
        # Skip revision being compiled
        if {[string match ${other_rev_name} ${rev_name}]} {
            continue
        }

        # Assume QSF file names follow format "${PROJECT_NAME}_${rev_name}_build${BUILDID}.qsf"
        set rev_to_remove_file [file join ${WORK_PATH} "[regsub ${rev_name} ${rev_build_name} ${other_rev_name}].qsf"]
        set post_flow_lock_file [file join ${WORK_PATH} "post_flow.lock"]

        # Check for other temp files (parallel operations) and wait if found
        while {[file exists ${post_flow_lock_file}]} {
            post_message "Waiting for ${post_flow_lock_file}"
            after 1000
        }

        # Make a copy of other_rev_name QSF file since delete_revision deletes QSF file
        file copy -force ${rev_to_remove_file} ${post_flow_lock_file}

        # Delete other_rev_name revision
        project_open -revision ${rev_build_name} ${single_rev_project_file}
        delete_revision [regsub ${rev_name} ${rev_build_name} ${other_rev_name}]
        project_close

        # Restore other_rev_name revision QSF file
        file rename -force ${post_flow_lock_file} ${rev_to_remove_file}
    }


    ############################################################################
    # Generate Quartus archive file list
    ############################################################################
    if {[file exists ${ARCHIVE_PATH}] == 0} {
    	file mkdir ${ARCHIVE_PATH}
    }

    # Create archive manifest file (files to include in QAR)
    set ARCHIVE_FILE_MANIFEST "${rev_work_path}/${rev_name}_archive_list.txt"
    set archive_dirs_no_recursive "
        ${rev_work_path}
        "
    set archive_dirs_recursive "
        ${BACKEND_PATH}
        ${DOC_PATH}
        ${HDL_PATH}
        ${IPCORE_LIB_PATH}
        ${rev_firmware_path}
        ${rev_qsys_path}
        "

    set archive_manifest_fd [open ${ARCHIVE_FILE_MANIFEST} w]

    # Add files
    #puts $archive_manifest_fd [file join ${QUARTUS_HOME} "bin64/assignment_defaults.qdf"]
    puts $archive_manifest_fd ${single_rev_project_file}
    puts $archive_manifest_fd [file join ${WORK_PATH} "${rev_build_name}.qsf"]

    foreach archive_current_dir ${archive_dirs_no_recursive} {
        foreach archive_current_file [glob -types {f} ${archive_current_dir}/*] {
            puts $archive_manifest_fd ${archive_current_file}
            }
        }

    foreach archive_current_dir ${archive_dirs_recursive} {
        foreach archive_current_file [glob-r ${archive_current_dir}] {
            puts $archive_manifest_fd ${archive_current_file}
            }
        }

    close $archive_manifest_fd


    ############################################################################
    # Generate Quartus archive
    ############################################################################
    set ARCHIVE_NAME "${rev_build_name}_git${GIT_COMMIT}"
    set archive_cmd "${QUARTUS_SH_EXE} --archive -revision ${rev_build_name} -output ${rev_work_path}/${ARCHIVE_NAME} -use_file_set custom -input \"$ARCHIVE_FILE_MANIFEST\" -overwrite ${WORK_PATH}/${PROJECT_NAME}"
    post_message "SYSTEM CALL: exec $archive_cmd"
    exec {*}$archive_cmd
    file rename -force "${WORK_PATH}/${rev_build_name}.archive.rpt" "${rev_work_path}/${rev_build_name}.archive.rpt"
    file rename -force "${rev_work_path}/${ARCHIVE_NAME}.qar" "${ARCHIVE_PATH}/${ARCHIVE_NAME}.qar"


    ############################################################################
    # Zip outputs
    ############################################################################
    set ZIP_NAME "${rev_build_name}_git${GIT_COMMIT}"
    set zip_file_list "${rev_work_path}/*.rpt ${rev_work_path}/*.log ${rev_firmware_path}/*.* ${rev_qsys_path}/*.htm* ${rev_qsys_path}/*.rpt"
    set zip_cmd "${ZIP_EXE} -FS -j -5 ${rev_work_path}/${ZIP_NAME} ${zip_file_list}"
    post_message "SYSTEM CALL: exec $zip_cmd"
    exec -ignorestderr {*}$zip_cmd
    file rename -force "${rev_work_path}/${ZIP_NAME}.zip" "${ARCHIVE_PATH}/${ZIP_NAME}.zip"


    ############################################################################
    # Compute MD5 sum
    ############################################################################
    set MD5_NAME "${rev_build_name}.md5"
    set md5sum_cmd "${MD5SUM_EXE} ${ARCHIVE_NAME}.qar ${ZIP_NAME}.zip > ${MD5_NAME}"
    cd ${ARCHIVE_PATH}
    post_message "SYSTEM CALL: exec $md5sum_cmd"
    exec {*}$md5sum_cmd


    ################################################################################
    # Clean up
    ################################################################################
    file delete $single_rev_project_file
}

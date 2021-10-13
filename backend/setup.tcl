################################################################################
# File         : setup.tcl
# Description  : Global environment variables for the KVB fpga project. 
################################################################################
set myself [info script]
puts "Running ${myself}"


global ROOT_PATH
 if { [info exists ::env(KVB) ] } {
    # Set the ROOT folder path from a Windows environment variable
    set ROOT_PATH [file normalize $::env(KVB)]
    puts "ROOT_PATH ::env(KVB) -> $ROOT_PATH"
 } else {
    # ROOT path not found
    post_message -type error "ROOT_PATH ::env(KVB) not set"
    error "ROOT_PATH ::env(KVB) not set"
}
puts "Setting the KVB project environment variable"


################################################################################
# Environment variable
################################################################################
set FPGA_FAMILY         "Cyclone IV GX"
set FLASH_PART_NUMBER   "EPCQ128"
set FPGA_NAME           "kvb"
set REVMAJOR            "4"                            ; # must be < 655
set REVMINOR            "0"                            ; # must be < 100
set REVISION            "v${REVMAJOR}_${REVMINOR}"
set PROJECT_NAME        "${FPGA_NAME}_${REVISION}"
set QSYS_NAME           "${FPGA_NAME}"
set QSYS_SYSTEM_NAME    "${QSYS_NAME}_system"
set GW_VERSION          [expr {${REVMAJOR} * 100 + ${REVMINOR}}]


################################################################################
# Get Quartus version
################################################################################
set quartus_ver_string "${quartus(version)}"
if {[scan $quartus_ver_string "Version %d.%d.%d" quartus_ver_major quartus_ver_minor quartus_ver_patch] != 3} {
    error "Unable to parse Quartus version from $quartus_ver_string"
}
set QUARTUS_VERSION_FULL "$quartus_ver_major.$quartus_ver_minor.$quartus_ver_patch"
set QUARTUS_VERSION "$quartus_ver_major.$quartus_ver_minor"


################################################################################
# Directory structure [no spaces in strings]
################################################################################
set QUARTUS_HOME      "$quartus(quartus_rootpath)"
set ARCHIVE_PATH      "${ROOT_PATH}/archive"
set HDL_PATH          "${ROOT_PATH}/design"
set BACKEND_PATH      "${ROOT_PATH}/backend"
set DOC_PATH          "${ROOT_PATH}/doc"
set IPCORE_LIB_PATH   "${ROOT_PATH}/ipcores/quartus${QUARTUS_VERSION}"
set TCL_PATH          "${ROOT_PATH}/util/tcl"
set WORK_PATH         "${ROOT_PATH}/quartus/${QUARTUS_VERSION}/${PROJECT_NAME}"
set TDOM_PATH         "${BACKEND_PATH}/tdom/win64/tdom0.8.3"


################################################################################
# Check for work path spaces and excessive length
################################################################################
set work_path_length [string length ${WORK_PATH}]
if {$work_path_length > 125} {
    post_message -type warning "Long work path ($work_path_length characters): ${WORK_PATH}"
}
if {[regexp {\s} ${WORK_PATH}]} {
    post_message -type error "Work path ${WORK_PATH} cannot contain spaces"
}


################################################################################
# Revision variables [no spaces in strings]
################################################################################
# This project contains Quartus project revisions for each KVB variant.
#
# Dictionary structure:
#   REV_DATA
#       <revision name>
#           rev_board_name      board name string
#           rev_part_number     K&S part number string
#           rev_work_path_rel   relative work path for <revision name> [no spaces]
#           rev_work_path       absolute work path for <revision name> [no spaces]
#           rev_firmware_path   absolute firmware path for <revision name>
#           rev_qsys_path       absolute QSYS system path for <revision name>
#
################################################################################

# CPUSKL/KA/KB/KE/KF/KG/KH/KI for ball bonder [VME A16/A24 D8(O)/D16, 2 PCIe UARTs] for EP4CGX22

dict set REV_DATA skl_ball_22    rev_fpga_dev         "EP4CGX22"
dict set REV_DATA skl_ball_22    rev_fpga_dev_name    "EP4CGX22CF19C8"
dict set REV_DATA skl_ball_22    rev_board_name       "CPUSKL"
dict set REV_DATA skl_ball_22    rev_part_number      "08991-4010-000/08991-4010-020"
dict set REV_DATA skl_ball_22    rev_family           "skl_ball"
dict set REV_DATA skl_ball_22    rev_work_path_rel    "skl_ball_22"
dict set REV_DATA skl_ball_22    rev_work_path        "${WORK_PATH}/skl_ball_22"
dict set REV_DATA skl_ball_22    rev_firmware_path    "${WORK_PATH}/skl_ball_22/firmware"
dict set REV_DATA skl_ball_22    rev_qsys_path        "${WORK_PATH}/skl_ball_22/${QSYS_SYSTEM_NAME}"

# CPUSKL/KC/KD or CPUKBL/KB for wedge bonder [VME A16/A24/A32 D8(O)/D16/D32, no PCIe UARTs] for EP4CGX22
dict set REV_DATA skl_wedge_22   rev_fpga_dev         "EP4CGX22"
dict set REV_DATA skl_wedge_22   rev_fpga_dev_name    "EP4CGX22CF19C8"
dict set REV_DATA skl_wedge_22   rev_board_name       "CPUSKL/CPUKBL"
dict set REV_DATA skl_wedge_22   rev_part_number      "07977-4000-000/08991-4010-000/08991-4010-020"
dict set REV_DATA skl_wedge_22    rev_family           "skl_wedge"
dict set REV_DATA skl_wedge_22   rev_work_path_rel    "skl_wedge_22"
dict set REV_DATA skl_wedge_22   rev_work_path        "${WORK_PATH}/skl_wedge_22"
dict set REV_DATA skl_wedge_22   rev_firmware_path    "${WORK_PATH}/skl_wedge_22/firmware"
dict set REV_DATA skl_wedge_22   rev_qsys_path        "${WORK_PATH}/skl_wedge_22/${QSYS_SYSTEM_NAME}"

# CPUKBL/KA for ball bonder [no VME, no PCIe UARTs] for EP4CGX22
dict set REV_DATA kbl_ball_22    rev_fpga_dev         "EP4CGX22"
dict set REV_DATA kbl_ball_22    rev_fpga_dev_name    "EP4CGX22CF19C8"
dict set REV_DATA kbl_ball_22    rev_board_name       "CPUKBL"
dict set REV_DATA kbl_ball_22    rev_part_number      "08900-4010-000/08900-4010-020"
dict set REV_DATA skl_ball_22    rev_family           "kbl_ball"
dict set REV_DATA kbl_ball_22    rev_work_path_rel    "kbl_ball_22"
dict set REV_DATA kbl_ball_22    rev_work_path        "${WORK_PATH}/kbl_ball_22"
dict set REV_DATA kbl_ball_22    rev_firmware_path    "${WORK_PATH}/kbl_ball_22/firmware"
dict set REV_DATA kbl_ball_22    rev_qsys_path        "${WORK_PATH}/kbl_ball_22/${QSYS_SYSTEM_NAME}"

# CPUSKL/KA/KB/KE/KF/KG/KH/KI for ball bonder [VME A16/A24 D8(O)/D16, 2 PCIe UARTs] for EP4CGX75
dict set REV_DATA skl_ball_75    rev_fpga_dev         "EP4CGX75"
dict set REV_DATA skl_ball_75    rev_fpga_dev_name    "EP4CGX75DF27C8"
dict set REV_DATA skl_ball_75    rev_board_name       "CPUSKL"
dict set REV_DATA skl_ball_75    rev_part_number      "08991-4010-000/08991-4010-020"
dict set REV_DATA skl_ball_75    rev_family           "skl_ball"
dict set REV_DATA skl_ball_75    rev_work_path_rel    "skl_ball_75"
dict set REV_DATA skl_ball_75    rev_work_path        "${WORK_PATH}/skl_ball_75"
dict set REV_DATA skl_ball_75    rev_firmware_path    "${WORK_PATH}/skl_ball_75/firmware"
dict set REV_DATA skl_ball_75    rev_qsys_path        "${WORK_PATH}/skl_ball_75/${QSYS_SYSTEM_NAME}"

# CPUSKL/KC/KD or CPUKBL/KB for wedge bonder [VME A16/A24/A32 D8(O)/D16/D32, no PCIe UARTs] for EP4CGX75
dict set REV_DATA skl_wedge_75   rev_fpga_dev         "EP4CGX75"
dict set REV_DATA skl_wedge_75   rev_fpga_dev_name    "EP4CGX75DF27C8"
dict set REV_DATA skl_wedge_75   rev_board_name       "CPUSKL/CPUKBL"
dict set REV_DATA skl_wedge_75   rev_part_number      "08991-4010-000/08991-4010-020/08900-4010-000"
dict set REV_DATA skl_wedge_75   rev_family           "skl_wedge"
dict set REV_DATA skl_wedge_75   rev_work_path_rel    "skl_wedge_75"
dict set REV_DATA skl_wedge_75   rev_work_path        "${WORK_PATH}/skl_wedge_75"
dict set REV_DATA skl_wedge_75   rev_firmware_path    "${WORK_PATH}/skl_wedge_75/firmware"
dict set REV_DATA skl_wedge_75   rev_qsys_path        "${WORK_PATH}/skl_wedge_75/${QSYS_SYSTEM_NAME}"

# CPUKBL/KA for ball bonder [no VME, no PCIe UARTs] for EP4CGX75
dict set REV_DATA kbl_ball_75    rev_fpga_dev         "EP4CGX75"
dict set REV_DATA kbl_ball_75    rev_fpga_dev_name    "EP4CGX75DF27C8"
dict set REV_DATA kbl_ball_75    rev_board_name       "CPUKBL"
dict set REV_DATA kbl_ball_75    rev_part_number      "07977-4000-000/08900-4010-000/08900-4010-020"
dict set REV_DATA kbl_ball_75    rev_family           "kbl_ball"
dict set REV_DATA kbl_ball_75    rev_work_path_rel    "kbl_ball_75"
dict set REV_DATA kbl_ball_75    rev_work_path        "${WORK_PATH}/kbl_ball_75"
dict set REV_DATA kbl_ball_75    rev_firmware_path    "${WORK_PATH}/kbl_ball_75/firmware"
dict set REV_DATA kbl_ball_75    rev_qsys_path        "${WORK_PATH}/kbl_ball_75/${QSYS_SYSTEM_NAME}"


################################################################################
# Add the TDOM library path in the search path
################################################################################
if {[lsearch $auto_path ${TDOM_PATH}] < 0} {
    set auto_path [linsert $auto_path 0 ${TDOM_PATH}]
    puts "Adding ${TDOM_PATH} to \$auto_path variable"
} else {
    puts "${TDOM_PATH} already defined in \$auto_path variable"
}


################################################################################
# Get Git commit (assume Git is in system path)
################################################################################
set current_directory [pwd]
cd ${ROOT_PATH}

# Retrieve the GIT SHA1 ID
proc retrieve_git_sha {} {

    # Check dirty tree (modified files)
	set git_cmd "git diff --shortstat"
    puts "Running ${git_cmd}"
	
	if {[catch {exec {*}${git_cmd}} result]} {
        post_message -type critical_warning "While running ${git_cmd} <error: ${result}>"
		return 0
    } elseif {$result != ""} {
        post_message -type critical_warning "GIT dirty tree: $result"
	}

    # Check untracked files
	set git_cmd "git status --porcelain"
    puts "Running ${git_cmd}"
	
	if {[catch {exec {*}${git_cmd}} result]} {
        post_message -type critical_warning "While running ${git_cmd} <error: ${result}>"
		return 0
    } elseif {$result != ""} {
        post_message -type critical_warning "GIT reported untracked files"
	}

	# Retrieve the Git SHA
	set git_cmd "git rev-parse --short=8 HEAD"
	puts "Running ${git_cmd}"
	
	if {[catch {exec {*}${git_cmd}} result]} {
        post_message -type critical_warning "While running ${git_cmd} <error: ${result}>"
        return 0
	} else {
		post_message "Git SHA1: ${result}"
		return ${result}
	}

}

set GIT_COMMIT [retrieve_git_sha]

cd ${current_directory}

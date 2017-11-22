###################################################################################
# File         : setup.tcl
# Description  : Global environment variables for the KVB fpga project. 
#
###################################################################################
set myself [info script]
puts "Running ${myself}"


global ROOT_PATH
 if { [info exists ::env(KVB) ] } {
    # Set the ROOT folder path from a Windows environment variable
    set ROOT_PATH [file normalize $::env(KVB)]
    puts "ROOT_PATH ::env(KVB) -> $ROOT_PATH"
 } else {
    # Set the ROOT folder path from an Hardcoded path
    set ROOT_PATH "D:/work/cpuskl"
    puts "ROOT_PATH -> $ROOT_PATH"
}
puts "Setting the KVB project environment variable"


########################################################################################
# Environment variable
########################################################################################
set FPGA_NAME        "kvb"
set REVMAJOR         "2"                            ; # must be < 655
set REVMINOR         "5"                            ; # must be < 100
set REVISION         "v${REVMAJOR}_${REVMINOR}"
set QUARTUS_VERSION  "quartus17.0"
set QSYS_SYSTEM_NAME "${FPGA_NAME}_system"
set PROJECT_NAME     "${FPGA_NAME}_${REVISION}"
set BOARD_NAME       "CPUSKL"                       ; # no spaces
set PART_NUMBER      "08891-4010-000-00"            ; # no spaces
set GW_VERSION       [expr {${REVMAJOR} * 100 + ${REVMINOR}}]
set QSYS_NAME        "kvb_system"


########################################################################################
# Directory structure
########################################################################################
set QUARTUS_HOME      "$quartus(quartus_rootpath)"
set ARCHIVE_PATH      "${ROOT_PATH}/archive"
set HDL_PATH          "${ROOT_PATH}/design"
set BACKEND_PATH      "${ROOT_PATH}/backend"
set IPCORE_LIB_PATH   "${ROOT_PATH}/ipcores/${QUARTUS_VERSION}"
set TCL_PATH          "${ROOT_PATH}/util/tcl"
set WORK_PATH         "${ROOT_PATH}/quartus/${QUARTUS_VERSION}/${PROJECT_NAME}"
set FIRMWARE_PATH     "${WORK_PATH}/firmwares"
set QSYS_PATH         "${WORK_PATH}/${QSYS_NAME}"
set TDOM_PATH         "${BACKEND_PATH}/tdom/win64/tdom0.8.3"
set ZIP_PATH          "${BACKEND_PATH}/zip/win64/zip3.1c"


########################################################################################
# Add the TDOM library path in the search path
########################################################################################
if {[lsearch $auto_path ${TDOM_PATH}] < 0} {
    set auto_path [linsert $auto_path 0 ${TDOM_PATH}]
    puts "Adding ${TDOM_PATH} to \$auto_path variable"
} else {
    puts "${TDOM_PATH} already defined in \$auto_path variable"
}


###################################################################################
# Get Git commit (assume Git is in system path)
###################################################################################
set current_directory [pwd]
cd ${ROOT_PATH}
set git_get_commit_cmd "git -C ${ROOT_PATH} rev-list --max-count=1 HEAD"
set git_update_index_cmd "git update-index"
set git_check_index_cmd "git diff-index --name-only HEAD"
set git_check_untracked_cmd "git ls-files --exclude-standard --others --exclude-from ${BACKEND_PATH}/gitexclude.txt"
puts "SYSTEM CALL: exec $git_get_commit_cmd"
if {[catch {exec {*}${git_get_commit_cmd}} GIT_COMMIT_LONG] == 0} {
   puts "SYSTEM CALL: exec $git_update_index_cmd"
   exec {*}${git_update_index_cmd}
   puts "SYSTEM CALL: exec $git_check_index_cmd"
   catch {exec {*}${git_check_index_cmd}} GIT_INDEX_CHECK
   if {[llength ${GIT_INDEX_CHECK}] == 0} {
      puts "SYSTEM CALL: exec $git_check_untracked_cmd"
      catch {exec {*}${git_check_untracked_cmd}} GIT_UNTRACKED_CHECK
         if {[llength ${GIT_UNTRACKED_CHECK}] == 0} {
            set GIT_COMMIT [string range $GIT_COMMIT_LONG 0 6]
            puts "GIT_COMMIT =  ${GIT_COMMIT}"
         } else {
         puts "GIT_COMMIT =  0 <untracked files>"
         puts ${GIT_UNTRACKED_CHECK}
         set GIT_COMMIT "0"
         }
   } else {
      puts "GIT_COMMIT =  0 <uncommited changes>"
      puts ${GIT_INDEX_CHECK}
      set GIT_COMMIT "0"
   }
} else {
   puts "GIT_COMMIT =  0 <error: ${GIT_COMMIT_LONG}>"
   set GIT_COMMIT "0"
}
cd ${current_directory}


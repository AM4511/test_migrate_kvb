################################################################################
# File         : check_messages.tcl
# Description  : Check build outputs for key warnings, timing failures, etc.
################################################################################
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


########################################################################################
# Quartus commands
########################################################################################
set REVISION_NAME [get_current_revision [file join ${WORK_PATH} ${PROJECT_NAME}]]


########################################################################################
# Files to process
########################################################################################
set QSYS_REPORT "${QSYS_NAME}_generation.rpt"
set MAP_REPORT "${REVISION_NAME}.map.rpt"
set FIT_REPORT "${REVISION_NAME}.fit.rpt"
set STA_REPORT "${REVISION_NAME}.sta.rpt"

set QSYS_REPORT_FILE [file join ${QSYS_PATH} ${QSYS_REPORT}]
set MAP_REPORT_FILE [file join ${FIRMWARE_PATH} ${MAP_REPORT}]
set FIT_REPORT_FILE [file join ${FIRMWARE_PATH} ${FIT_REPORT}]
set STA_REPORT_FILE [file join ${FIRMWARE_PATH} ${STA_REPORT}]


########################################################################################
# Failure messages (if found check fails)
########################################################################################
set qsys_fail_messages {
    "*stale pipeline*"
}

set map_fail_messages {
    "*critical warning*"
    "*inferring latch*"
}

set fit_fail_messages {
    "*critical warning*"
}

set sta_fail_messages {
    "*critical warning*"
    "*incorrect assignment*"
    "*not fully constrained*"
}


########################################################################################
# Parse messages
########################################################################################
set found_fail 0;

puts ""
puts "Check qsys generation messages \[${QSYS_REPORT}\]"
puts "--------------------------------------------------------------------------------"
set qsys_report_fd [open ${QSYS_REPORT_FILE} r]
set qsys_file [read $qsys_report_fd]
close $qsys_report_fd
set qsys_report [split $qsys_file "\n"]
set line_no 0
foreach line $qsys_report {
    incr line_no
    foreach fail $qsys_fail_messages {
        if {[string match -nocase $fail $line]} {
            puts "$line_no: $line"
            incr found_fail
        }
    }
}

puts ""
puts "Check analysis and synthesis messages \[${MAP_REPORT}\]"
puts "--------------------------------------------------------------------------------"
set map_report_fd [open ${MAP_REPORT_FILE} r]
set map_file [read $map_report_fd]
close $map_report_fd
set map_report [split $map_file "\n"]
set line_no 0
foreach line $map_report {
    incr line_no
    foreach fail $map_fail_messages {
        if {[string match -nocase $fail $line]} {
            puts "$line_no: $line"
            incr found_fail
        }
    }
}

puts ""
puts "Check fitter messages \[${FIT_REPORT}\]"
puts "--------------------------------------------------------------------------------"
set fit_report_fd [open ${FIT_REPORT_FILE} r]
set fit_file [read $fit_report_fd]
close $fit_report_fd
set fit_report [split $fit_file "\n"]
set line_no 0
foreach line $fit_report {
    incr line_no
    foreach fail $fit_fail_messages {
        if {[string match -nocase $fail $line]} {
            puts "$line_no: $line"
            incr found_fail
        }
    }
}

puts ""
puts "Check timing analysis messages \[${STA_REPORT}\]"
puts "--------------------------------------------------------------------------------"
set sta_report_fd [open ${STA_REPORT_FILE} r]
set sta_file [read $sta_report_fd]
close $sta_report_fd
set sta_report [split $sta_file "\n"]
set line_no 0
foreach line $sta_report {
    incr line_no
    foreach fail $sta_fail_messages {
        if {[string match -nocase $fail $line]} {
            puts "$line_no: $line"
            incr found_fail
        }
    }
}

puts ""
if {$found_fail > 0} {
    error "Failed: $found_fail problematic messages found"
} else {
    puts "Passed: no problematic messages found"
}


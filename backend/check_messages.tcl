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
# Quartus commands
########################################################################################
set MAP_REPORT_FILE [file join ${FIRMWARE_PATH} "${REVISION_NAME}.map.rpt"]
set FIT_REPORT_FILE [file join ${FIRMWARE_PATH} "${REVISION_NAME}.fit.rpt"]
set STA_REPORT_FILE [file join ${FIRMWARE_PATH} "${REVISION_NAME}.sta.rpt"]


########################################################################################
# Failure messages (if found check fails)
########################################################################################
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

puts "Check analysis and synthesis messages"
set map_report_fd [open ${MAP_REPORT_FILE} r]
set map_file [read $map_report_fd]
close $map_report_fd
set map_report [split $map_file "\n"]
foreach line $map_report {
    foreach fail $map_fail_messages {
        if {[string match -nocase $fail $line]} {
            puts $line
            incr found_fail
        }
    }
}

puts "Check fitter messages"
set fit_report_fd [open ${FIT_REPORT_FILE} r]
set fit_file [read $fit_report_fd]
close $fit_report_fd
set fit_report [split $fit_file "\n"]
foreach line $fit_report {
    foreach fail $fit_fail_messages {
        if {[string match -nocase $fail $line]} {
            puts $line
            incr found_fail
        }
    }
}

puts "Check timing analysis messages"
set sta_report_fd [open ${STA_REPORT_FILE} r]
set sta_file [read $sta_report_fd]
close $sta_report_fd
set sta_report [split $sta_file "\n"]
foreach line $sta_report {
    foreach fail $sta_fail_messages {
        if {[string match -nocase $fail $line]} {
            puts $line
            incr found_fail
        }
    }
}

if {$found_fail > 0} {
    error "Failed: $found_fail problematic messages found"
} else {
    puts "Passed: no problematic messages found"
}


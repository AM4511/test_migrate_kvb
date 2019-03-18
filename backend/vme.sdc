################################################################################
# File         : vme.sdc
# Description  : Timing constraintes for the vme IP from the KVB FPGA
################################################################################
# All state machine timing is done with 8ns core clk.
#
# Constraints based on the VME Specification using clock cycles and propagation
# delays.
#
#   Parameter 4 - AS* low delay from Address Group stable = 35ns min OR
#                      Address Group setup to AS* falling = 35ns min
#      The state machine delays AS* from the Address Group by 6 clocks (48ns).
#      As long as the min delay of AS* - max delay of A[31:0] + 48ns is > 35ns,
#      timing is good. So, set the max - min delays to 12.9ns (16.4ns - 3.5ns)
set_max_delay -to [get_ports vme_a*] 16.4
set_min_delay -to [get_ports vme_a*] 3.5
set_max_delay -to [get_ports vme_write*] 16.4
set_min_delay -to [get_ports vme_write*] 3.5
set_max_delay -to [get_ports vme_lword_n] 16.4
set_min_delay -to [get_ports vme_lword_n] 3.5
set_max_delay -to [get_ports vme_iack*] 16.4
set_min_delay -to [get_ports vme_iack*] 3.5
#   reduce max delay to 14.0 to cover Parameter 29
set_max_delay -to [get_ports vme_ds*] 14.4
set_min_delay -to [get_ports vme_ds*] 3.5
#
#   Parameter 13 – DS0* to DS1* skew = 10ns max
#      Additionally, include vme_as_n in the skew set to guarantee DS0* and DS1*
#      occur after AS* as long as max skew < 8ns (1 clock period) ==> 7.0ns
set_max_skew -from_clock {u0|pcie_hard_ip_0|*|coreclkout} -to [get_ports {vme_as_n vme_ds*}] 7.0
#
#   Parameter 29 – D[31:0] hold from DS0* or DS1* high = 0ns min
#      Min delay chosen larger to make vme_ds* max minis vme_db* delays less than 1 clock cycle (8ns)
set_max_delay -to [get_ports vme_db*] 24.0
set_min_delay -to [get_ports vme_db*] 7.0
#
# *** Input Timing ***
# The state machine waits for dtack to end a read or write cycle.  When DTACK* is
# detected after syncing it to clk, the avalon read or write cycle will end on
# the next clk cycle.  This allows enough time for read data to settle.
# When the avalon read or write cycle ends the DS0#, DS1# and AS# are then
# deactivated. The timimg constraint below guarantees that the skew between any
# VME input signal will be 3nsec or less.
# This value can be as high as 8ns and still meet the max skew requirements.
set_max_skew -from [get_ports vme*] -to_clock {u0|pcie_hard_ip_0|*|coreclkout} 3.0

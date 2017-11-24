# ##################################################################################
# File         : vme.sdc
# Description  : Timing constraintes for the vme IP from the KVB FPGA
# ##################################################################################

########################################################################################
########################################################################################
####                       VME IO Timing Constraints                                 ###
########################################################################################
########################################################################################
# All state machine timing is done with 8ns core clk.
# The state machine generates the AS# 48ns after the VME data and address. The VME spec is 35ns. 
# The state machine generates the DS# 8ns after AS#.  The VME spec is 0ns.
# The timimg constraint below guarantees that the skew between any VME output signal will be 6nsec or less.
# This value can be as high as 8ns and still meet the max skew requirements.

set_max_skew -from_clock {u0|pcie_hard_ip_0|*|coreclkout} -to [get_ports vme*] 6.0  

# The state machine waits for dtack to end a read or write cycle.  When dtack is detected after syncing it to clk, 
# the avalon read or write cycle will end on the next clk cycle.  This allows enough time for read data to settle.
# When the avalon read or write cycle ends the DS0#, DS1# and AS# are then deactivated.
# The timimg constraint below guarantees that the skew between any VME input signal will be 3nsec or less.
# This value can be as high as 8ns and still meet the max skew requirements.

set_max_skew -from [get_ports vme*] -to_clock {u0|pcie_hard_ip_0|*|coreclkout} 3.0  

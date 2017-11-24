##################################################################################
# File         : kvb.sdc
# Description  : Timing constraintes for the KVB FPGA
#
##################################################################################

# Time unit definition
set_time_format -unit ns -decimal_places 3 


########################################################################################
########################################################################################
###                    Create Reference clocks                                       ###
########################################################################################
########################################################################################
create_clock -name {clkin_125m_p} -period 8.000 -waveform {0.000 4.000} [get_ports {clkin_125m_p}]
create_clock -name {refclk_pcie} -period 10.000 -waveform {0.000 5.000} { refclk }


########################################################################################

#**************************************************************
# Derive PLL Clock
#**************************************************************
derive_pll_clocks
derive_clock_uncertainty


#**************************************************************
# False path
#**************************************************************
set_false_path -from [get_ports {sys_rst_n}]
set_false_path -from [get_registers {altgx_reconfig_inst|*|busy}]


########################################################################################
########################################################################################
####                                  I2C                                            ###
########################################################################################
########################################################################################
## IO timings are managed in verilog based on the src clock period precision.
## For such a slow interface this is sufficient. We lock the input/output FF location 
## of these  IO in the IO Ring using the following assignments
##
## set_instance_assignment -name FAST_INPUT_REGISTER ON -to local_i2c_s*
## set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to local_i2c_s*
##
## in the .qsf file
set_min_delay -to [get_ports {local_i2c_sda}] 0.000
set_max_delay -to [get_ports {local_i2c_sda}] 7.500
set_min_delay -to [get_ports {local_i2c_scl}] 0.000
set_max_delay -to [get_ports {local_i2c_scl}] 7.500

set_min_delay -from [get_ports {local_i2c_sda}] 0.000
set_max_delay -from [get_ports {local_i2c_sda}] 3.500
set_min_delay -from [get_ports {local_i2c_scl}] 0.000
set_max_delay -from [get_ports {local_i2c_scl}] 3.500

# The port local_i2c_sda is resynchronized in MainSM.sdc
# before being used so we can declare it as a false path.
set_false_path -from [get_ports {local_i2c_sda}]

# The port local_i2c_scl is resynchronized in MainSM.sdc
# before being used so we can declare it as a false path.
# !!!!!!!NOTE TO VERIFY!!!! POTENTIAL TIMING ISSUE HERE
# AS divCnt USES A NON RESYNCHRONYZE VERSION OF local_i2c_scl
set_false_path -from [get_ports {local_i2c_scl}]



########################################################################################
########################################################################################
####                      GPIOs                                                      ###
########################################################################################
########################################################################################
set_false_path -from [get_ports {gpio*}]
set_false_path -to [get_ports {gpio*}]


########################################################################################
########################################################################################
####                  cpcis_pcie_clken_n[6:0]                                        ###
########################################################################################
########################################################################################
# On Input: PCIe clken detect. These are static signal
set_false_path -from [get_ports {cpcis_pcie_clken_n*}]
set_false_path -from [get_ports {cpcis_pcie_clken_n*}]

# On Output: sync_clk
set_min_delay -to [get_ports {cpcis_pcie_clken_n*}] 0.000
set_max_delay -to [get_ports {cpcis_pcie_clken_n*}] 5.500

set_false_path -to  [get_ports {cpcis_pcie_clken_n*}] 

########################################################################################
########################################################################################
####                  pch_clk_req_n[*]                                               ###
########################################################################################
########################################################################################
# On Output: sync_clk
set_false_path -to [get_ports {pch_clk_req_n[*]}]


########################################################################################
########################################################################################
####                       cam_trigger[*]                                            ###
########################################################################################
########################################################################################
# Camera triggers are false path. They are resync on input in the Nexis FPGA
set_false_path -to [get_ports {cam_trigger*}]


########################################################################################
########################################################################################
####                       prog_led[*]                                               ###
########################################################################################
########################################################################################
set_false_path -to [get_ports {prog_led_n[*]}]


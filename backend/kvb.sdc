# ##################################################################################
# File         : kvb.sdc
# Description  : Timing constraintes of the KVB FPGA
#
# Example in the Quartus TCL console:
#
# tcl> source "D:/work/cpuskl/backend/create_quartus_project.tcl"
#
# ##################################################################################

#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************
create_clock -name {clkin_125m_p} -period 8.000 -waveform {0.000 4.000} [get_ports {clkin_125m_p}]
create_clock -name {lpc_clk} -period 41.667 -waveform {0.000 20.833} [get_ports {lpc_clk}]
create_clock -name {refclk_pcie} -period 10.000 -waveform {0.000 5.000} { refclk }


#**************************************************************
# Create Generated Clock
#**************************************************************
# The 4 UART reference clocks
create_generated_clock -name {uart_ref_clk_0} -source [get_ports {lpc_clk}] -edges {1 13 27}  [get_registers {u1|\G_UART:0:bridge|uart_clk}] 
create_generated_clock -name {uart_ref_clk_1} -source [get_ports {lpc_clk}] -edges {1 13 27}  [get_registers {u1|\G_UART:1:bridge|uart_clk}] 
create_generated_clock -name {uart_ref_clk_2} -source [get_ports {lpc_clk}] -edges {1 13 27}  [get_registers {u1|\G_UART:2:bridge|uart_clk}] 
create_generated_clock -name {uart_ref_clk_3} -source [get_ports {lpc_clk}] -edges {1 13 27}  [get_registers {u1|\G_UART:3:bridge|uart_clk}] 

# SPI Read clock:  50 MHz/4
# SPI Write clock: 50 MHz/2

#create_generated_clock -name {qspi_rd_clk} -source {reconfig_pll|altpll_component|auto_generated|pll1|clk[0]} -divide_by 4 -multiply_by 1 -invert { u0|qspi_mram_0|qspi_top_inst|llqspi_inst|o_sck|q }
create_generated_clock  -name {qspi_rd_clk} -source {reconfig_pll|altpll_component|auto_generated|pll1|clk[0]} -edges {3 7 11} { u0|qspi_mram_0|qspi_top_inst|llqspi_inst|o_sck|q }


# Create the clock on the FPGA port interface (Keep phase relationship. Better than a virtual clock. Take into account the full round trip from source to destination)
create_generated_clock -name {mram_sck} -source {reconfig_pll|altpll_component|auto_generated|pll1|clk[0]} -divide_by 4 -multiply_by 1 { mram_sck }


#**************************************************************
# Derive PLL Clock
#**************************************************************
derive_pll_clocks
derive_clock_uncertainty


#**************************************************************
# Asynchronous clock domain (False path)
#**************************************************************
set_clock_groups -asynchronous -group {lpc_clk} -group {u0|pcie_hard_ip_0|pcie_internal_hip|cyclone_iii.cycloneiv_hssi_pcie_hip|coreclkout}


#**************************************************************
# False path
#**************************************************************
set_false_path -from [get_ports {sys_rst_n}]


#**************************************************************
# Set input delays
#**************************************************************


########################################################################################
#
# Everspin MR10Q010
# Tcko = tv = Output Valid = 7ns max + (80ns/2) = 47 ns (Data generated on the FALLING EDGE (80ns/2))
#
# Texas Instruments TXB0108
# tpd(A->B) 1.3 ns min; 6.8 ns max
# tpd(B->A) 0.8 ns min; 7.6 ns max
#
# PCB traces delays
# 
# 
# Max Input delay = tmram_sck(KVB->TXB0108->MR10Q010) + Tcko + tpd(MR10Q010->TXB0108->KVB)
#                 = 7.6ns + 47 ns(from falling edge) +  6.8 ns = 61.4 ns
#
# Min Input delay = tmram_sck(KVB->TXB0108->MR10Q010) + Tcko + tpd(MR10Q010->TXB0108->KVB)
#                 = 0.8ns +  47 + 1.3 ns = 49.1 ns
########################################################################################
set MAX_INPUT_DELAY_MRAM_IO 61.4 
set MIN_INPUT_DELAY_MRAM_IO 49.1 

set_input_delay -max -clock { mram_sck } ${MAX_INPUT_DELAY_MRAM_IO} [get_ports {mram_io[*]}]
set_input_delay -min -clock { mram_sck } ${MIN_INPUT_DELAY_MRAM_IO} [get_ports {mram_io[*]}]


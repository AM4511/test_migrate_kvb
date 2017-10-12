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
# Create Reference clocks
#**************************************************************
create_clock -name {clkin_125m_p} -period 8.000 -waveform {0.000 4.000} [get_ports {clkin_125m_p}]
create_clock -name {lpc_clk} -period 41.667 -waveform {0.000 20.833} [get_ports {lpc_clk}]
create_clock -name {refclk_pcie} -period 10.000 -waveform {0.000 5.000} { refclk }


#**************************************************************
# Create UART Generated Clock
#**************************************************************
# The 4 UART reference clocks
create_generated_clock -name {uart_ref_clk_0} -source [get_ports {lpc_clk}] -edges {1 13 27}  [get_registers {u1|\G_UART:0:bridge|uart_clk}] 
create_generated_clock -name {uart_ref_clk_1} -source [get_ports {lpc_clk}] -edges {1 13 27}  [get_registers {u1|\G_UART:1:bridge|uart_clk}] 
create_generated_clock -name {uart_ref_clk_2} -source [get_ports {lpc_clk}] -edges {1 13 27}  [get_registers {u1|\G_UART:2:bridge|uart_clk}] 
create_generated_clock -name {uart_ref_clk_3} -source [get_ports {lpc_clk}] -edges {1 13 27}  [get_registers {u1|\G_UART:3:bridge|uart_clk}] 


#**************************************************************
# Create SPI Generated Clock
#**************************************************************
# SPI Read clock:  50 MHz/4
# SPI Write clock: 50 MHz/2
#
# Note: o_sclk is an inverted clock. Data on falling edge this
#       is why we have to use the option -invert in the
#       create_generated_clock command


set CLK50MHz   {reconfig_pll|altpll_component|auto_generated|pll1|clk[0]}
create_generated_clock -name {qspi_clk_read}  -source $CLK50MHz -divide_by 4 -multiply_by 1 -invert [get_pins { u0|qspi_mram_0|qspi_top_inst|llqspi_inst|o_sck|q }]
create_generated_clock -name {qspi_clk_write} -source $CLK50MHz -divide_by 2 -multiply_by 1 -invert -add [get_pins { u0|qspi_mram_0|qspi_top_inst|llqspi_inst|o_sck|q }]


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
####                       MRAM IO Timing constraints                                ###
########################################################################################
########################################################################################
# SPI Read clock:  50 MHz/4
set MRAM_READ_SCK_PERIOD 80.00
create_clock -name {mram_read_sck_virtual} -period  $MRAM_READ_SCK_PERIOD


# SPI Write clock: 50 MHz/2
set MRAM_WRITE_SCK_PERIOD 40.00
create_clock -name {mram_write_sck_virtual} -period  $MRAM_WRITE_SCK_PERIOD

# Need to remove unrelated clock domain from analysis
set_false_path -from {mram_read_sck_virtual} -to {qspi_clk_write}


########################################################################################
#
# FPGA Clock output delay (T_kvb) 4.40 ns (FlipFlop to mram_sck)
#
# Everspin MR10Q010
# T_cko = tv = Output Valid = 7ns max + (80ns/2) = 47 ns (Data generated on the FALLING EDGE (80ns/2))
#
# Texas Instruments TXB0108
# T_pd(A->B) 1.3 ns min; 6.8 ns max
# T_pd(B->A) 0.8 ns min; 7.6 ns max
# T_sk(O)    0.6 ns max; (Channel to channe skew)
#
# PCB traces delays
#
#
#
#
# Max Input delay = T_kvb   + T_pd(B->A)max  + MR10Q010[Falling edge + T_cko]      + T_pd(A->B)max 
#                 = 4.40 ns + 7.6ns          + ($MRAM_READ_SCK_PERIOD/2   + 7ns  ) +  6.8 ns
#                 = 45.8 ns
#
# Min Input delay = T_kvb   + T_pd(B->A)min  + MR10Q010[Falling edge + T_cko]      + T_pd(A->B)min
#                 = 4.40 ns + 0.8ns          + ($MRAM_READ_SCK_PERIOD/2   + 0ns  ) + 1.3ns
#                 = 26.5 ns
#                
########################################################################################
set MAX_INPUT_DELAY_MRAM_IO 45.8
set MIN_INPUT_DELAY_MRAM_IO 26.5

set_input_delay -max -clock { mram_read_sck_virtual } ${MAX_INPUT_DELAY_MRAM_IO} [get_ports {mram_io[*]}]
set_input_delay -min -clock { mram_read_sck_virtual } ${MIN_INPUT_DELAY_MRAM_IO} [get_ports {mram_io[*]}]


########################################################################################
#
# Everspin MR10Q010
# tsu = 2ns min 
# thold = 5ns min 
#
# Texas Instruments TXB0108
# tpd(A->B) 1.3 ns min; 6.8 ns max
# tpd(B->A) 0.8 ns min; 7.6 ns max
# tsk(O)    0.6 ns max; (Channel to channe skew)
#
# PCB traces delays
# 
# 
# Max output delay = T(data path max) - T(clock path min) 
#                  = (tpd(B->A)max + tsu) - (tpd(B->A)max -  tsk(O))
#                  = (7.6 + 2) - (7.6 - 0.6)
#                  = 2.6 ns
#
# Min output delay = T(data path min) - T(clock path max)
#                  = T_data_path_min + thold - (T_data_path_min + tsk(O))
#                  = (0.8 + 5) - (0.8 + 0.6) 
#                  =  4.4 ns
########################################################################################
set MAX_OUTUT_DELAY 2.6
set MIN_OUTUT_DELAY 4.4

set_output_delay -max -clock { mram_write_sck_virtual } ${MAX_OUTUT_DELAY} [get_ports {mram_io[*]}]
set_output_delay -min -clock { mram_write_sck_virtual } ${MIN_OUTUT_DELAY} [get_ports {mram_io[*]}]

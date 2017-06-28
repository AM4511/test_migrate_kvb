# Create the QSPI clock
# Create the SPI reference clock 

# SPI Read clock:  50 MHz/4
# SPI Write clock: 50 MHz/2
# Note the synthesis invert o_sclk then clock data on falling edge this is why we have to use the option -invert here
create_generated_clock -name {qspi_rd_clk} -source {reconfig_pll|altpll_component|auto_generated|pll1|clk[0]} -divide_by 4 -multiply_by 1 -invert { u0|qspi_mram_0|qspi_top_inst|llqspi_inst|o_sck|q }
#create_generated_clock -name {qspi_rd_clk} -source {reconfig_pll|altpll_component|auto_generated|pll1|clk[0]} -edge {} { u0|qspi_mram_0|qspi_top_inst|llqspi_inst|o_sck|q }


# Create the clock on the FPGA port interface (Keep phase relationship. Better than a virtual clock. Take into account the round trip)
create_generated_clock -name {mram_sck} -source {reconfig_pll|altpll_component|auto_generated|pll1|clk[0]} -divide_by 4 -multiply_by 1 { mram_sck }

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

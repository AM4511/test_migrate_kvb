# ##################################################################################
# File         : qspimram.sdc
# Description  : Timing constraintes for the  QSPI MRAM IP from the KVB FPGA
# ##################################################################################

#**************************************************************
# Create Generated Clock
#**************************************************************
# SPI Read clock:  50 MHz/4
# SPI Write clock: 50 MHz/2
#
# Note: o_sclk is an inverted clock. Data on falling edge this
#       is why we have to use the option -invert in the
#       create_generated_clock command


# Define the source clock point for the MRAM controller
set MRAM_SRC_SCK_PERIOD 20.00
set CLK50MHz   {reconfig_pll|altpll_component|auto_generated|pll1|clk[0]}


# Define the QSPI read clock (Generated clock in the file llqspi.v)
create_generated_clock -name {mram_sck_read}  -source $CLK50MHz -divide_by 4 -invert  -phase 180 -add  [get_pins { u0|qspi_mram_0|qspi_top_inst|llqspi_inst|o_sck|q }]

# Define the write clock (Generated clock in the file llqspi.v)
create_generated_clock -name {mram_sck_write} -source $CLK50MHz -divide_by 2 -invert  -phase 180 -add [get_pins { u0|qspi_mram_0|qspi_top_inst|llqspi_inst|o_sck|q }]

set_clock_groups -asynchronous -group [get_clocks {mram_sck_read}] -group [get_clocks {mram_sck_write}]

# SPI Read clock:  50 MHz/4
set MRAM_READ_SCK_PERIOD [expr $MRAM_SRC_SCK_PERIOD * 4]


# SPI Write clock: 50 MHz/2
set MRAM_WRITE_SCK_PERIOD [expr $MRAM_SRC_SCK_PERIOD * 2]


#**************************************************************
# PORT: mram_cs_n (IO constraints)
#**************************************************************
## mram_cs_n data path
set pcb_delay_mram_cs_n 0.0
set txb0108_tpd_max_B_A 7.6
set txb0108_tpd_min_B_A 0.8
set txb0108_tsk_max     0.6

set mr10q010_tsu_min 5.0
set mr10q010_thold_min 5.0

## mram_cs_n clock path
set pcb_delay_mram_sck 0.0
set mram_sck_delay_min [expr $pcb_delay_mram_sck - $txb0108_tsk_max]
set mram_sck_delay_max [expr $pcb_delay_mram_sck + $txb0108_tsk_max]

set output_delay_max [expr $pcb_delay_mram_cs_n + $mr10q010_tsu_min - $mram_sck_delay_min]
set output_delay_min [expr $pcb_delay_mram_cs_n - $mr10q010_thold_min -  $mram_sck_delay_max]

set_output_delay -clock  mram_sck_write -min [expr $output_delay_min + $MRAM_WRITE_SCK_PERIOD] -reference_pin mram_sck [get_ports {mram_cs_n}]
set_output_delay -clock  mram_sck_write -max $output_delay_max -reference_pin mram_sck [get_ports {mram_cs_n}]

set_output_delay -clock  mram_sck_read -add_delay -min [expr $output_delay_min + $MRAM_READ_SCK_PERIOD] -reference_pin mram_sck [get_ports {mram_cs_n}]
set_output_delay -clock  mram_sck_read -add_delay -max $output_delay_max -reference_pin mram_sck [get_ports {mram_cs_n}]


#**************************************************************
# PORT: mram_io (IO constraints)
#**************************************************************
set pcb_delay_mram_io_max 0.0
set pcb_delay_mram_io_min 0.0
set pcb_delay_mram_sck 0.0

set mr10q010_tco_max 7.0
set mr10q010_tco_min 0.0
set mr10q010_tsu_min 2.0
set mr10q010_thold_min 5.0

set txb0108_tpd_max_B_A 7.6
set txb0108_tpd_min_B_A 0.8
set txb0108_tpd_max_A_B 6.8
set txb0108_tpd_min_A_B 1.3


set input_delay_max [expr $pcb_delay_mram_io_max + $mr10q010_tco_max + $txb0108_tpd_max_B_A + $txb0108_tpd_max_A_B]
set input_delay_min [expr $pcb_delay_mram_io_min - $mr10q010_tco_min + $txb0108_tpd_min_B_A + $txb0108_tpd_min_A_B]

## Read back data generated on falling edge
set_input_delay -max -clock {mram_sck_read} -clock_fall -reference_pin mram_sck ${input_delay_max} [get_ports {mram_io[*]}]
set_input_delay -min -clock {mram_sck_read} -clock_fall -reference_pin mram_sck ${input_delay_min} [get_ports {mram_io[*]}]

set output_delay_max [expr $pcb_delay_mram_io_max + $mr10q010_tsu_min - $mram_sck_delay_min]
set output_delay_min [expr $pcb_delay_mram_io_min - $mr10q010_thold_min - $mram_sck_delay_max]

## write data sampled on rising edge
set_output_delay -max -clock {mram_sck_write} -reference_pin mram_sck ${output_delay_max} [get_ports {mram_io[*]}]
set_output_delay -min -clock {mram_sck_write} -reference_pin mram_sck [expr ${output_delay_min} + $MRAM_WRITE_SCK_PERIOD] [get_ports {mram_io[*]}]

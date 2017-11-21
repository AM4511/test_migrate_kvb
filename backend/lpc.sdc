create_clock -name {lpc_clk} -period 41.667 -waveform {0.000 20.833} [get_ports {lpc_clk}]
derive_pll_clocks
derive_clock_uncertainty


########################################################################################
########################################################################################
####                    LPC UART Generated Clock                                     ###
########################################################################################
########################################################################################
# The 4 UART reference clocks
create_generated_clock -name {uart_ref_clk_0} -source [get_ports {lpc_clk}] -edges {1 13 27}  [get_registers {u1|\G_UART:0:bridge|uart_clk}] 
create_generated_clock -name {uart_ref_clk_1} -source [get_ports {lpc_clk}] -edges {1 13 27}  [get_registers {u1|\G_UART:1:bridge|uart_clk}] 
create_generated_clock -name {uart_ref_clk_2} -source [get_ports {lpc_clk}] -edges {1 13 27}  [get_registers {u1|\G_UART:2:bridge|uart_clk}] 
create_generated_clock -name {uart_ref_clk_3} -source [get_ports {lpc_clk}] -edges {1 13 27}  [get_registers {u1|\G_UART:3:bridge|uart_clk}]


########################################################################################
########################################################################################
####                      UART false paths                                           ###
########################################################################################
set_false_path -from [get_keepers *u1\|\\G_UART:*:uart\|MCR\[4\]*]
set_false_path -from [get_keepers *u1\|\\G_UART:*:uart\|LCR\[6\]*]
set_false_path -from [get_keepers *u1\|\\G_UART:*:uart\|TXD_FF*]


########################################################################################
########################################################################################
####                      LPC  constraints                                           ###
########################################################################################
set pcb_delay_lpc_clk 0.0

## LPC_AD[3:0]
set pch_Tco_lpc_ad_max 0.0
set pch_Tco_lpc_ad_min 0.0
set pch_Tsu_lpc_ad 0.0
set pch_Thold_lpc_ad 0.0
set pcb_delay_lpc_ad_max 0.0
set pcb_delay_lpc_ad_min 0.0


set input_delay_max [expr $pch_Tco_lpc_ad_max + $pcb_delay_lpc_ad_max - $pcb_delay_lpc_clk]
set input_delay_min [expr $pch_Tco_lpc_ad_min + $pcb_delay_lpc_ad_min - $pcb_delay_lpc_clk]

set_input_delay -clock lpc_clk  -max $input_delay_max [get_ports {lpc_ad*}]
set_input_delay -clock lpc_clk  -min $input_delay_min [get_ports {lpc_ad*}]

set output_delay_max [expr $pcb_delay_lpc_ad_max + $pch_Tsu_lpc_ad - $pcb_delay_lpc_clk]
set output_delay_min [expr $pcb_delay_lpc_ad_min - $pch_Thold_lpc_ad - $pcb_delay_lpc_clk]

set_output_delay -clock lpc_clk  -max $output_delay_max [get_ports {lpc_ad*}]
set_output_delay -clock lpc_clk  -min $output_delay_min [get_ports {lpc_ad*}]


## LPC_FRAME
set pch_Tco_lpc_frame_n_max 0.0
set pch_Tco_lpc_frame_n_min 0.0
set pcb_delay_lpc_frame_n 0.0


set input_delay_max [expr $pch_Tco_lpc_frame_n_max + $pcb_delay_lpc_frame_n - $pcb_delay_lpc_clk]
set input_delay_min [expr $pch_Tco_lpc_frame_n_min + $pcb_delay_lpc_frame_n - $pcb_delay_lpc_clk]

set_input_delay -clock lpc_clk  -max $input_delay_max [get_ports {lpc_frame_n}]
set_input_delay -clock lpc_clk  -min $input_delay_min [get_ports {lpc_frame_n}]

## SERIRQ
set pch_Tco_serirq_max 0.0
set pch_Tco_serirq_min 0.0
set pch_Tsu_serirq 0.0
set pch_Thold_serirq 0.0
set pcb_delay_serirq 0.0


set input_delay_max [expr $pch_Tco_serirq_max + $pcb_delay_serirq - $pcb_delay_lpc_clk]
set input_delay_min [expr $pch_Tco_serirq_min + $pcb_delay_serirq - $pcb_delay_lpc_clk]

set_input_delay -clock lpc_clk  -max $input_delay_max [get_ports {serirq}]
set_input_delay -clock lpc_clk  -min $input_delay_min [get_ports {serirq}]

set output_delay_max [expr $pcb_delay_serirq + $pch_Tsu_serirq - $pcb_delay_lpc_clk]
set output_delay_min [expr $pcb_delay_serirq - $pch_Thold_serirq - $pcb_delay_lpc_clk]

set_output_delay -clock lpc_clk  -max $output_delay_max [get_ports {serirq}]
set_output_delay -clock lpc_clk  -min $output_delay_min [get_ports {serirq}]

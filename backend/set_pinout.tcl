set me [info script]
puts "Running ${me}"

####################################################################################
# Define VME Data TRansaction BUS grouping
####################################################################################
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_write_n -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_dtack_n -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_write -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_lword_n -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_ds1_n -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_ds0_n -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_as_n -section_id VME_DTB

set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[31] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[30] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[29] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[28] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[27] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[26] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[25] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[24] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[23] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[22] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[21] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[20] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[19] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[18] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[17] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[16] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[15] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[14] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[13] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[12] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[11] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[10] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[9] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[8] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[7] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[6] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[5] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[4] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[3] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[2] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_a[1] -section_id VME_DTB

set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_am[5] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_am[4] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_am[3] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_am[2] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_am[1] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_am[0] -section_id VME_DTB

set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[31] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[30] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[29] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[28] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[27] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[26] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[25] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[24] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[23] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[22] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[21] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[20] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[19] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[18] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[17] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[16] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[15] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[14] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[13] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[12] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[11] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[10] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[9] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[8] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[7] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[6] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[5] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[4] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[3] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[2] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[1] -section_id VME_DTB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_db[0] -section_id VME_DTB

####################################################################################
# Define VME Priority Interrupt BUS grouping
####################################################################################
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_iackout_n -section_id VME_PIB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_iack_n -section_id VME_PIB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_irq_n[7] -section_id VME_PIB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_irq_n[6] -section_id VME_PIB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_irq_n[5] -section_id VME_PIB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_irq_n[4] -section_id VME_PIB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_irq_n[3] -section_id VME_PIB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_irq_n[2] -section_id VME_PIB
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER vme_irq_n[1] -section_id VME_PIB

####################################################################################
# COM Ports grouping
####################################################################################
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER ser1_tx -section_id COM1
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER ser1_rx -section_id COM1
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER ser2_rx -section_id COM2
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER ser2_tx -section_id COM2
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER ser3_rx -section_id COM3
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER ser3_tx -section_id COM3
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER ser4_tx -section_id COM4
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER ser4_rx -section_id COM4
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER ser4_rts_n -section_id COM4

####################################################################################
# QSPI M-RAM grouping
####################################################################################
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER mram_sck -section_id MRAM
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER mram_cs_n -section_id MRAM
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER mram_io[3] -section_id MRAM
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER mram_io[2] -section_id MRAM
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER mram_io[1] -section_id MRAM
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER mram_io[0] -section_id MRAM

####################################################################################
# I2C grouping
####################################################################################
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER local_i2c_sda -section_id LOCAL_I2C
set_global_assignment -name ASSIGNMENT_GROUP_MEMBER local_i2c_scl -section_id LOCAL_I2C


####################################################################################
# Pin Location Assignment: VME Interface
####################################################################################
set_location_assignment PIN_R17 -to vme_a[1]
set_location_assignment PIN_P18 -to vme_a[2]
set_location_assignment PIN_N18 -to vme_a[3]
set_location_assignment PIN_M18 -to vme_a[4]
set_location_assignment PIN_L15 -to vme_a[5]
set_location_assignment PIN_K15 -to vme_a[6]
set_location_assignment PIN_J17 -to vme_a[7]
set_location_assignment PIN_T18 -to vme_a[8]
set_location_assignment PIN_R18 -to vme_a[9]
set_location_assignment PIN_N17 -to vme_a[10]
set_location_assignment PIN_M17 -to vme_a[11]
set_location_assignment PIN_L18 -to vme_a[12]
set_location_assignment PIN_K16 -to vme_a[13]
set_location_assignment PIN_G18 -to vme_a[14]
set_location_assignment PIN_H16 -to vme_a[15]
set_location_assignment PIN_G17 -to vme_a[16]
set_location_assignment PIN_F18 -to vme_a[17]
set_location_assignment PIN_F17 -to vme_a[18]
set_location_assignment PIN_D17 -to vme_a[19]
set_location_assignment PIN_D18 -to vme_a[20]
set_location_assignment PIN_D16 -to vme_a[21]
set_location_assignment PIN_C16 -to vme_a[22]
set_location_assignment PIN_B18 -to vme_a[23]
set_location_assignment PIN_U18 -to vme_a[24]
set_location_assignment PIN_T17 -to vme_a[25]
set_location_assignment PIN_V17 -to vme_a[26]
set_location_assignment PIN_U16 -to vme_a[27]
set_location_assignment PIN_V18 -to vme_a[28]
set_location_assignment PIN_U15 -to vme_a[29]
set_location_assignment PIN_V15 -to vme_a[30]
set_location_assignment PIN_V16 -to vme_a[31]
set_location_assignment PIN_C18 -to vme_am[0]
set_location_assignment PIN_C17 -to vme_am[1]
set_location_assignment PIN_D15 -to vme_am[2]
set_location_assignment PIN_E18 -to vme_am[3]
set_location_assignment PIN_G16 -to vme_am[4]
set_location_assignment PIN_A18 -to vme_am[5]

set_location_assignment PIN_B16 -to vme_lword_n
set_location_assignment PIN_E16 -to vme_as_n
set_location_assignment PIN_A17 -to vme_ds0_n
set_location_assignment PIN_A15 -to vme_ds1_n
set_location_assignment PIN_B15 -to vme_write_n
set_location_assignment PIN_F16 -to vme_iack_n
set_location_assignment PIN_J16 -to vme_iackout_n
set_location_assignment PIN_C15 -to vme_dtack_n
set_location_assignment PIN_C10 -to vme_write

set_location_assignment PIN_E10 -to vme_db[0]
set_location_assignment PIN_D10 -to vme_db[1]
set_location_assignment PIN_C11 -to vme_db[2]
set_location_assignment PIN_C12 -to vme_db[3]
set_location_assignment PIN_A11 -to vme_db[4]
set_location_assignment PIN_C9 -to vme_db[5]
set_location_assignment PIN_B9 -to vme_db[6]
set_location_assignment PIN_D12 -to vme_db[7]
set_location_assignment PIN_A10 -to vme_db[8]
set_location_assignment PIN_B10 -to vme_db[9]
set_location_assignment PIN_D11 -to vme_db[10]
set_location_assignment PIN_D13 -to vme_db[11]
set_location_assignment PIN_A13 -to vme_db[12]
set_location_assignment PIN_B13 -to vme_db[13]
set_location_assignment PIN_C13 -to vme_db[14]
set_location_assignment PIN_A14 -to vme_db[15]
set_location_assignment PIN_N16 -to vme_db[16]
set_location_assignment PIN_P16 -to vme_db[17]
set_location_assignment PIN_T16 -to vme_db[18]
set_location_assignment PIN_R16 -to vme_db[19]
set_location_assignment PIN_R15 -to vme_db[20]
set_location_assignment PIN_T15 -to vme_db[21]
set_location_assignment PIN_P15 -to vme_db[22]
set_location_assignment PIN_N15 -to vme_db[23]
set_location_assignment PIN_T14 -to vme_db[24]
set_location_assignment PIN_R14 -to vme_db[25]
set_location_assignment PIN_T13 -to vme_db[26]
set_location_assignment PIN_R13 -to vme_db[27]
set_location_assignment PIN_P13 -to vme_db[28]
set_location_assignment PIN_T12 -to vme_db[29]
set_location_assignment PIN_R12 -to vme_db[30]
set_location_assignment PIN_P12 -to vme_db[31]

set_location_assignment PIN_G15 -to vme_irq_n[6]
set_location_assignment PIN_H18 -to vme_irq_n[5]
set_location_assignment PIN_K18 -to vme_irq_n[3]
set_location_assignment PIN_L16 -to vme_irq_n[2]
set_location_assignment PIN_J18 -to vme_irq_n[4]
set_location_assignment PIN_K17 -to vme_irq_n[7]
set_location_assignment PIN_M16 -to vme_irq_n[1]

####################################################################################
# Pin Location Assignment: GPIO interface
####################################################################################
set_location_assignment PIN_N5 -to prog_tp[0]
set_location_assignment PIN_N6 -to prog_tp[1]
set_location_assignment PIN_M7 -to prog_tp[2]
set_location_assignment PIN_N7 -to prog_tp[3]
set_location_assignment PIN_P6 -to prog_tp[4]
set_location_assignment PIN_R7 -to prog_tp[5]
set_location_assignment PIN_T6 -to prog_tp[6]
set_location_assignment PIN_T7 -to prog_tp[7]
set_location_assignment PIN_V8 -to prog_tp[8]
set_location_assignment PIN_R8 -to prog_tp[9]

set_location_assignment PIN_E15 -to gpio[0]
set_location_assignment PIN_C14 -to gpio[2]
set_location_assignment PIN_F15 -to gpio[1]
set_location_assignment PIN_D14 -to gpio[3]

####################################################################################
# Pin Location Assignment: User programmable LED interface
####################################################################################
set_location_assignment PIN_C8 -to prog_led[0]
set_location_assignment PIN_D8 -to prog_led[1]
set_location_assignment PIN_E12 -to prog_led[2]

####################################################################################
# Pin Location Assignment: Camera triggers
####################################################################################
set_location_assignment PIN_V13 -to cam_trigger[0]
set_location_assignment PIN_V14 -to cam_trigger[1]
set_location_assignment PIN_U13 -to cam_trigger[2]
set_location_assignment PIN_U12 -to cam_trigger[3]

####################################################################################
# Pin Location Assignment: UART[3:0] interfaces
####################################################################################
set_location_assignment PIN_U9 -to ser1_tx
set_location_assignment PIN_V9 -to ser1_rx
set_location_assignment PIN_R9 -to ser2_tx
set_location_assignment PIN_T9 -to ser2_rx
set_location_assignment PIN_P10 -to ser3_tx
set_location_assignment PIN_R10 -to ser3_rx
set_location_assignment PIN_U10 -to ser4_tx
set_location_assignment PIN_V10 -to ser4_rx
set_location_assignment PIN_T10 -to ser4_rts_n

####################################################################################
# Pin Location Assignment: MRAM QSPI interface
####################################################################################
set_location_assignment PIN_A5 -to mram_sck
set_location_assignment PIN_B5 -to mram_cs_n
set_location_assignment PIN_A7 -to mram_io[0]
set_location_assignment PIN_B7 -to mram_io[1]
set_location_assignment PIN_B6 -to mram_io[2]
set_location_assignment PIN_A6 -to mram_io[3]

####################################################################################
# Pin Location Assignment: PCIe Gen1 x1 interface
####################################################################################
set_location_assignment PIN_A9 -to sys_rst_n
set_location_assignment PIN_M9 -to refclk
set_location_assignment PIN_T2 -to rx_in0
set_location_assignment PIN_P2 -to tx_out0
set_location_assignment PIN_P1 -to "tx_out0(n)"
set_location_assignment PIN_T1 -to "rx_in0(n)"

## Define buffer type
set_instance_assignment -name IO_STANDARD HCSL -to refclk
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to rx_in0
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to tx_out0

####################################################################################
# Pin Location Assignment: I2C Local interface
####################################################################################
set_location_assignment PIN_D7 -to local_i2c_sda
set_location_assignment PIN_C7 -to local_i2c_scl

####################################################################################
# Pin Location Assignment: Low Pin Count (LPC) interface
####################################################################################
set_location_assignment PIN_V11 -to lpc_clk
set_location_assignment PIN_V12 -to lpc_frame_n
set_location_assignment PIN_U6 -to lpc_ad[0]
set_location_assignment PIN_V6 -to lpc_ad[1]
set_location_assignment PIN_V7 -to lpc_ad[2]
set_location_assignment PIN_U7 -to lpc_ad[3]
set_location_assignment PIN_T8 -to serirq

set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to lpc_ad[3]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to lpc_ad[2]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to lpc_ad[1]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to lpc_ad[0]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to lpc_ad

####################################################################################
# Pin Location Assignment: Misc Pins interface
####################################################################################
set_location_assignment PIN_G10 -to clkin_125m_p
set_location_assignment PIN_D9 -to voltage_alert
set_location_assignment PIN_D6 -to vme_buffer_oe

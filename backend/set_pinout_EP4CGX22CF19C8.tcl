################################################################################
# File         : set_pinout_EP4CGX22CF19C8.tcl
# Description  : Pin assignments for EP4CGX22CF19C8 FPGA
################################################################################
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
set_location_assignment PIN_R17  -to vme_a[1]                  ; # FPGA_VME_A1
set_location_assignment PIN_P18  -to vme_a[2]                  ; # FPGA_VME_A2
set_location_assignment PIN_N18  -to vme_a[3]                  ; # FPGA_VME_A3
set_location_assignment PIN_M18  -to vme_a[4]                  ; # FPGA_VME_A4
set_location_assignment PIN_L15  -to vme_a[5]                  ; # FPGA_VME_A5
set_location_assignment PIN_K15  -to vme_a[6]                  ; # FPGA_VME_A6
set_location_assignment PIN_J17  -to vme_a[7]                  ; # FPGA_VME_A7
set_location_assignment PIN_T18  -to vme_a[8]                  ; # FPGA_VME_A8
set_location_assignment PIN_R18  -to vme_a[9]                  ; # FPGA_VME_A9
set_location_assignment PIN_N17  -to vme_a[10]                 ; # FPGA_VME_A10
set_location_assignment PIN_M17  -to vme_a[11]                 ; # FPGA_VME_A11
set_location_assignment PIN_L18  -to vme_a[12]                 ; # FPGA_VME_A12
set_location_assignment PIN_K16  -to vme_a[13]                 ; # FPGA_VME_A13
set_location_assignment PIN_G18  -to vme_a[14]                 ; # FPGA_VME_A14
set_location_assignment PIN_H16  -to vme_a[15]                 ; # FPGA_VME_A15
set_location_assignment PIN_G17  -to vme_a[16]                 ; # FPGA_VME_A16
set_location_assignment PIN_F18  -to vme_a[17]                 ; # FPGA_VME_A17
set_location_assignment PIN_F17  -to vme_a[18]                 ; # FPGA_VME_A18
set_location_assignment PIN_D17  -to vme_a[19]                 ; # FPGA_VME_A19
set_location_assignment PIN_D18  -to vme_a[20]                 ; # FPGA_VME_A20
set_location_assignment PIN_D16  -to vme_a[21]                 ; # FPGA_VME_A21
set_location_assignment PIN_C16  -to vme_a[22]                 ; # FPGA_VME_A22
set_location_assignment PIN_B18  -to vme_a[23]                 ; # FPGA_VME_A23
set_location_assignment PIN_U18  -to vme_a[24]                 ; # FPGA_VME_A24
set_location_assignment PIN_T17  -to vme_a[25]                 ; # FPGA_VME_A25
set_location_assignment PIN_V17  -to vme_a[26]                 ; # FPGA_VME_A26
set_location_assignment PIN_U16  -to vme_a[27]                 ; # FPGA_VME_A27
set_location_assignment PIN_V18  -to vme_a[28]                 ; # FPGA_VME_A28
set_location_assignment PIN_U15  -to vme_a[29]                 ; # FPGA_VME_A29
set_location_assignment PIN_V15  -to vme_a[30]                 ; # FPGA_VME_A30
set_location_assignment PIN_V16  -to vme_a[31]                 ; # FPGA_VME_A31
set_location_assignment PIN_C18  -to vme_am[0]                 ; # FPGA_VME_AM0
set_location_assignment PIN_C17  -to vme_am[1]                 ; # FPGA_VME_AM1
set_location_assignment PIN_D15  -to vme_am[2]                 ; # FPGA_VME_AM2
set_location_assignment PIN_E18  -to vme_am[3]                 ; # FPGA_VME_AM3
set_location_assignment PIN_G16  -to vme_am[4]                 ; # FPGA_VME_AM4
set_location_assignment PIN_A18  -to vme_am[5]                 ; # FPGA_VME_AM5

set_location_assignment PIN_B16  -to vme_lword_n               ; # FPGA_VME_LWORD_N
set_location_assignment PIN_E16  -to vme_as_n                  ; # FPGA_VME_AS_N
set_location_assignment PIN_A17  -to vme_ds0_n                 ; # FPGA_VME_DS0_N
set_location_assignment PIN_A15  -to vme_ds1_n                 ; # FPGA_VME_DS1_N
set_location_assignment PIN_B15  -to vme_write_n               ; # FPGA_VME_WRITE_N
set_location_assignment PIN_F16  -to vme_iack_n                ; # FPGA_VME_IACK_N
set_location_assignment PIN_J16  -to vme_iackout_n             ; # FPGA_VME_IACKOUT_N
set_location_assignment PIN_C15  -to vme_dtack_n               ; # FPGA_VME_DTACK_N
set_location_assignment PIN_C10  -to vme_write                 ; # FPGA_VME_WRITE

set_location_assignment PIN_E10  -to vme_db[0]                 ; # FPGA_VME_D0
set_location_assignment PIN_D10  -to vme_db[1]                 ; # FPGA_VME_D1
set_location_assignment PIN_C11  -to vme_db[2]                 ; # FPGA_VME_D2
set_location_assignment PIN_C12  -to vme_db[3]                 ; # FPGA_VME_D3
set_location_assignment PIN_A11  -to vme_db[4]                 ; # FPGA_VME_D4
set_location_assignment PIN_C9   -to vme_db[5]                 ; # FPGA_VME_D5
set_location_assignment PIN_B9   -to vme_db[6]                 ; # FPGA_VME_D6
set_location_assignment PIN_D12  -to vme_db[7]                 ; # FPGA_VME_D7
set_location_assignment PIN_A10  -to vme_db[8]                 ; # FPGA_VME_D8
set_location_assignment PIN_B10  -to vme_db[9]                 ; # FPGA_VME_D9
set_location_assignment PIN_D11  -to vme_db[10]                ; # FPGA_VME_D10
set_location_assignment PIN_D13  -to vme_db[11]                ; # FPGA_VME_D11
set_location_assignment PIN_A13  -to vme_db[12]                ; # FPGA_VME_D12
set_location_assignment PIN_B13  -to vme_db[13]                ; # FPGA_VME_D13
set_location_assignment PIN_C13  -to vme_db[14]                ; # FPGA_VME_D14
set_location_assignment PIN_A14  -to vme_db[15]                ; # FPGA_VME_D15
set_location_assignment PIN_N16  -to vme_db[16]                ; # FPGA_VME_D16
set_location_assignment PIN_P16  -to vme_db[17]                ; # FPGA_VME_D17
set_location_assignment PIN_T16  -to vme_db[18]                ; # FPGA_VME_D18
set_location_assignment PIN_R16  -to vme_db[19]                ; # FPGA_VME_D19
set_location_assignment PIN_R15  -to vme_db[20]                ; # FPGA_VME_D20
set_location_assignment PIN_T15  -to vme_db[21]                ; # FPGA_VME_D21
set_location_assignment PIN_P15  -to vme_db[22]                ; # FPGA_VME_D22
set_location_assignment PIN_N15  -to vme_db[23]                ; # FPGA_VME_D23
set_location_assignment PIN_T14  -to vme_db[24]                ; # FPGA_VME_D24
set_location_assignment PIN_R14  -to vme_db[25]                ; # FPGA_VME_D25
set_location_assignment PIN_T13  -to vme_db[26]                ; # FPGA_VME_D26
set_location_assignment PIN_R13  -to vme_db[27]                ; # FPGA_VME_D27
set_location_assignment PIN_P13  -to vme_db[28]                ; # FPGA_VME_D28
set_location_assignment PIN_T12  -to vme_db[29]                ; # FPGA_VME_D29
set_location_assignment PIN_R12  -to vme_db[30]                ; # FPGA_VME_D30
set_location_assignment PIN_P12  -to vme_db[31]                ; # FPGA_VME_D31

set_location_assignment PIN_M16  -to vme_irq_n[1]              ; # FPGA_VME_IRQ1_N
set_location_assignment PIN_L16  -to vme_irq_n[2]              ; # FPGA_VME_IRQ2_N
set_location_assignment PIN_K18  -to vme_irq_n[3]              ; # FPGA_VME_IRQ3_N
set_location_assignment PIN_J18  -to vme_irq_n[4]              ; # FPGA_VME_IRQ4_N
set_location_assignment PIN_H18  -to vme_irq_n[5]              ; # FPGA_VME_IRQ5_N
set_location_assignment PIN_G15  -to vme_irq_n[6]              ; # FPGA_VME_IRQ6_N
set_location_assignment PIN_K17  -to vme_irq_n[7]              ; # FPGA_VME_IRQ7_N



####################################################################################
# VME FPGA pin	Current usage	New usage                Comment
####################################################################################
# PIN_C14	User input 2	User input 2 -> I/O
# PIN_F15	User input 1	User input 1 -> I/O
# PIN_D14	User input 3	User input 3 -> I/O
# PIN_E15	User input 0	User input 0 -> I/O
# PIN_N7	User output 3	cpcis_pcie_clken_n4
# PIN_M7	User output 2	cpcis_pcie_clken_n3
# PIN_P6	User output 4	pcie_cke_n5
# PIN_T6	User output 6	pcie_cke_n2
# PIN_T7	User output 7	pcie_cke_n1
# PIN_R7	User output 5	cpcis_pcie_clken_n5
# PIN_N5	User output 0	pcie_cke_n3
# PIN_N6	User output 1	pcie_cke_n4
# PIN_V8	User output 8	cpcis_pcie_clken_n0
# PIN_R8	User output 9	cpcis_pcie_clken_n6
# PIN_R6	Unused	        pcie_cke_n6
# PIN_V5	Unused	        pcie_cke_n0
# PIN_R11	Unused	        cpcis_pcie_clken_n2
# PIN_T11	Unused	        cpcis_pcie_clken_n1
# PIN_E6	Unused	        Unused -> I/O ?
# PIN_C6	Unused	        Unused -> I/O ?
# PIN_A8	Unused	        Unused -> I/O ?
# PIN_A16	Unused	        Unused -> I/O ?
# PIN_A12	Unused	        Unused	                 Input direction only
# PIN_B12	Unused      	Unused                   Input direction only
# PIN_G9	Unused	        power_failure_n          Input direction only

#############################################################################
# PCIe Clock enable
#############################################################################
set_location_assignment PIN_V8   -to cpcis_pcie_clken_n[0]     ; # CPCI_2_PE_CKE_N
set_location_assignment PIN_T11  -to cpcis_pcie_clken_n[1]     ; # CPCI_3_PE_CKE_N
set_location_assignment PIN_R11  -to cpcis_pcie_clken_n[2]     ; # CPCI_4_PE_CKE_N
set_location_assignment PIN_M7   -to cpcis_pcie_clken_n[3]     ; # CPCI_5_PE_CKE_N
set_location_assignment PIN_N7   -to cpcis_pcie_clken_n[4]     ; # CPCI_6_PE_CKE_N
set_location_assignment PIN_R7   -to cpcis_pcie_clken_n[5]     ; # CPCI_7_PE_CKE_N
set_location_assignment PIN_R8   -to cpcis_pcie_clken_n[6]     ; # CPCI_8_PE_CKE_N

# Pcie clock enable
set_location_assignment PIN_V5   -to pch_clk_req_n[0]          ; # PE_CLKREQ2_N
set_location_assignment PIN_T7   -to pch_clk_req_n[1]          ; # PE_CLKREQ3_N
set_location_assignment PIN_T6   -to pch_clk_req_n[2]          ; # PE_CLKREQ4_N
set_location_assignment PIN_N5   -to pch_clk_req_n[3]          ; # PE_CLKREQ5_N
set_location_assignment PIN_N6   -to pch_clk_req_n[4]          ; # PE_CLKREQ6_N
set_location_assignment PIN_P6   -to pch_clk_req_n[5]          ; # PE_CLKREQ7_N
set_location_assignment PIN_R6   -to pch_clk_req_n[6]          ; # PE_CLKREQ8_N


#############################################################################
# GPIO
#############################################################################
set_location_assignment PIN_E15  -to gpio[0]                   ; # GPIO0
set_location_assignment PIN_F15  -to gpio[1]                   ; # GPIO1
set_location_assignment PIN_C14  -to gpio[2]                   ; # GPIO2
set_location_assignment PIN_D14  -to gpio[3]                   ; # GPIO3
set_location_assignment PIN_A8   -to gpio[4]                   ; # GPIO4
set_location_assignment PIN_A16  -to gpio[5]                   ; # GPIO5
set_location_assignment PIN_C6   -to gpio[6]                   ; # GPIO6
set_location_assignment PIN_E6   -to gpio[7]                   ; # GPIO7

####################################################################################
# Pin Location Assignment: User programmable LED interface
####################################################################################
set_location_assignment PIN_C8   -to prog_led_n[0]             ; # USER_LED0
set_location_assignment PIN_D8   -to prog_led_n[1]             ; # USER_LED1
set_location_assignment PIN_E12  -to prog_led_n[2]             ; # USER_LED2

####################################################################################
# Pin Location Assignment: Camera triggers
####################################################################################
set_location_assignment PIN_V13  -to cam_trigger[0]            ; # VME_H1_TRIG
set_location_assignment PIN_V14  -to cam_trigger[1]            ; # VME_H2_TRIG
set_location_assignment PIN_U13  -to cam_trigger[2]            ; # VME_H3_TRIG
set_location_assignment PIN_U12  -to cam_trigger[3]            ; # VME_H4_TRIG

####################################################################################
# Pin Location Assignment: UART[3:0] interfaces
####################################################################################
set_location_assignment PIN_U9   -to ser1_tx                   ; # FPGA_TXD1
set_location_assignment PIN_V9   -to ser1_rx                   ; # FPGA_RXD1
set_location_assignment PIN_R9   -to ser2_tx                   ; # FPGA_TXD2
set_location_assignment PIN_T9   -to ser2_rx                   ; # FPGA_RXD2
set_location_assignment PIN_P10  -to ser3_tx                   ; # FPGA_TXD3
set_location_assignment PIN_R10  -to ser3_rx                   ; # FPGA_RXD3
set_location_assignment PIN_U10  -to ser4_tx                   ; # FPGA_TXD4
set_location_assignment PIN_V10  -to ser4_rx                   ; # FPGA_RXD4
set_location_assignment PIN_T10  -to ser4_rts_n                ; # FPGA_RTS4_N

####################################################################################
# Pin Location Assignment: MRAM QSPI interface
####################################################################################
set_location_assignment PIN_A5   -to mram_sck                  ; # FPGA_MRAM_SCK
set_location_assignment PIN_B5   -to mram_cs_n                 ; # FPGA_MRAM_CS_N
set_location_assignment PIN_A7   -to mram_io[0]                ; # FPGA_MRAM_I0
set_location_assignment PIN_B7   -to mram_io[1]                ; # FPGA_MRAM_I1
set_location_assignment PIN_B6   -to mram_io[2]                ; # FPGA_MRAM_I2
set_location_assignment PIN_A6   -to mram_io[3]                ; # FPGA_MRAM_I3

####################################################################################
# Pin Location Assignment: PCIe Gen1 x1 interface
####################################################################################
set_location_assignment PIN_A9   -to sys_rst_n                 ; # PLTRST_PCIE_SLOTS_N
set_location_assignment PIN_M9   -to refclk                    ; # VME_PE_CK_DP
set_location_assignment PIN_M10  -to "refclk(n)"               ; # VME_PE_CK_DN
set_location_assignment PIN_T2   -to rx_in0                    ; # VME_PERP0
set_location_assignment PIN_T1   -to "rx_in0(n)"               ; # VME_PERN0
set_location_assignment PIN_P2   -to tx_out0                   ; # VME_PETP0
set_location_assignment PIN_P1   -to "tx_out0(n)"              ; # VME_PETN0

## Define buffer type
set_instance_assignment -name IO_STANDARD HCSL  -to refclk
set_instance_assignment -name IO_STANDARD "1.5-V PCML"  -to rx_in0
set_instance_assignment -name IO_STANDARD "1.5-V PCML"  -to tx_out0

####################################################################################
# Pin Location Assignment: I2C Local interface
####################################################################################
set_location_assignment PIN_D7   -to local_i2c_sda             ; # FPGA_I2C_DATA
set_location_assignment PIN_C7   -to local_i2c_scl             ; # FPGA_I2C_CLK

####################################################################################
# Pin Location Assignment: Low Pin Count (LPC) interface
####################################################################################
set_location_assignment PIN_V11  -to lpc_clk                   ; # LPCCLK0_24M
set_location_assignment PIN_V12  -to lpc_frame_n               ; # LPC_FRAME_N
set_location_assignment PIN_U6   -to lpc_ad[0]                 ; # L_AD0
set_location_assignment PIN_V6   -to lpc_ad[1]                 ; # L_AD1
set_location_assignment PIN_V7   -to lpc_ad[2]                 ; # L_AD2
set_location_assignment PIN_U7   -to lpc_ad[3]                 ; # L_AD3
set_location_assignment PIN_T8   -to serirq                    ; # INT_SERIRQ

set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON  -to lpc_ad[3]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON  -to lpc_ad[2]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON  -to lpc_ad[1]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON  -to lpc_ad[0]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON  -to lpc_ad

####################################################################################
# Pin Location Assignment: Misc Pins interface
####################################################################################
set_location_assignment PIN_G10  -to clkin_125m_p
set_location_assignment PIN_D9   -to voltage_alert
set_location_assignment PIN_D6   -to vme_buffer_oe
set_location_assignment PIN_G9   -to power_failure_n

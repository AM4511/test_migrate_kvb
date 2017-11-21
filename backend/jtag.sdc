########################################################################################
# The following constraints are retrieved from:
#
# https://www.altera.com/support/support-resources/knowledge-base/solutions/rd02172015_590.html
#
#
# How can I constrain the timing of the Serial Flash Loader (SFL) IP in Cyclone III
# and Cyclone IV devices?
#
# Description
#
# When programming a Serial Configuration (EPCS) device, a Quad-Serial Configuration (EPCQ)
# device with the Serial Flash Loader (SFL) IP in Cyclone® III and Cyclone IV devices,
# you can use the following .SDC constraints to correctly timing constrain the SFL. 
#
# Note that you need to modify signal names, paths and timings according to your design,
# configuration device and board trace lengths.
#
########################################################################################
#clock

derive_clock_uncertainty

create_generated_clock -name {altera_dclk} -source [get_ports {altera_reserved_tck}] -master_clock {altera_reserved_tck} [get_ports {sfl|serial_flash_loader_0|altserial_flash_loader_component|\GEN_ASMI_TYPE_1:asmi_inst~ALTERA_DCLK}]


# constrain JTAG port
set_input_delay -clock altera_reserved_tck 20 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck 20 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck 20 [get_ports altera_reserved_tdo]


# ASMI port
set_output_delay -add_delay  -clock [get_clocks {altera_dclk}]  13.000 [get_ports {sfl|serial_flash_loader_0|altserial_flash_loader_component|\GEN_ASMI_TYPE_1:asmi_inst~ALTERA_SCE}]
set_output_delay -add_delay  -clock [get_clocks {altera_dclk}]  8.000 [get_ports {sfl|serial_flash_loader_0|altserial_flash_loader_component|\GEN_ASMI_TYPE_1:asmi_inst~ALTERA_SDO}]
set_input_delay -add_delay  -clock [get_clocks {altera_dclk}]  11.000 [get_ports {sfl|serial_flash_loader_0|altserial_flash_loader_component|\GEN_ASMI_TYPE_1:asmi_inst~ALTERA_DATA0}]

 

#Remove clock groups set by Time Quest 
#remove_clock_groups -all

 

#Set False Path
set_false_path -from [get_ports {altera_reserved_tck}] -to [get_keepers {sfl|serial_flash_loader_0|altserial_flash_loader_component|\GEN_ASMI_TYPE_1:asmi_inst~ALTERA_DCLK}]
set_false_path -from [get_keepers {sfl|serial_flash_loader_0|altserial_flash_loader_component|alt_sfl_enhanced:\ENHANCED_PGM:sfl_inst_enhanced|device_dclk_en_reg}] -to [get_ports {sfl|serial_flash_loader_0|altserial_flash_loader_component|\GEN_ASMI_TYPE_1:asmi_inst~ALTERA_DCLK}]

 

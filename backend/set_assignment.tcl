set me [info script]
puts "Running ${me}"

####################################################################################
#
####################################################################################
set_global_assignment -name DEVICE EP4CGX22CF19C8
set_global_assignment -name FAMILY "Cyclone IV GX"
set_global_assignment -name TOP_LEVEL_ENTITY cpuskl_kvb_top
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY $FIRMWARE_PATH
set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
set_global_assignment -name EDA_SIMULATION_TOOL "<None>"
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT NONE -section_id eda_simulation
set_global_assignment -name ROUTER_CLOCKING_TOPOLOGY_ANALYSIS ON
set_global_assignment -name PRE_MAPPING_RESYNTHESIS ON
set_global_assignment -name ADVANCED_PHYSICAL_OPTIMIZATION ON
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
set_global_assignment -name CYCLONEII_OPTIMIZATION_TECHNIQUE SPEED
set_global_assignment -name ACTIVE_SERIAL_CLOCK FREQ_40MHZ
set_global_assignment -name PHYSICAL_SYNTHESIS_ASYNCHRONOUS_SIGNAL_PIPELINING ON
set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "NO HEAT SINK WITH STILL AIR"
set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
set_global_assignment -name RESERVE_ALL_UNUSED_PINS_WEAK_PULLUP "AS INPUT TRI-STATED"
set_global_assignment -name OPTIMIZATION_TECHNIQUE SPEED
set_global_assignment -name SYNTH_TIMING_DRIVEN_SYNTHESIS ON
set_global_assignment -name OPTIMIZE_POWER_DURING_SYNTHESIS OFF
set_global_assignment -name OPTIMIZE_HOLD_TIMING "ALL PATHS"
set_global_assignment -name OPTIMIZE_MULTI_CORNER_TIMING ON
set_global_assignment -name OPTIMIZE_POWER_DURING_FITTING OFF
set_global_assignment -name FITTER_EFFORT "STANDARD FIT"
set_global_assignment -name UNIPHY_SEQUENCER_DQS_CONFIG_ENABLE ON
set_global_assignment -name ECO_REGENERATE_REPORT ON
set_global_assignment -name PHYSICAL_SYNTHESIS_COMBO_LOGIC ON
set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_RETIMING ON
set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON
set_global_assignment -name SEED 2
set_global_assignment -name ENABLE_SIGNALTAP OFF
set_global_assignment -name TIMEQUEST_MULTICORNER_ANALYSIS ON
set_global_assignment -name SMART_RECOMPILE OFF
set_global_assignment -name USE_CONFIGURATION_DEVICE OFF
set_global_assignment -name ON_CHIP_BITSTREAM_DECOMPRESSION OFF
set_global_assignment -name OUTPUT_IO_TIMING_NEAR_END_VMEAS "HALF VCCIO" -rise
set_global_assignment -name OUTPUT_IO_TIMING_NEAR_END_VMEAS "HALF VCCIO" -fall
set_global_assignment -name OUTPUT_IO_TIMING_FAR_END_VMEAS "HALF SIGNAL SWING" -rise
set_global_assignment -name OUTPUT_IO_TIMING_FAR_END_VMEAS "HALF SIGNAL SWING" -fall
set_global_assignment -name USE_DLL_FREQUENCY_FOR_DQS_DELAY_CHAIN ON
set_global_assignment -name SEARCH_PATH $FIRMWARE_PATH/ -tag from_archive
set_global_assignment -name ENABLE_CONFIGURATION_PINS OFF
set_global_assignment -name ENABLE_NCE_PIN OFF
set_global_assignment -name ENABLE_BOOT_SEL_PIN OFF
set_global_assignment -name DEVICE_FILTER_PACKAGE FBGA
set_global_assignment -name DEVICE_FILTER_PIN_COUNT 324
set_global_assignment -name DEVICE_FILTER_SPEED_GRADE 8
set_global_assignment -name DEVICE_MIGRATION_LIST "EP4CGX22CF19C8,EP4CGX30CF19C8"
set_global_assignment -name FLOW_ENABLE_IO_ASSIGNMENT_ANALYSIS ON
set_global_assignment -name PROJECT_SHOW_ENTITY_NAME OFF
set_global_assignment -name PHYSICAL_SYNTHESIS_COMBO_LOGIC_FOR_AREA ON
set_global_assignment -name POWER_USE_TA_VALUE 50
set_global_assignment -name FLOW_ENABLE_POWER_ANALYZER ON
set_global_assignment -name POWER_DEFAULT_TOGGLE_RATE "25 %"
set_global_assignment -name POWER_DEFAULT_INPUT_IO_TOGGLE_RATE "25 %"
set_global_assignment -name POWER_USE_PVA OFF
set_global_assignment -name POWER_REPORT_SIGNAL_ACTIVITY ON
set_global_assignment -name NUM_PARALLEL_PROCESSORS 4
set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
set_global_assignment -name ENABLE_INIT_DONE_OUTPUT OFF
set_global_assignment -name ENABLE_OCT_DONE OFF
set_global_assignment -name STRATIXV_CONFIGURATION_SCHEME "PASSIVE SERIAL"	

set_global_assignment -name CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_DATA0_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_DATA1_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_FLASH_NCE_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_DCLK_AFTER_CONFIGURATION "USE AS REGULAR IO"

# Including default assignments
set_global_assignment -name TIMEQUEST_REPORT_WORST_CASE_TIMING_PATHS ON -family "Cyclone IV GX"
set_global_assignment -name TIMEQUEST_CCPP_TRADEOFF_TOLERANCE 0 -family "Cyclone IV GX"
set_global_assignment -name TDC_CCPP_TRADEOFF_TOLERANCE 0 -family "Cyclone IV GX"
set_global_assignment -name TIMEQUEST_DO_CCPP_REMOVAL ON -family "Cyclone IV GX"
set_global_assignment -name TIMEQUEST_SPECTRA_Q OFF -family "Cyclone IV GX"
set_global_assignment -name SYNCHRONIZATION_REGISTER_CHAIN_LENGTH 2 -family "Cyclone IV GX"
set_global_assignment -name SYNTH_RESOURCE_AWARE_INFERENCE_FOR_BLOCK_RAM ON -family "Cyclone IV GX"
set_global_assignment -name AUTO_DELAY_CHAINS ON -family "Cyclone IV GX"

# Output files to generate assignments
set_global_assignment -name GENERATE_RBF_FILE ON
set_global_assignment -name GENERATE_SVF_FILE ON
set_global_assignment -name GENERATE_JAM_FILE ON
set_global_assignment -name GENERATE_JBC_FILE ON

# Script to run during the flow
set_global_assignment -name PRE_FLOW_SCRIPT_FILE quartus_sh:${PRE_FLOW_SCRIPT_FILE}
# set_global_assignment -name POST_MODULE_SCRIPT_FILE quartus_sh:next.tcl
set_global_assignment -name POST_FLOW_SCRIPT_FILE quartus_sh:${POST_FLOW_SCRIPT_FILE}

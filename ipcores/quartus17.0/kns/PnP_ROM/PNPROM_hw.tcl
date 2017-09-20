# TCL File Generated by Component Editor 14.0
# Thu Apr 14 16:13:25 EDT 2016
# DO NOT MODIFY


# 
# PnPROM "PnP ROM" v1.1
# Ken Paist 2016.04.14.16:13:25
# PCIe Plug-N-Play board info ROM
# 

# 
# request TCL package from ACDS 14.0
# 
package require -exact qsys 14.0


# 
# module PnPROM
# 
set_module_property DESCRIPTION "PCIe Plug-N-Play board info ROM"
set_module_property NAME PnPROM
set_module_property VERSION 1.2
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR "Ken Paist"
set_module_property DISPLAY_NAME "PnP ROM"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL PnPROM
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE true
add_fileset_file PnPROM.v VERILOG PATH ./design/PnPROM.v TOP_LEVEL_FILE


# 
# parameters
# 
add_parameter dev_name STRING BoardName ""
set_parameter_property dev_name DEFAULT_VALUE BoardName
set_parameter_property dev_name DISPLAY_NAME "Board name"
set_parameter_property dev_name WIDTH ""
set_parameter_property dev_name TYPE STRING
set_parameter_property dev_name UNITS None
set_parameter_property dev_name DESCRIPTION ""
set_parameter_property dev_name AFFECTS_GENERATION false
add_parameter part_num STRING 0xxxx-4xxx-000-xx ""
set_parameter_property part_num DEFAULT_VALUE 0xxxx-4xxx-000-xx
set_parameter_property part_num DISPLAY_NAME "Part number"
set_parameter_property part_num WIDTH ""
set_parameter_property part_num TYPE STRING
set_parameter_property part_num UNITS None
set_parameter_property part_num DESCRIPTION ""
set_parameter_property part_num AFFECTS_GENERATION false
add_parameter gw_ver INTEGER 0 ""
set_parameter_property gw_ver DEFAULT_VALUE 0
set_parameter_property gw_ver DISPLAY_NAME "Gateware version"
set_parameter_property gw_ver WIDTH ""
set_parameter_property gw_ver TYPE INTEGER
set_parameter_property gw_ver UNITS None
set_parameter_property gw_ver ALLOWED_RANGES 0:2147483647
set_parameter_property gw_ver DESCRIPTION ""
set_parameter_property gw_ver AFFECTS_GENERATION false
add_parameter git_commit INTEGER 0 ""
set_parameter_property git_commit DEFAULT_VALUE 0
set_parameter_property git_commit DISPLAY_NAME "Git commit"
set_parameter_property git_commit WIDTH ""
set_parameter_property git_commit TYPE INTEGER
set_parameter_property git_commit UNITS None
set_parameter_property git_commit DISPLAY_HINT "hexadecimal"
set_parameter_property git_commit ALLOWED_RANGES 0:268435455
set_parameter_property git_commit DESCRIPTION ""
set_parameter_property git_commit AFFECTS_GENERATION false
add_parameter build_id INTEGER 0 ""
set_parameter_property build_id DEFAULT_VALUE 0
set_parameter_property build_id DISPLAY_NAME "Build ID"
set_parameter_property build_id WIDTH ""
set_parameter_property build_id TYPE INTEGER
set_parameter_property build_id UNITS None
set_parameter_property build_id ALLOWED_RANGES 0:2147483647
set_parameter_property build_id DESCRIPTION ""
set_parameter_property build_id AFFECTS_GENERATION false
add_parameter INIT_FILE STRING ./design/PnP_ROM.hex
set_parameter_property INIT_FILE DEFAULT_VALUE ./design/PnP_ROM.hex
set_parameter_property INIT_FILE DISPLAY_NAME "Init file"
set_parameter_property INIT_FILE TYPE STRING
set_parameter_property INIT_FILE UNITS None
set_parameter_property INIT_FILE HDL_PARAMETER true


# 
# display items
# 


# 
# connection point avalon_slave_0
# 
add_interface avalon_slave_0 avalon end
set_interface_property avalon_slave_0 addressUnits WORDS
set_interface_property avalon_slave_0 associatedClock clock
set_interface_property avalon_slave_0 associatedReset reset
set_interface_property avalon_slave_0 bitsPerSymbol 8
set_interface_property avalon_slave_0 burstOnBurstBoundariesOnly false
set_interface_property avalon_slave_0 burstcountUnits WORDS
set_interface_property avalon_slave_0 explicitAddressSpan 0
set_interface_property avalon_slave_0 holdTime 0
set_interface_property avalon_slave_0 linewrapBursts false
set_interface_property avalon_slave_0 maximumPendingReadTransactions 0
set_interface_property avalon_slave_0 maximumPendingWriteTransactions 0
set_interface_property avalon_slave_0 readLatency 0
set_interface_property avalon_slave_0 readWaitTime 1
set_interface_property avalon_slave_0 setupTime 0
set_interface_property avalon_slave_0 timingUnits Cycles
set_interface_property avalon_slave_0 writeWaitTime 0
set_interface_property avalon_slave_0 ENABLED true
set_interface_property avalon_slave_0 EXPORT_OF ""
set_interface_property avalon_slave_0 PORT_NAME_MAP ""
set_interface_property avalon_slave_0 CMSIS_SVD_VARIABLES ""
set_interface_property avalon_slave_0 SVD_ADDRESS_GROUP ""

add_interface_port avalon_slave_0 address address Input 10
add_interface_port avalon_slave_0 byteenable byteenable Input 4
add_interface_port avalon_slave_0 chipselect chipselect Input 1
add_interface_port avalon_slave_0 clken clken Input 1
add_interface_port avalon_slave_0 write write Input 1
add_interface_port avalon_slave_0 writedata writedata Input 32
add_interface_port avalon_slave_0 readdata readdata Output 32
add_interface_port avalon_slave_0 debugaccess debugaccess Input 1
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isFlash 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isPrintableDevice 0


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1
add_interface_port reset reset_req reset_req Input 1


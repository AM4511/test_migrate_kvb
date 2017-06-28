set_global_assignment -entity "serial_flash_loader" -library "lib_serial_flash_loader" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "serial_flash_loader" -library "lib_serial_flash_loader" -name IP_TOOL_VERSION "17.0"
set_global_assignment -entity "serial_flash_loader" -library "lib_serial_flash_loader" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_serial_flash_loader" -name SPD_FILE [file join $::quartus(sip_path) "../serial_flash_loader.spd"]
set_global_assignment -library "lib_serial_flash_loader" -name MISC_FILE [file join $::quartus(sip_path) "../../serial_flash_loader.qsys"]

set_global_assignment -library "lib_serial_flash_loader" -name MISC_FILE [file join $::quartus(sip_path) "serial_flash_loader.v"]
set_global_assignment -library "lib_serial_flash_loader" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_serial_flash_loader.v"]

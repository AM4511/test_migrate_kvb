# qsys scripting (.tcl) file for kvb_system
package require -exact qsys 16.0

create_system ${QSYS_NAME}

set_project_property DEVICE ${DEVICE}
set_project_property HIDE_FROM_IP_CATALOG {false}

# Instances and instance parameters
# (disabled instances are intentionally culled)
add_instance PnPROM_0 PnPROM
set_instance_parameter_value PnPROM_0 {INIT_FILE} ${WORK_PATH}/PnP_ROM.hex
set_instance_parameter_value PnPROM_0 {dev_name} ${BOARD_NAME}
set_instance_parameter_value PnPROM_0 {gw_ver} ${GW_VERSION}
set_instance_parameter_value PnPROM_0 {part_num} ${PART_NUMBER}
set_instance_parameter_value PnPROM_0 {git_commit} ${GIT_COMMIT}
set_instance_parameter_value PnPROM_0 {build_id} ${BUILDID}

add_instance clk_50 clock_source
set_instance_parameter_value clk_50 {clockFrequency} {50000000.0}
set_instance_parameter_value clk_50 {clockFrequencyKnown} {1}
set_instance_parameter_value clk_50 {resetSynchronousEdges} {NONE}

add_instance dead_rom altera_avalon_onchip_memory2
set_instance_parameter_value dead_rom {allowInSystemMemoryContentEditor} {0}
set_instance_parameter_value dead_rom {blockType} {AUTO}
set_instance_parameter_value dead_rom {copyInitFile} {0}
set_instance_parameter_value dead_rom {dataWidth} {32}
set_instance_parameter_value dead_rom {dataWidth2} {32}
set_instance_parameter_value dead_rom {dualPort} {0}
set_instance_parameter_value dead_rom {ecc_enabled} {0}
set_instance_parameter_value dead_rom {enPRInitMode} {0}
set_instance_parameter_value dead_rom {enableDiffWidth} {0}
set_instance_parameter_value dead_rom {initMemContent} {1}
set_instance_parameter_value dead_rom {initializationFileName} ${WORK_PATH}/dead_rom.hex
set_instance_parameter_value dead_rom {instanceID} {NONE}
set_instance_parameter_value dead_rom {memorySize} {32.0}
set_instance_parameter_value dead_rom {readDuringWriteMode} {DONT_CARE}
set_instance_parameter_value dead_rom {resetrequest_enabled} {1}
set_instance_parameter_value dead_rom {simAllowMRAMContentsFile} {0}
set_instance_parameter_value dead_rom {simMemInitOnlyFilename} {0}
set_instance_parameter_value dead_rom {singleClockOperation} {0}
set_instance_parameter_value dead_rom {slave1Latency} {1}
set_instance_parameter_value dead_rom {slave2Latency} {1}
set_instance_parameter_value dead_rom {useNonDefaultInitFile} {1}
set_instance_parameter_value dead_rom {useShallowMemBlocks} {0}
set_instance_parameter_value dead_rom {writable} {0}

add_instance i2c_master_0 i2c_master
set_instance_parameter_value i2c_master_0 {CLK_RATE} {125}

add_instance one_shot_0 one_shot
set_instance_parameter_value one_shot_0 {ENABLE_DEFAULT} {15}
set_instance_parameter_value one_shot_0 {INVERT_DEFAULT} {0}
set_instance_parameter_value one_shot_0 {MAX_PULSE} {8}
set_instance_parameter_value one_shot_0 {TIME_DEFAULT} {125}
set_instance_parameter_value one_shot_0 {WIDTH} {4}

add_instance pcie_hard_ip_0 altera_pcie_hard_ip_ltssm
set_instance_parameter_value pcie_hard_ip_0 {AST_LITE} {0}
set_instance_parameter_value pcie_hard_ip_0 {BAR Type} {32\ bit\ Non-Prefetchable 32\ bit\ Non-Prefetchable Not\ used Not\ used Not\ used Not\ used}
set_instance_parameter_value pcie_hard_ip_0 {CB_A2P_ADDR_MAP_IS_FIXED} {1}
set_instance_parameter_value pcie_hard_ip_0 {CB_A2P_ADDR_MAP_NUM_ENTRIES} {2}
set_instance_parameter_value pcie_hard_ip_0 {CB_A2P_ADDR_MAP_PASS_THRU_BITS} {20}
set_instance_parameter_value pcie_hard_ip_0 {CB_P2A_FIXED_AVALON_ADDR_B0} {0}
set_instance_parameter_value pcie_hard_ip_0 {CB_P2A_FIXED_AVALON_ADDR_B1} {0}
set_instance_parameter_value pcie_hard_ip_0 {CB_P2A_FIXED_AVALON_ADDR_B2} {0}
set_instance_parameter_value pcie_hard_ip_0 {CB_P2A_FIXED_AVALON_ADDR_B3} {0}
set_instance_parameter_value pcie_hard_ip_0 {CB_P2A_FIXED_AVALON_ADDR_B4} {0}
set_instance_parameter_value pcie_hard_ip_0 {CB_P2A_FIXED_AVALON_ADDR_B5} {0}
set_instance_parameter_value pcie_hard_ip_0 {CB_PCIE_MODE} {1}
set_instance_parameter_value pcie_hard_ip_0 {CB_PCIE_RX_LITE} {0}
set_instance_parameter_value pcie_hard_ip_0 {CB_TXS_ADDRESS_WIDTH} {7}
set_instance_parameter_value pcie_hard_ip_0 {CG_AVALON_S_ADDR_WIDTH} {20}
set_instance_parameter_value pcie_hard_ip_0 {CG_COMMON_CLOCK_MODE} {1}
set_instance_parameter_value pcie_hard_ip_0 {CG_ENABLE_A2P_INTERRUPT} {0}
set_instance_parameter_value pcie_hard_ip_0 {CG_IMPL_CRA_AV_SLAVE_PORT} {1}
set_instance_parameter_value pcie_hard_ip_0 {CG_IRQ_BIT_ENA} {65535}
set_instance_parameter_value pcie_hard_ip_0 {CG_NO_CPL_REORDERING} {0}
set_instance_parameter_value pcie_hard_ip_0 {CG_RXM_IRQ_NUM} {16}
set_instance_parameter_value pcie_hard_ip_0 {G_TAG_NUM0} {32}
set_instance_parameter_value pcie_hard_ip_0 {NUM_PREFETCH_MASTERS} {1}
set_instance_parameter_value pcie_hard_ip_0 {PCIe Address 31:0} {0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000}
set_instance_parameter_value pcie_hard_ip_0 {PCIe Address 63:32} {0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000}
set_instance_parameter_value pcie_hard_ip_0 {RH_NUM} {7}
set_instance_parameter_value pcie_hard_ip_0 {RXM_BEN_WIDTH} {8}
set_instance_parameter_value pcie_hard_ip_0 {RXM_DATA_WIDTH} {64}
set_instance_parameter_value pcie_hard_ip_0 {RX_BUF} {9}
set_instance_parameter_value pcie_hard_ip_0 {TL_SELECTION} {1}
set_instance_parameter_value pcie_hard_ip_0 {advanced_errors} {false}
set_instance_parameter_value pcie_hard_ip_0 {bar0_io_space} {false}
set_instance_parameter_value pcie_hard_ip_0 {bar1_io_space} {false}
set_instance_parameter_value pcie_hard_ip_0 {bar2_io_space} {false}
set_instance_parameter_value pcie_hard_ip_0 {bar3_io_space} {false}
set_instance_parameter_value pcie_hard_ip_0 {bar4_io_space} {false}
set_instance_parameter_value pcie_hard_ip_0 {bar5_io_space} {false}
set_instance_parameter_value pcie_hard_ip_0 {bar_io_window_size} {32BIT}
set_instance_parameter_value pcie_hard_ip_0 {bar_prefetchable} {32}
set_instance_parameter_value pcie_hard_ip_0 {bypass_tl} {false}
set_instance_parameter_value pcie_hard_ip_0 {class_code} {425984}
set_instance_parameter_value pcie_hard_ip_0 {completion_timeout} {NONE}
set_instance_parameter_value pcie_hard_ip_0 {credit_buffer_allocation_aux} {ABSOLUTE}
set_instance_parameter_value pcie_hard_ip_0 {device_id} {57346}
set_instance_parameter_value pcie_hard_ip_0 {diffclock_nfts_count} {255}
set_instance_parameter_value pcie_hard_ip_0 {dll_active_report_support} {false}
set_instance_parameter_value pcie_hard_ip_0 {eie_before_nfts_count} {4}
set_instance_parameter_value pcie_hard_ip_0 {enable_adapter_half_rate_mode} {false}
set_instance_parameter_value pcie_hard_ip_0 {enable_completion_timeout_disable} {false}
set_instance_parameter_value pcie_hard_ip_0 {enable_coreclk_out_half_rate} {false}
set_instance_parameter_value pcie_hard_ip_0 {enable_ecrc_check} {false}
set_instance_parameter_value pcie_hard_ip_0 {enable_ecrc_gen} {false}
set_instance_parameter_value pcie_hard_ip_0 {enable_function_msix_support} {false}
set_instance_parameter_value pcie_hard_ip_0 {enable_l1_aspm} {false}
set_instance_parameter_value pcie_hard_ip_0 {enable_msi_64bit_addressing} {true}
set_instance_parameter_value pcie_hard_ip_0 {enable_slot_register} {false}
set_instance_parameter_value pcie_hard_ip_0 {endpoint_l0_latency} {0}
set_instance_parameter_value pcie_hard_ip_0 {endpoint_l1_latency} {0}
set_instance_parameter_value pcie_hard_ip_0 {fixed_address_mode} {0}
set_instance_parameter_value pcie_hard_ip_0 {gen2_diffclock_nfts_count} {255}
set_instance_parameter_value pcie_hard_ip_0 {gen2_sameclock_nfts_count} {255}
set_instance_parameter_value pcie_hard_ip_0 {hot_plug_support} {0}
set_instance_parameter_value pcie_hard_ip_0 {l01_entry_latency} {31}
set_instance_parameter_value pcie_hard_ip_0 {l0_exit_latency_diffclock} {7}
set_instance_parameter_value pcie_hard_ip_0 {l0_exit_latency_sameclock} {7}
set_instance_parameter_value pcie_hard_ip_0 {l1_exit_latency_diffclock} {7}
set_instance_parameter_value pcie_hard_ip_0 {l1_exit_latency_sameclock} {7}
set_instance_parameter_value pcie_hard_ip_0 {link_common_clock} {1}
set_instance_parameter_value pcie_hard_ip_0 {low_priority_vc} {0}
set_instance_parameter_value pcie_hard_ip_0 {max_link_width} {1}
set_instance_parameter_value pcie_hard_ip_0 {max_payload_size} {1}
set_instance_parameter_value pcie_hard_ip_0 {msi_function_count} {0}
set_instance_parameter_value pcie_hard_ip_0 {msix_pba_bir} {0}
set_instance_parameter_value pcie_hard_ip_0 {msix_pba_offset} {0}
set_instance_parameter_value pcie_hard_ip_0 {msix_table_bir} {0}
set_instance_parameter_value pcie_hard_ip_0 {msix_table_offset} {0}
set_instance_parameter_value pcie_hard_ip_0 {msix_table_size} {0}
set_instance_parameter_value pcie_hard_ip_0 {my_advanced_errors} {0}
set_instance_parameter_value pcie_hard_ip_0 {my_enable_ecrc_check} {0}
set_instance_parameter_value pcie_hard_ip_0 {my_enable_ecrc_gen} {0}
set_instance_parameter_value pcie_hard_ip_0 {my_gen2_lane_rate_mode} {0}
set_instance_parameter_value pcie_hard_ip_0 {no_command_completed} {true}
set_instance_parameter_value pcie_hard_ip_0 {no_soft_reset} {false}
set_instance_parameter_value pcie_hard_ip_0 {p_pcie_app_clk} {0}
set_instance_parameter_value pcie_hard_ip_0 {p_pcie_target_performance_preset} {Maximum}
set_instance_parameter_value pcie_hard_ip_0 {p_pcie_test_out_width} {64bits}
set_instance_parameter_value pcie_hard_ip_0 {p_pcie_txrx_clock} {100 MHz}
set_instance_parameter_value pcie_hard_ip_0 {p_pcie_version} {2.0}
set_instance_parameter_value pcie_hard_ip_0 {p_user_msi_enable} {0}
set_instance_parameter_value pcie_hard_ip_0 {pcie_mode} {SHARED_MODE}
set_instance_parameter_value pcie_hard_ip_0 {pcie_qsys} {1}
set_instance_parameter_value pcie_hard_ip_0 {port_link_number} {1}
set_instance_parameter_value pcie_hard_ip_0 {revision_id} {1}
set_instance_parameter_value pcie_hard_ip_0 {sameclock_nfts_count} {255}
set_instance_parameter_value pcie_hard_ip_0 {slot_number} {0}
set_instance_parameter_value pcie_hard_ip_0 {slot_power_limit} {0}
set_instance_parameter_value pcie_hard_ip_0 {slot_power_scale} {0}
set_instance_parameter_value pcie_hard_ip_0 {subsystem_device_id} {5189}
set_instance_parameter_value pcie_hard_ip_0 {subsystem_vendor_id} {4466}
set_instance_parameter_value pcie_hard_ip_0 {surprise_down_error_support} {false}
set_instance_parameter_value pcie_hard_ip_0 {under_test} {0}
set_instance_parameter_value pcie_hard_ip_0 {use_crc_forwarding} {false}
set_instance_parameter_value pcie_hard_ip_0 {vendor_id} {4466}

add_instance pio_0 altera_avalon_pio
set_instance_parameter_value pio_0 {bitClearingEdgeCapReg} {0}
set_instance_parameter_value pio_0 {bitModifyingOutReg} {1}
set_instance_parameter_value pio_0 {captureEdge} {0}
set_instance_parameter_value pio_0 {direction} {Bidir}
set_instance_parameter_value pio_0 {edgeType} {RISING}
set_instance_parameter_value pio_0 {generateIRQ} {0}
set_instance_parameter_value pio_0 {irqType} {LEVEL}
set_instance_parameter_value pio_0 {resetValue} {0.0}
set_instance_parameter_value pio_0 {simDoTestBenchWiring} {0}
set_instance_parameter_value pio_0 {simDrivenValue} {0.0}
set_instance_parameter_value pio_0 {width} {8}

add_instance pio_1 altera_avalon_pio
set_instance_parameter_value pio_1 {bitClearingEdgeCapReg} {0}
set_instance_parameter_value pio_1 {bitModifyingOutReg} {0}
set_instance_parameter_value pio_1 {captureEdge} {0}
set_instance_parameter_value pio_1 {direction} {Output}
set_instance_parameter_value pio_1 {edgeType} {RISING}
set_instance_parameter_value pio_1 {generateIRQ} {0}
set_instance_parameter_value pio_1 {irqType} {LEVEL}
set_instance_parameter_value pio_1 {resetValue} {0.0}
set_instance_parameter_value pio_1 {simDoTestBenchWiring} {0}
set_instance_parameter_value pio_1 {simDrivenValue} {0.0}
set_instance_parameter_value pio_1 {width} {2}

add_instance qspi_mram_0 qspi_mram
set_instance_parameter_value qspi_mram_0 {QSPI_DISABLE} {false}

add_instance vme_intf_0 vme_intf
set_instance_parameter_value vme_intf_0 {A32_OFFSET} {536870912}
set_instance_parameter_value vme_intf_0 {A32_WIDTH} {28}
set_instance_parameter_value vme_intf_0 {BIG_ENDIAN} {0}

# exported interfaces
add_interface clk_50 clock sink
set_interface_property clk_50 EXPORT_OF clk_50.clk_in
add_interface i2c_master_0 conduit end
set_interface_property i2c_master_0 EXPORT_OF i2c_master_0.conduit_end
add_interface one_shot_0 conduit end
set_interface_property one_shot_0 EXPORT_OF one_shot_0.conduit_end
add_interface pcie_hard_ip_0_clocks_sim conduit end
set_interface_property pcie_hard_ip_0_clocks_sim EXPORT_OF pcie_hard_ip_0.clocks_sim
add_interface pcie_hard_ip_0_dl_ltssm_int conduit end
set_interface_property pcie_hard_ip_0_dl_ltssm_int EXPORT_OF pcie_hard_ip_0.dl_ltssm_int
add_interface pcie_hard_ip_0_fixedclk clock sink
set_interface_property pcie_hard_ip_0_fixedclk EXPORT_OF pcie_hard_ip_0.fixedclk
add_interface pcie_hard_ip_0_pcie_rstn conduit end
set_interface_property pcie_hard_ip_0_pcie_rstn EXPORT_OF pcie_hard_ip_0.pcie_rstn
add_interface pcie_hard_ip_0_pipe_ext conduit end
set_interface_property pcie_hard_ip_0_pipe_ext EXPORT_OF pcie_hard_ip_0.pipe_ext
add_interface pcie_hard_ip_0_powerdown conduit end
set_interface_property pcie_hard_ip_0_powerdown EXPORT_OF pcie_hard_ip_0.powerdown
add_interface pcie_hard_ip_0_reconfig_busy conduit end
set_interface_property pcie_hard_ip_0_reconfig_busy EXPORT_OF pcie_hard_ip_0.reconfig_busy
add_interface pcie_hard_ip_0_reconfig_fromgxb_0 conduit end
set_interface_property pcie_hard_ip_0_reconfig_fromgxb_0 EXPORT_OF pcie_hard_ip_0.reconfig_fromgxb_0
add_interface pcie_hard_ip_0_reconfig_togxb conduit end
set_interface_property pcie_hard_ip_0_reconfig_togxb EXPORT_OF pcie_hard_ip_0.reconfig_togxb
add_interface pcie_hard_ip_0_refclk conduit end
set_interface_property pcie_hard_ip_0_refclk EXPORT_OF pcie_hard_ip_0.refclk
add_interface pcie_hard_ip_0_rx_in conduit end
set_interface_property pcie_hard_ip_0_rx_in EXPORT_OF pcie_hard_ip_0.rx_in
add_interface pcie_hard_ip_0_test_in conduit end
set_interface_property pcie_hard_ip_0_test_in EXPORT_OF pcie_hard_ip_0.test_in
add_interface pcie_hard_ip_0_test_out conduit end
set_interface_property pcie_hard_ip_0_test_out EXPORT_OF pcie_hard_ip_0.test_out
add_interface pcie_hard_ip_0_tx_out conduit end
set_interface_property pcie_hard_ip_0_tx_out EXPORT_OF pcie_hard_ip_0.tx_out
add_interface pio_0 conduit end
set_interface_property pio_0 EXPORT_OF pio_0.external_connection
add_interface pio_1 conduit end
set_interface_property pio_1 EXPORT_OF pio_1.external_connection
add_interface qspi_mram_0 conduit end
set_interface_property qspi_mram_0 EXPORT_OF qspi_mram_0.conduit_end
add_interface reset reset sink
set_interface_property reset EXPORT_OF clk_50.clk_in_reset
add_interface vme_intf_0 conduit end
set_interface_property vme_intf_0 EXPORT_OF vme_intf_0.vme_intf

# connections and connection parameters
add_connection clk_50.clk pcie_hard_ip_0.cal_blk_clk

add_connection clk_50.clk pcie_hard_ip_0.reconfig_gxbclk

add_connection clk_50.clk qspi_mram_0.clock

add_connection clk_50.clk_reset dead_rom.reset1

add_connection clk_50.clk_reset qspi_mram_0.reset

add_connection pcie_hard_ip_0.bar0 PnPROM_0.avalon_slave_0
set_connection_parameter_value pcie_hard_ip_0.bar0/PnPROM_0.avalon_slave_0 arbitrationPriority {1}
set_connection_parameter_value pcie_hard_ip_0.bar0/PnPROM_0.avalon_slave_0 baseAddress {0x0000}
set_connection_parameter_value pcie_hard_ip_0.bar0/PnPROM_0.avalon_slave_0 defaultConnection {0}


add_connection pcie_hard_ip_0.bar0 dead_rom.s1
set_connection_parameter_value pcie_hard_ip_0.bar0/dead_rom.s1 arbitrationPriority {1}
set_connection_parameter_value pcie_hard_ip_0.bar0/dead_rom.s1 baseAddress {0x0000}
set_connection_parameter_value pcie_hard_ip_0.bar0/dead_rom.s1 defaultConnection {1}

add_connection pcie_hard_ip_0.bar0 i2c_master_0.avalon_slave_0
set_connection_parameter_value pcie_hard_ip_0.bar0/i2c_master_0.avalon_slave_0 arbitrationPriority {1}
set_connection_parameter_value pcie_hard_ip_0.bar0/i2c_master_0.avalon_slave_0 baseAddress {0x000200c0}
set_connection_parameter_value pcie_hard_ip_0.bar0/i2c_master_0.avalon_slave_0 defaultConnection {0}

add_connection pcie_hard_ip_0.bar0 one_shot_0.avalon_slave_0
set_connection_parameter_value pcie_hard_ip_0.bar0/one_shot_0.avalon_slave_0 arbitrationPriority {1}
set_connection_parameter_value pcie_hard_ip_0.bar0/one_shot_0.avalon_slave_0 baseAddress {0x00020100}
set_connection_parameter_value pcie_hard_ip_0.bar0/one_shot_0.avalon_slave_0 defaultConnection {0}

add_connection pcie_hard_ip_0.bar0 pcie_hard_ip_0.cra
set_connection_parameter_value pcie_hard_ip_0.bar0/pcie_hard_ip_0.cra arbitrationPriority {1}
set_connection_parameter_value pcie_hard_ip_0.bar0/pcie_hard_ip_0.cra baseAddress {0x00010000}
set_connection_parameter_value pcie_hard_ip_0.bar0/pcie_hard_ip_0.cra defaultConnection {0}

add_connection pcie_hard_ip_0.bar0 pio_0.s1
set_connection_parameter_value pcie_hard_ip_0.bar0/pio_0.s1 arbitrationPriority {1}
set_connection_parameter_value pcie_hard_ip_0.bar0/pio_0.s1 baseAddress {0x00020000}
set_connection_parameter_value pcie_hard_ip_0.bar0/pio_0.s1 defaultConnection {0}

add_connection pcie_hard_ip_0.bar0 pio_1.s1
set_connection_parameter_value pcie_hard_ip_0.bar0/pio_1.s1 arbitrationPriority {1}
set_connection_parameter_value pcie_hard_ip_0.bar0/pio_1.s1 baseAddress {0x00020020}
set_connection_parameter_value pcie_hard_ip_0.bar0/pio_1.s1 defaultConnection {0}

add_connection pcie_hard_ip_0.bar0 qspi_mram_0.avalon_slave_0
set_connection_parameter_value pcie_hard_ip_0.bar0/qspi_mram_0.avalon_slave_0 arbitrationPriority {1}
set_connection_parameter_value pcie_hard_ip_0.bar0/qspi_mram_0.avalon_slave_0 baseAddress {0x00040000}
set_connection_parameter_value pcie_hard_ip_0.bar0/qspi_mram_0.avalon_slave_0 defaultConnection {0}

add_connection pcie_hard_ip_0.bar0 vme_intf_0.avalon_slave_0
set_connection_parameter_value pcie_hard_ip_0.bar0/vme_intf_0.avalon_slave_0 arbitrationPriority {1}
set_connection_parameter_value pcie_hard_ip_0.bar0/vme_intf_0.avalon_slave_0 baseAddress {0x04000000}
set_connection_parameter_value pcie_hard_ip_0.bar0/vme_intf_0.avalon_slave_0 defaultConnection {0}

add_connection pcie_hard_ip_0.bar1 vme_intf_0.avalon_slave_1
set_connection_parameter_value pcie_hard_ip_0.bar1/vme_intf_0.avalon_slave_1 arbitrationPriority {1}
set_connection_parameter_value pcie_hard_ip_0.bar1/vme_intf_0.avalon_slave_1 baseAddress {0x0000}
set_connection_parameter_value pcie_hard_ip_0.bar1/vme_intf_0.avalon_slave_1 defaultConnection {0}

add_connection pcie_hard_ip_0.pcie_core_clk PnPROM_0.clock

add_connection pcie_hard_ip_0.pcie_core_clk dead_rom.clk1

add_connection pcie_hard_ip_0.pcie_core_clk i2c_master_0.clock

add_connection pcie_hard_ip_0.pcie_core_clk one_shot_0.clock

add_connection pcie_hard_ip_0.pcie_core_clk pio_0.clk

add_connection pcie_hard_ip_0.pcie_core_clk pio_1.clk

add_connection pcie_hard_ip_0.pcie_core_clk vme_intf_0.clock

add_connection pcie_hard_ip_0.pcie_core_reset PnPROM_0.reset

add_connection pcie_hard_ip_0.pcie_core_reset i2c_master_0.reset

add_connection pcie_hard_ip_0.pcie_core_reset one_shot_0.reset

add_connection pcie_hard_ip_0.pcie_core_reset pio_0.reset

add_connection pcie_hard_ip_0.pcie_core_reset pio_1.reset

add_connection pcie_hard_ip_0.pcie_core_reset vme_intf_0.reset

add_connection pcie_hard_ip_0.rxm_irq i2c_master_0.interrupt_sender
set_connection_parameter_value pcie_hard_ip_0.rxm_irq/i2c_master_0.interrupt_sender irqNumber {1}

add_connection pcie_hard_ip_0.rxm_irq vme_intf_0.interrupt_sender
set_connection_parameter_value pcie_hard_ip_0.rxm_irq/vme_intf_0.interrupt_sender irqNumber {0}

# interconnect requirements
set_interconnect_requirement {$system} {qsys_mm.clockCrossingAdapter} {HANDSHAKE}
set_interconnect_requirement {$system} {qsys_mm.enableEccProtection} {FALSE}
set_interconnect_requirement {$system} {qsys_mm.insertDefaultSlave} {FALSE}
set_interconnect_requirement {$system} {qsys_mm.maxAdditionalLatency} {4}
set_interconnect_requirement {mm_interconnect_0|pcie_hard_ip_0_bar0_agent.cp/router.sink} {qsys_mm.postTransform.pipelineCount} {1}
set_interconnect_requirement {mm_interconnect_0|router.src/pcie_hard_ip_0_bar0_limiter.cmd_sink} {qsys_mm.postTransform.pipelineCount} {1}

save_system ${QSYS_NAME}.qsys

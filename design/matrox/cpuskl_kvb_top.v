`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////
// Company:        Kulicke and Soffa Industries Inc.
//                 Matrox Electronic Systems Ltd.
//
// Engineer:       Richard Carickhoff, David Rauth, Alain Marchand
//
// Create Date:    1/12/2016
// Design Name:    CPUSKL Bridge
// Module Name:    cpuskl_kvb_top
// Project Name:   cpuskl_kvb
// Target Devices: EP4CGX22CF19C8
// Tool versions:  Quartus Version 17.0
// Description:    VME bridge, UARTs, I2C, clock management
//
// Dependencies:
//
// Revision:
//    1.0 - File Created
//    1.1 - Disable SCL when I2C not active
//          Removed BAR2-3 used for 32-bit VME Interface
//          Changed VME DTACK detection to state machine
//    1.2 - Added dead band rom - DEADDEAD
//          Fixed irq not resetting problem
//          Changed PCIe revision ID and class code
//    1.3 - Changed I2C module to meet timing requirements of chips on board
//          Added altgx_reconfig IP to top level file
//          Removed unused statements in c4gx_pcie_sopc.out.sdc
//    1.4 - Changed the VME timing for AS#, DS0# and DS1# to meet VME spec
//
//    2.0 - Matrox take over. Change device for CPUSKL.
//    2.1 - Replaced 3 LPC UARTs with PCIe UARTs. Replaced I2C master. Added CRA
//          slave interface to PCIe-AvalonMM bridge. Added Git commit to scripts
//          and PnP ROM. Added one-shot timer for camera triggers. Added PIO for
//          user LEDs. Added QAR and ZIP archive generation to scripts.
//    2.2 - Updated VME, QSPI, and PCIe UART IP. Finalized timing constraints.
///////////////////////////////////////////////////////////////////////////////


module cpuskl_kvb_top (
    // oscillator
    input         clkin_125m_p,

    // PCIe
    input         sys_rst_n,           // platform_rst# (reset from PCIe bus and pwr good)
    input         refclk,              // 100MHz reference clock
    input         rx_in0,              // PCIe input
    output        tx_out0,             // PCIe output

    // VME interface signals
    inout  [31:0] vme_db,              // 32-bit data bus
    output [31:1] vme_a,               // 32-bit address bus
    output [5:0]  vme_am,              // address modifier
    output        vme_lword_n,         // long word
    output        vme_as_n,            // address strobe
    output        vme_ds0_n,           // data strobe 0
    output        vme_ds1_n,           // data strobe 1
    output        vme_write_n,         // write
    output        vme_write,           // write
    output        vme_iack_n,          // interrupt acknowledge
    output        vme_iackout_n,       // interrupt acknowledge out
    input         vme_dtack_n,         // data transfer acknowledge
    input  [7:1]  vme_irq_n,           // interrupt requests
    output        vme_buffer_oe,       // VME buffer output enable

    // platform signals
    input         voltage_alert,
    input         power_failure_n,
    inout  [7:0]  gpio,                // test point I/O
    inout  [6:0]  cpcis_pcie_clken_n,  // PCIe board present inputs - 16KHz sync clk outputs
    output [6:0]  pch_clk_req_n,       // PCIe clock enable sent to the PCH
    output [3:0]  cam_trigger,         // Nexis Triggers
    output [2:0]  prog_led_n,

    // UART interfaces
    input         ser1_rx,
    output        ser1_tx,
    input         ser2_rx,
    output        ser2_tx,
    input         ser3_rx,
    output        ser3_tx,
    input         ser4_rx,
    output        ser4_tx,
    output        ser4_rts_n,

    // QSPI interface
    inout  [3:0]  mram_io,
    output        mram_sck,
    output        mram_cs_n,

    // I2C0 Controller
    inout         local_i2c_sda,
    inout         local_i2c_scl,

    // LPC interface
    input         lpc_clk ,
    input         lpc_frame_n,
    inout  [3:0]  lpc_ad,
    inout         serirq
    );

    
    wire          clk50;
    wire          clk125;
    wire          sync_clk;
    wire   [6:0]  sync_clks;
    reg    [6:0]  cpcis_prsnt;

    wire          pll_lock;
    wire   [31:0] pio_out;
    wire          pipe_mode;

    wire          ser4_rts;
    reg           sys_rst_n1;
    reg           sys_rst_n2;
    wire          platform_wake;
    reg    [4:0]  cnt;
    reg           sys_rst_n_delayed;
    reg    [1:0]  led_out;

    wire   [16:0] reconfig_fromgxb;
    wire   [3:0]  reconfig_togxb;
    wire          busy;

    wire   [63:0] test_out_icm;
    wire   [39:0] test_in;
    wire   [4:0]  dl_ltssm_int;
    wire   [3:0]  ser_rx;
    wire   [3:0]  ser_tx;
    
    assign vme_write = ~vme_write_n;
    assign vme_buffer_oe = 1'b1;
    assign prog_led_n[2:1] = ~led_out;
    

    // Assignment of the test_in[39:0] signal -Hard IP
    // The test_in bus provides runtime control for specific IP core
    // features. For normal operation, this bus can be driven to all 0's. The
    // following bits are defined:
    //    [0]–Simulation mode. This signal can be set to 1 to accelerate
    //        initialization by changing many initialization count.
    //    [2:1]–reserved.
    //    [3]–FPGA mode. Set this signal to 1 for an FPGA implementation.
    //    [2:1]–reserved.
    //    [6:5] Compliance test mode. Disable/force compliance mode:
    //             - bit 0–when set, prevents the LTSSM from entering compliance
    //               mode. Toggling this bit controls the entry and exit from the
    //               compliance state, enabling the transmission of Gen1 and Gen2
    //               compliance patterns.
    //             - bit 1–forces compliance mode. Forces entry to compliance mode
    //               when timeout is reached in polling.active state (and not all lanes
    //               have detected their exit condition).
    //    [7]–Disables low power state negotiation. When asserted, this signal
    //        disables all low power state negotiation. This bit is set to 1 for Qsys.
    //    [11:8]–you must tie these signals low.
    //    [15:13]–lane select.
    //    [31:16, 12]–reserved.
    //    [32] Compliance mode test switch. When set to 1, the IP core is in
    //    compliance mode which is used for Compliance Base Board testing
    //    (CBB) testing. When set to 0, the IP core is in operates normally.
    //    Connect this signal to a switch to turn on and off compliance mode.

    assign test_in[0]     = 1'b0;
    assign test_in[2:1]   = 2'b00;
    assign test_in[3]     = 1'b1;
    assign test_in[4]     = 1'b0;
    assign test_in[6:5]   = 2'b01;
    assign test_in[7]     = 1'b1;
    assign test_in[11:8]  = 4'b0000;
    assign test_in[12]    = 1'b0;
    assign test_in[15:13] = 3'b000;
    assign test_in[39:16] = 0;


    // Serial Flash loader. Used to dowload the firmware in the on-board FLASH.
    serial_flash_loader sfl(
        .noe_in(1'b0)
        );


    reconfig_pll reconfig_pll(
        .inclk0(clkin_125m_p),
        .c0(clk50),
        .c1(clk125),
        .c2(sync_clk),  // 16KHz (62.5usec)
        .locked(pll_lock)
        );


    always @(posedge clk125 or negedge sys_rst_n) begin
        if (sys_rst_n == 0) begin
            sys_rst_n1 <= 0;
            sys_rst_n2 <= 0;
        end
        else begin
            sys_rst_n1 <= 1'b1;
            sys_rst_n2 <= sys_rst_n1;
        end
    end


    always @(posedge clk125 or negedge sys_rst_n2) begin
        if (sys_rst_n2 == 0) begin
            cnt <= 0;
            sys_rst_n_delayed <= 0;
        end
        else begin
            if (cnt == 5'd25) begin  // 200nsec delay
            sys_rst_n_delayed <= 1'b1;
            end
            else begin
                cnt <= cnt + 1'b1;
            end
        end
    end


    // LTSSM state: The LTSSM state machine encoding defines the following states:
    //    00000: Detect.Quiet
    //    00001: Detect.Active
    //    00010: Polling.Active
    //    00011: Polling.Compliance
    //    00100: Polling.Configuration
    //    00101: Polling.Speed
    //    00110: config.Linkwidthstart
    //    00111: Config.Linkaccept
    //    01000: Config.Lanenumaccept
    //    01001: Config.Lanenumwait
    //    01010: Config.Complete
    //    01011: Config.Idle
    //    01100: Recovery.Rcvlock
    //    01101: Recovery.Rcvconfig
    //    01110: Recovery.Idle
    //    01111: L0
    //    10000: Disable
    //    10001: Loopback.Entry
    //    10010: Loopback.Active
    //    10011: Loopback.Exit
    //    10100: Hot.Reset
    //    10101: LOs
    //    11001: L2.transmit.Wake
    //    11010: Speed.Recovery
    //    11011: Recovery.Equalization, Phase 0
    //    11100: Recovery.Equalization, Phase 1
    //    11101: Recovery.Equalization, Phase 2
    //    11110: recovery.Equalization, Phase 3

    assign prog_led_n[0] = (dl_ltssm_int == 5'b01111 || dl_ltssm_int == 5'b10101) ? 1'b0 : 1'b1;
    

    altgx_reconfig altgx_reconfig_inst (
        .reconfig_clk (clk50),
		.reconfig_fromgxb (reconfig_fromgxb),
		.busy (busy),  // This will only be used in reset logic for offset cancellation process. Never used for actual channel reconfiguration
		.reconfig_togxb (reconfig_togxb)
		);

 
    //==========================
    // Set input values
    //==========================
    assign pipe_mode = 1'b0;

    
    kvb_system u0 (
        /////////////////////////////////////////////////////////////
        // Clocks
        /////////////////////////////////////////////////////////////
        .clk_50_clk                                        (clk50),

        
        /////////////////////////////////////////////////////////////
        // I2C Master Local
        /////////////////////////////////////////////////////////////
        .i2c_master_0_sda                                  (local_i2c_sda),
        .i2c_master_0_scl                                  (local_i2c_scl),


        /////////////////////////////////////////////////////////////
        // PCIe Hard IP
        /////////////////////////////////////////////////////////////
        .pcie_hard_ip_0_clocks_sim_clk250_export           (),
        .pcie_hard_ip_0_clocks_sim_clk500_export           (),
        .pcie_hard_ip_0_clocks_sim_clk125_export           (), 
        .pcie_hard_ip_0_fixedclk_clk                       (clk125), 
        .pcie_hard_ip_0_pcie_rstn_export                   (sys_rst_n),

        .pcie_hard_ip_0_pipe_ext_pipe_mode                 (pipe_mode),
        .pcie_hard_ip_0_pipe_ext_phystatus_ext             (),
        .pcie_hard_ip_0_pipe_ext_rate_ext                  (),
        .pcie_hard_ip_0_pipe_ext_powerdown_ext             (),
        .pcie_hard_ip_0_pipe_ext_txdetectrx_ext            (),
        .pcie_hard_ip_0_pipe_ext_rxelecidle0_ext           (),
        .pcie_hard_ip_0_pipe_ext_rxdata0_ext               (),
        .pcie_hard_ip_0_pipe_ext_rxstatus0_ext             (),
        .pcie_hard_ip_0_pipe_ext_rxvalid0_ext              (),
        .pcie_hard_ip_0_pipe_ext_rxdatak0_ext              (),
        .pcie_hard_ip_0_pipe_ext_txdata0_ext               (),
        .pcie_hard_ip_0_pipe_ext_txdatak0_ext              (),
        .pcie_hard_ip_0_pipe_ext_rxpolarity0_ext           (),
        .pcie_hard_ip_0_pipe_ext_txcompl0_ext              (),
        .pcie_hard_ip_0_pipe_ext_txelecidle0_ext           (),

        .pcie_hard_ip_0_powerdown_pll_powerdown            (1'b0),
        .pcie_hard_ip_0_powerdown_gxb_powerdown            (1'b0),
        .pcie_hard_ip_0_reconfig_busy_busy_altgxb_reconfig (busy),
        .pcie_hard_ip_0_reconfig_fromgxb_0_data            (reconfig_fromgxb),
        .pcie_hard_ip_0_reconfig_togxb_data                (reconfig_togxb),
        .pcie_hard_ip_0_refclk_export                      (refclk),
        .pcie_hard_ip_0_rx_in_rx_datain_0                  (rx_in0),
        .pcie_hard_ip_0_test_in_test_in                    (test_in),
        .pcie_hard_ip_0_test_out_test_out                  (),
        .pcie_hard_ip_0_tx_out_tx_dataout_0                (tx_out0),
        .pcie_hard_ip_0_dl_ltssm_int_interconect           (dl_ltssm_int), 


        /////////////////////////////////////////////////////////////
        // I/Os
        /////////////////////////////////////////////////////////////
        .pio_0_export                                      (gpio),
        .pio_1_export                                      (led_out),
        .one_shot_0_export                                 (cam_trigger),


        /////////////////////////////////////////////////////////////
        //MRAM Q_SPI interface
        /////////////////////////////////////////////////////////////
        .qspi_mram_0_qspi_sck                              (mram_sck),
        .qspi_mram_0_qspi_cs_n                             (mram_cs_n),
        .qspi_mram_0_qspi_dat                              (mram_io),

        
        /////////////////////////////////////////////////////////////
        // System reset
        /////////////////////////////////////////////////////////////
        .reset_reset_n                                     (sys_rst_n),


        /////////////////////////////////////////////////////////////
        // VME Interface
        /////////////////////////////////////////////////////////////
        .vme_intf_0_vme_sysfail_n                          (),
        .vme_intf_0_vme_irq_n                              (vme_irq_n),
        .vme_intf_0_vme_iackout_n                          (vme_iackout_n),
        .vme_intf_0_vme_iack_n                             (vme_iack_n),
        .vme_intf_0_vme_dtack_n                            (vme_dtack_n),
        .vme_intf_0_vmd_ds1_n                              (vme_ds1_n),
        .vme_intf_0_vme_ds0_n                              (vme_ds0_n),
        .vme_intf_0_vme_write_n                            (vme_write_n),
        .vme_intf_0_vme_sysrst_n                           (),
        .vme_intf_0_vme_lword_n                            (vme_lword_n),
        .vme_intf_0_vme_as_n                               (vme_as_n),
        .vme_intf_0_vme_am                                 (vme_am),
        .vme_intf_0_vme_db                                 (vme_db),
        .vme_intf_0_vme_a                                  (vme_a),


        /////////////////////////////////////////////////////////////
        // UART Interfaces
        /////////////////////////////////////////////////////////////
        .a_16550_uart_0_uart_sin                           (),
        .a_16550_uart_0_uart_sout                          (),
        .a_16550_uart_0_uart_rts                           (),
        .a_16550_uart_0_uart_cts                           (),
        .a_16550_uart_0_uart_dtr                           (),
        .a_16550_uart_0_uart_dsr                           (),
        .a_16550_uart_0_uart_ri                            (),
        .a_16550_uart_0_uart_dcd                           (),

        .a_16550_uart_1_uart_sin                           (ser2_rx),
        .a_16550_uart_1_uart_sout                          (ser2_tx),
        .a_16550_uart_1_uart_rts                           (),
        .a_16550_uart_1_uart_cts                           (),
        .a_16550_uart_1_uart_dtr                           (),
        .a_16550_uart_1_uart_dsr                           (),
        .a_16550_uart_1_uart_ri                            (),
        .a_16550_uart_1_uart_dcd                           (),

        .a_16550_uart_2_uart_sin                           (ser3_rx),
        .a_16550_uart_2_uart_sout                          (ser3_tx),
        .a_16550_uart_2_uart_rts                           (),
        .a_16550_uart_2_uart_cts                           (),
        .a_16550_uart_2_uart_dtr                           (),
        .a_16550_uart_2_uart_dsr                           (),
        .a_16550_uart_2_uart_ri                            (),
        .a_16550_uart_2_uart_dcd                           (),

        .a_16550_uart_3_uart_sin                           (ser4_rx),
        .a_16550_uart_3_uart_sout                          (ser4_tx),
        .a_16550_uart_3_uart_rts                           (ser4_rts),
        .a_16550_uart_3_uart_cts                           (),
        .a_16550_uart_3_uart_dtr                           (),
        .a_16550_uart_3_uart_dsr                           (),
        .a_16550_uart_3_uart_ri                            (),
        .a_16550_uart_3_uart_dcd                           ()
        );


    lpc2uarts u1 (
        .lpc_clk     (lpc_clk),
        .lpc_reset_n (sys_rst_n),
        .lpc_frame_n (lpc_frame_n),
        .lpc_ad      (lpc_ad),
        .serirq      (serirq),
        .ser_rx      (ser_rx),
        .ser_tx      (ser_tx),
        .ser4_rts_n  ()
        );

    assign ser1_tx = ser_tx[0];
    assign ser_rx[0] =  ser1_rx;

    assign ser4_rts_n = ~ser4_rts;

    
    ////////////////////////////////////////////////////////////////////
    // cpcis_pcie_clken_n[6:0]
    //
    // INPUT: latched on the PCI reset
    // OUTPUT: drive sync_clk when not in PCI reset
    //
    ////////////////////////////////////////////////////////////////////
    always @ (posedge clk125) begin
        if (sys_rst_n2 == 0) begin
            cpcis_prsnt[6:0] <= ~cpcis_pcie_clken_n[6:0];  // boards present
        end
    end
    
    assign sync_clks[6:0] = {7{sync_clk}};
    assign cpcis_pcie_clken_n[6:0] = ( sys_rst_n_delayed  == 1'b1) ? cpcis_prsnt[6:0] & sync_clks[6:0] : 6'hz ;
    
    
    ////////////////////////////////////////////////////////////////////
    // pch_clk_req_n[6:0]
    //
    // OUTPUT (Opendrain): Request PCIe Clock when associated PCIE
    //                     board detected
    //
    ////////////////////////////////////////////////////////////////////
    assign pch_clk_req_n[0] = (cpcis_prsnt[0]) ? 1'b0 : 1'bz;
    assign pch_clk_req_n[1] = (cpcis_prsnt[1]) ? 1'b0 : 1'bz;
    assign pch_clk_req_n[2] = (cpcis_prsnt[2]) ? 1'b0 : 1'bz;
    assign pch_clk_req_n[3] = (cpcis_prsnt[3]) ? 1'b0 : 1'bz;
    assign pch_clk_req_n[4] = (cpcis_prsnt[4]) ? 1'b0 : 1'bz;
    assign pch_clk_req_n[5] = (cpcis_prsnt[5]) ? 1'b0 : 1'bz;
    assign pch_clk_req_n[6] = (cpcis_prsnt[6]) ? 1'b0 : 1'bz;

endmodule
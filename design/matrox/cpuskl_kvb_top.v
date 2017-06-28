`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Kulicke and Soffa Industries Inc
// Engineer: Richard Carickhoff
// 
// Create Date:    1/12/2016 
// Design Name: 
// Module Name:    c4gt_pcie_gen1x1.v 
// Project Name:   c4gt_gen1x1_vme_bridge
// Target Devices: EP4CGX30CF23C8
// Tool versions:  Quartus Version 14.0
// Description: VME Bridge top module
//
// Dependencies: 
//
// Revision: 
// Revision 1.0 - File Created
// 			1.1 - Disable SCL when I2C not active
//				  Removed BAR2-3 used for 32-bit VME Interface
//				  Changed VME DTACK detection to state machine
//			1.2 - Added dead band rom - DEADDEAD
//			      Fixed irq not resetting problem
//				  Changed PCIe revision ID and class code
//		    1.3 - Changed I2C module to meet timing requirements of chips on board
//			      Added altgx_reconfig IP to top level file
//                Removed unused statements in c4gx_pcie_sopc.out.sdc
//			1.4 - Changed the VME timing for AS#, DS0# and DS1# to meet VME spec
//
//          2.0 - Matrox take over. Change device for
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
//
//////////////////////////////////////////////////////////////////////////////////

module cpuskl_kvb_top (
			 input 	       clkin_125m_p, 
			 input 	       voltage_alert, 

			 // PCIe
			 input 	       sys_rst_n, // platform_rst# (reset from PCIe bus and pwr good)
			 input 	       refclk, // 100MHz reference clock 
			 input 	       rx_in0, // PCIe input
			 output        tx_out0, // PCIe output

			 // VME Interface Signals
			 inout [31:0]  vme_db, // 32-bit data bus
			 output [31:1] vme_a, // 32-bit address bus
			 output [5:0]  vme_am, // address modifier
			 output        vme_lword_n, // long word
			 output        vme_as_n, // address strobe
			 output        vme_ds0_n, // data strobe 0
			 output        vme_ds1_n, // data strobe 1
			 output        vme_write_n, // write
			 output        vme_write, // write
			 output        vme_iack_n, // interrupt acknowledge
			 output        vme_iackout_n, // interrupt acknowledge out
			 input 	       vme_dtack_n, // data transfer acknowledge
			 input [7:1]   vme_irq_n, // interrupt requests
			 output        vme_buffer_oe_n, // VME buffer output enable

			 output [9:0]  prog_tp,
                         input [3:0]   gpio, //[AM]
                         output [3:0]  cam_trigger,//[AM]
                         output [2:0]  prog_led,

			 // UART0 Interface
			 input 	       ser1_rx,
			 output        ser1_tx, 

			 // UART1 Interface
			 input 	       ser2_rx,
			 output        ser2_tx, 

			 // UART2 Interface
			 input 	       ser3_rx,
			 output        ser3_tx, 

			 // UART3 Interface
			 input 	       ser4_rx,
			 output        ser4_tx, 
			 output        ser4_rts_n,

			 // QSPI Interface
			 inout [3:0]   mram_io,
			 output        mram_sck,
			 output        mram_cs_n,

			 // I2C0 Controller
			 inout 	       local_i2c_sda,
			 inout 	       local_i2c_scl,


			 input 	       lpc_clk ,
			 input 	       lpc_frame_n,
			 inout [3:0]   lpc_ad,
			 inout 	       serirq  
			 );

   wire 			       clk50;
   wire 			       clk125;
   wire 			       sync_clk;
   wire 			       pll_lock;
   wire [31:0] 			       pio_out;
   wire 			       pipe_mode;

   wire 			       ser4_rts;
   reg 				       link_active;
   wire [5:0] 			       sync_clks;
   reg 				       sys_rst_n1;
   reg 				       sys_rst_n2;
   reg [4:0] 			       dl_ltssm_int1;
   reg [4:0] 			       dl_ltssm_int2;
   wire 			       platform_wake;
   reg [4:0] 			       cnt;
   reg 				       sys_rst_n_delayed;


   wire [16:0] 			       reconfig_fromgxb;
   wire [3:0] 			       reconfig_togxb;
   wire 			       busy;
   
   wire [63:0] 			       test_out_icm;
   wire [39:0] 			       test_in;
   wire [4:0] 			       dl_ltssm_int;
   wire [3:0] 			       ser_rx;
   wire [3:0] 			       ser_tx;
 
   assign       vme_write = ~vme_write_n;
   assign 	green_led = link_active;
   assign 	red_led =  ~link_active;

   
 /* Assignment of the test_in[39:0] signal -Hard IP
The test_in bus provides runtime control for specific IP core 
features. For normal operation, this bus can be driven to all 0's. The
following bits are defined:
    [0]–Simulation mode. This signal can be set to 1 to accelerate
	    initialization by changing many initialization count.
    [2:1]–reserved.
    [3]–FPGA mode. Set this signal to 1 for an FPGA implementation.
    [2:1]–reserved.
    [6:5] Compliance test mode. Disable/force compliance mode:
             - bit 0–when set, prevents the LTSSM from entering compliance
               mode. Toggling this bit controls the entry and exit from the
               compliance state, enabling the transmission of Gen1 and Gen2
               compliance patterns.
             - bit 1–forces compliance mode. Forces entry to compliance mode
               when timeout is reached in polling.active state (and not all lanes
               have detected their exit condition).
    [7]–Disables low power state negotiation. When asserted, this signal
        disables all low power state negotiation. This bit is set to 1 for Qsys.
    [11:8]–you must tie these signals low.
    [15:13]–lane select.
    [31:16, 12]–reserved.
    [32] Compliance mode test switch. When set to 1, the IP core is in
    compliance mode which is used for Compliance Base Board testing
    (CBB) testing. When set to 0, the IP core is in operates normally.
    Connect this signal to a switch to turn on and off compliance mode.
    Refer to the PCI Express High Performance Reference Design for an 
*/
   assign 	test_in[0]     = 1'b0;
   assign 	test_in[2:1]   = 2'b00;
   assign 	test_in[3]     = 1'b1;
   assign 	test_in[4]     = 1'b0;
   assign 	test_in[6:5]   = 2'b01;
   assign 	test_in[7]     = 1'b1;
   assign 	test_in[11:8]  = 4'b0000;
   assign 	test_in[12]    = 1'b0;
   assign 	test_in[15:13] = 3'b000;
   assign 	test_in[39:16] = 0;

   
   assign   vme_buffer_oe_n = 1'b0;


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
	 dl_ltssm_int1 <= 0;
	 dl_ltssm_int2 <= 0;
      end
      else begin
	 sys_rst_n1 <= sys_rst_n;
	 sys_rst_n2 <= sys_rst_n1;
	 dl_ltssm_int1 <= dl_ltssm_int;
	 dl_ltssm_int2 <= dl_ltssm_int1;
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
   
   always @(posedge clk125 or negedge sys_rst_n2) begin
      if (sys_rst_n2 == 0) begin
	 link_active <= 0;
      end
      else begin
	 if(dl_ltssm_int2 == 5'b01111) begin  // LO
	    link_active  <= 1'b1;
	 end 
	 else if(dl_ltssm_int2 == 5'b10101) begin  // LOs
	    link_active  <= 1'b1;
	 end 
	 else begin
	    link_active  <= 0;
	 end
      end
   end

   //assign sync_clks[5:0] = {6{sync_clk}};

   altgx_reconfig	altgx_reconfig_inst (
					     .reconfig_clk ( clk50 ),
					     .reconfig_fromgxb ( reconfig_fromgxb ),
					     .busy ( busy ),  // This will only be used in reset logic for offset cancellation process. Never used for actual channel reconfiguration
					     .reconfig_togxb ( reconfig_togxb )
					     );

 
   //==========================
   // Set input values
   //==========================
   assign pipe_mode = 1'b0;

   kvb_system u0 (
   	     .clk_50_clk                              (clk50),
      
	     /////////////////////////////////////////////////////////////
	     // I2C Master Local
	     /////////////////////////////////////////////////////////////
	     .i2c_master_0_sda                        (local_i2c_sda),
	     .i2c_master_0_scl                        (local_i2c_scl),
      
      
	     /////////////////////////////////////////////////////////////
	     // PCIe Hard IP
	     /////////////////////////////////////////////////////////////
	     .pcie_hard_ip_0_clocks_sim_clk250_export           (),           //         pcie_hard_ip_0_clocks_sim.clk250_export
	     .pcie_hard_ip_0_clocks_sim_clk500_export           (),           //                                  .clk500_export
	     .pcie_hard_ip_0_clocks_sim_clk125_export           (),           //                                  .clk125_export
	     .pcie_hard_ip_0_fixedclk_clk                       (clk125),                       // Free running clock @ 125 MHz
	     .pcie_hard_ip_0_pcie_rstn_export                   (sys_rst_n),                   //        pcie RESET
      
	     .pcie_hard_ip_0_pipe_ext_pipe_mode                 (pipe_mode),                 //           pcie_hard_ip_0_pipe_ext.pipe_mode
	     .pcie_hard_ip_0_pipe_ext_phystatus_ext             (),             //                                  .phystatus_ext
	     .pcie_hard_ip_0_pipe_ext_rate_ext                  (),                  //                                  .rate_ext
	     .pcie_hard_ip_0_pipe_ext_powerdown_ext             (),             //                                  .powerdown_ext
	     .pcie_hard_ip_0_pipe_ext_txdetectrx_ext            (),            //                                  .txdetectrx_ext
	     .pcie_hard_ip_0_pipe_ext_rxelecidle0_ext           (),           //                                  .rxelecidle0_ext
	     .pcie_hard_ip_0_pipe_ext_rxdata0_ext               (),               //                                  .rxdata0_ext
	     .pcie_hard_ip_0_pipe_ext_rxstatus0_ext             (),             //                                  .rxstatus0_ext
	     .pcie_hard_ip_0_pipe_ext_rxvalid0_ext              (),              //                                  .rxvalid0_ext
	     .pcie_hard_ip_0_pipe_ext_rxdatak0_ext              (),              //                                  .rxdatak0_ext
	     .pcie_hard_ip_0_pipe_ext_txdata0_ext               (),               //                                  .txdata0_ext
	     .pcie_hard_ip_0_pipe_ext_txdatak0_ext              (),              //                                  .txdatak0_ext
	     .pcie_hard_ip_0_pipe_ext_rxpolarity0_ext           (),           //                                  .rxpolarity0_ext
	     .pcie_hard_ip_0_pipe_ext_txcompl0_ext              (),              //                                  .txcompl0_ext
	     .pcie_hard_ip_0_pipe_ext_txelecidle0_ext           (),           //                                  .txelecidle0_ext
      
	     .pcie_hard_ip_0_reconfig_busy_busy_altgxb_reconfig (busy), //      pcie_hard_ip_0_reconfig_busy.busy_altgxb_reconfig
	     .pcie_hard_ip_0_reconfig_fromgxb_0_data            (reconfig_fromgxb),            // pcie_hard_ip_0_reconfig_fromgxb_0.data
	     .pcie_hard_ip_0_reconfig_togxb_data                (reconfig_togxb),                //     pcie_hard_ip_0_reconfig_togxb.data
	     .pcie_hard_ip_0_refclk_export                      (refclk),                      //             pcie_hard_ip_0_refclk.export
	     .pcie_hard_ip_0_rx_in_rx_datain_0                  (rx_in0),                  //              pcie_hard_ip_0_rx_in.rx_datain_0
	     .pcie_hard_ip_0_test_in_test_in                    (test_in),                    //            pcie_hard_ip_0_test_in.test_in
	     .pcie_hard_ip_0_test_out_test_out                  (),                  //           pcie_hard_ip_0_test_out.test_out
	     .pcie_hard_ip_0_tx_out_tx_dataout_0              (tx_out0),                //             pcie_hard_ip_0_tx_out.tx_dataout_0
      
      
	     /////////////////////////////////////////////////////////////
	     // I/Os
	     /////////////////////////////////////////////////////////////
	     .pio_0_in_export                                   ({28'b0000000000000000000000000000, gpio[3:0]}),
	     .pio_1_out_export                                  ({22'b0000000000000000000000, prog_tp[9:0]}),

   
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
	     .vme_intf_0_vme_sysrst_n                           (),
	     .vme_intf_0_vmd_ds1_n                              (vme_ds1_n),
	     .vme_intf_0_vme_ds0_n                              (vme_ds0_n),
	     .vme_intf_0_vme_write_n                            (vme_write_n ),
	     .vme_intf_0_vme_sysrst_n                           (),
	     .vme_intf_0_vme_lword_n                            (vme_lword_n),
	     .vme_intf_0_vme_as_n                               (vme_as_n),
	     .vme_intf_0_vme_am                                 (vme_am),
	     .vme_intf_0_vme_db                                 (vme_db),
	     .vme_intf_0_vme_a                                  (vme_a)
	     );

 lpc2uarts u1 (
    .lpc_clk     (lpc_clk),
    .lpc_reset_n (sys_rst_n),
    .lpc_frame_n (lpc_frame_n),
    .lpc_ad      (lpc_ad),
    .serirq      (serirq),
    .ser_rx      (ser_rx),
    .ser_tx      (ser_tx),
    .ser4_rts_n  (ser4_rts_n)
    );

   assign ser1_tx = ser_tx[0];
   assign ser2_tx = ser_tx[1];
   assign ser3_tx = ser_tx[2];
   assign ser4_tx = ser_tx[3];
   
   assign ser_rx[0] =  ser1_rx;
   assign ser_rx[1] =  ser2_rx;
   assign ser_rx[2] =  ser3_rx;
   assign ser_rx[3] =  ser4_rx;
 

endmodule

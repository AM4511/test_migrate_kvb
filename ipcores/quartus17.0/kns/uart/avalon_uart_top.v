`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////
// Company: Kulicke and Soffa Industries Inc
// Engineer: Richard Carickhoff
// 
// Create Date:    1/20/2016 
// Design Name: 
// Module Name:    avalon_uart_top.v 
// Project Name:   c4gx_gen1x1_vme_bridge
// Target Devices: EP4CGX30CF23C8
// Tool versions:  Quartus Version 14.0
// Description: Avalon interface to UART module
//
// Dependencies: 
//
// Version  Date        Author          Change
// -------------------------------------------------------------------------------
// 1.0      01/20/2016  R. Carickhoff   Created.
// 1.0      04/21/2016  R. Carickhoff   Modified module uart_rfifo.v.
// 1.1      10/25/2017  R. Carickhoff   Modified module to handle consecutive writes
//                                      with s_write remaining active.
//
// Additional Comments:
//
//
//////////////////////////////////////////////////////////////////////////////////

module avalon_uart_top	(
    input  	clk,
    input  	reset,
    input  	[2:0] s_address,
    input  	[7:0] s_writedata,
    input  	s_write,
    input  	s_read,
    input  	s_chipselect,
    output 	s_waitrequest_n,
    output 	[7:0] s_readdata,
    output 	s_irq,
    
// export signals UART
    input 	srx_pad_i,
    output 	stx_pad_o,
    output 	rts_pad_o,
    input 	cts_pad_i,
    output 	dtr_pad_o,
    input 	dsr_pad_i,
    input 	ri_pad_i,
    input 	dcd_pad_i

);

wire ack;
wire enable;
reg  ack1=0;

always @(posedge clk) begin
    if (reset) 
        ack1 <= 0;
    else
        ack1 <= ack;
end

assign s_waitrequest_n = ~((s_read || s_write) && ~ack); 
assign enable = (s_read || s_write) && ~ack1;  

uart_top	the_uart_top(
	 .wb_clk_i (clk),
	 .wb_rst_i (reset),
// Wishbone signals
    .wb_adr_i (s_address),
    .wb_dat_i (s_writedata[7:0]),
    .wb_dat_o (s_readdata[7:0]),
    .wb_we_i  (s_write && enable),
    .wb_stb_i (s_chipselect && enable),
    .wb_cyc_i (s_chipselect && enable),
    .wb_ack_o (ack),
    .wb_sel_i (4'b0),
	 .int_o    (s_irq), // interrupt request

// UART	signals
// serial input/output
	 .stx_pad_o (stx_pad_o),
    .srx_pad_i (srx_pad_i),

// modem signals
	 .rts_pad_o (rts_pad_o),
    .cts_pad_i (cts_pad_i),
    .dtr_pad_o (dtr_pad_o),
    .dsr_pad_i (dsr_pad_i),
    .ri_pad_i  (ri_pad_i),
    .dcd_pad_i (dcd_pad_i)

);
 
 endmodule



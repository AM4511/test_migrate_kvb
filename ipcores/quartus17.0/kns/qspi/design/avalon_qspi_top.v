`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Kulicke and Soffa Industries Inc
// Engineer: Richard Carickhoff
// 
// Create Date:    1/21/2016 
// Design Name: 
// Module Name:    avalon_qspi_top.v 
// Project Name:   c4gx_gen1x1_vme_bridge
// Target Devices: EP4CGX30CF23C8
// Tool versions:  Quartus Version 14.0
// Description: Avalon interface to QSPI module
//
// Dependencies: 
//
// Version  Date        Author          Change
// -------------------------------------------------------------------------------
// 1.0      01/21/2016  R. Carickhoff   Created.
// 1.1      10/25/2017  R. Carickhoff   Updated ack circuit to emulate single read
//                                      and write Avalon access.
//
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

// s_address[17:0] = 0x00000 - 0x1FFFF  spi memory 131,072 words of 8 bits
// s_address{17:0] = 0x20000 - 0x20000  Write: Status Register[7:0], Read: Status Register[7:0]
// s_address{17:0] = 0x20001 - 0x20001  Write: SPI Command[7:0]
// Refer to MR10Q010 datasheet for definition of SPI comands and status register

module avalon_qspi_top ( 
//	global clk/reset
	input  clk, // 125mhz
	input  reset,
	
// Avalon Interface signals
	input  s_write,
	input  s_read,
	input  [17:0] s_address, 
	input  [7:0] s_writedata,
	output [7:0] s_readdata,
	output s_waitrequest,
    
// Quad SPI control signals
	output qspi_sck,
	output qspi_cs_n,
	inout	 [3:0] qspi_dat
);

wire	ack;
reg	ack1=0;
wire	spi_cmd;
wire	sts_cmd;

always @(posedge clk) begin
    if (reset) 
        ack1 <= 0;
    else
        ack1 <= ack;
end

assign s_waitrequest = (s_read || s_write) && ~(ack && ~ack1);
assign sts_cmd = (s_address == 18'h20000);
assign spi_cmd = (s_address == 18'h20001);

// SPI Interface Control Module
qspi_top qspi_top_inst (
	.clk(clk),
	.reset(reset),
   .write(s_write && ~(ack && ack1)),
   .read(s_read && ~(ack && ack1)), 
   .spi_cmd(spi_cmd), 
	.sts_cmd(sts_cmd),
	.address({7'h0, s_address[16:0]}),
	.writedata(s_writedata),
	.readdata(s_readdata),
	.ack(ack),
	.qspi_sck(qspi_sck),
	.qspi_cs_n(qspi_cs_n),
	.qspi_dat(qspi_dat)
);

endmodule



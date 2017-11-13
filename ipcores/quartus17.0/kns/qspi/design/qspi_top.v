`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////
// Company: Kulicke and Soffa Industries Inc
// Engineer: Richard Carickhoff
// 
// Create Date:    1/20/2016 
// Design Name: 
// Module Name:    qspi_top.v 
// Project Name:   c4gx_gen1x1_vme_bridge
// Target Devices: EP4CGX30CF23C8
// Tool versions:  Quartus Version 14.0
// Description: qspi_top Module generates SPI commands sequences using OpenCore 
// Quad SPI Flash Controller module "llqspi".  the qspi_top module was designed 
// to be used with MR10Q010 Flash Controller from Everspin.  The llqspi module
// was modified to provide a slower SPI clock when reading from SPI.  The i_dat[3:0] 
// signals were also modified to be clocked on the rising edge of the SPI clock.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
/////////////////////////////////////////////////////////////////////////////////////
//
// Designed for Everspin MR10Q010 Quad SPI MRAM organized as 131,072 words of 8 bits
// address[23:0] = Max. SPI data memory space of 8-bits words
// spi_sts = SPI Status Register[7:0] Supports Read or Write
// spi_cmd = SPI Command[7:0] Supports Write only
//
/////////////////////////////////////////////////////////////////////////////////////

module qspi_top ( 
//	global clk/reset
	input		clk,		
	input		reset,

// Slave memory interface signals	
   input		write,
   input		read, 
	input		spi_cmd,
	input		sts_cmd,
	input		[23:0] address,
	input		[7:0] writedata,
	output	reg [7:0] readdata,
	output	reg ack,
	
// Quad SPI control signals
	output	qspi_sck,
	output	qspi_cs_n,
	inout		[3:0] qspi_dat
);

parameter QSPI_DISABLE = 0;

// SPI Commands Supported
localparam 	CMD_RDSR  =	8'h05;		// Returns the contents of the 8-bit Status Register
localparam 	CMD_WREN	 =	8'h06;		// Sets the Write Enable Latch (WEL) bit in the status register to 1
localparam 	CMD_WRDI	 =	8'h04;		// Resets the Write Enable Latch (WEL) bit in the status register to 0
localparam 	CMD_WRSR	 =	8'h01;		// Writes new values to the entire Status Register
localparam 	CMD_SLEEP =	8'hb9;		// Initiates Sleep Mode
localparam 	CMD_WAKE	 =	8'hab;		// Terminates Sleep Mode
localparam	CMD_FRQAD =	8'heb;		// Fast Read Quad Address and Data
localparam	CMD_READ  =	8'h03;		// Read Single Address and Data (SCK 40 MHz max)
localparam	CMD_FWQAD =	8'h12;		//	Fast Write Quad Address and Data
localparam	CMD_WRITE =	8'h02;		// Write Single Address and Data
localparam 	CMD_DQPI	 =	8'hff;		// Disable QSPI Mode

// QSPI Command Sequence States
localparam	QSPI_CMD_IDLE		= 4'h0;
localparam	QSPI_CMD_BEGIN		= 4'h1;
localparam	QSPI_SEQ_BEGIN		= 4'h2;
localparam	QSPI_SEQ1_BEGIN	= 4'h3;
localparam	QSPI_SEQ1_END		= 4'h4;
localparam	QSPI_SEQ2_BEGIN	= 4'h5;
localparam	QSPI_SEQ2_END		= 4'h6;
localparam	QSPI_SEQ3_BEGIN	= 4'h7;
localparam	QSPI_SEQ3_END		= 4'h8;
localparam	QSPI_SEQ_END		= 4'h9;
localparam	QSPI_CMD_END		= 4'ha;

localparam	SET_XIP_MODE = 8'hef;
localparam  RST_XIP_MODE = 8'hff;

// local variables	
reg	wr;					// starts spi command sequence
reg	spd;					// 0 -> normal SPI, 1 -> QSPI
reg	dir;					// 0 -> read data from SPI, 1 -> write data to SPI
reg	hold;					// tells module that another command sequence will be issued
wire	valid;				// tells when read data is valid in o_word
wire	busy;					// active during spi cycle
reg	clk_enb;				// used to reduce o_sck rate
reg   [2:0] clk_cnt;    // number of counts to reduce o_sck rate
reg	rd_sts_flg;			// set during RDSR cycle
reg	[31:0] i_word;		// SPI data to be written
wire	[31:0] o_word;		// data received from SPI
reg	[3:0] state;
wire	[1:0] mode;
wire	[3:0] din;
wire	[3:0] dout;
reg	[7:0] status_reg; // {SRWD, QPI_Mode, RESV, RESV, Block_Protect[1:0], WEL, RESV}
reg	[1:0] len;			// 0=>8bits, 1=>16 bits, 2=>24 bits, 3=>32 bits
reg	[36:0] cmd_seq1;	// max. of 3 possible SPI sequences
reg	[36:0] cmd_seq2;
reg	[36:0] cmd_seq3;

// Lower Lever QSPI Module
llqspi llqspi_inst (
	.i_clk(clk),						// master clk
	.i_clk_enb(clk_enb || dir), 	// dir = (1)full speed, (0)half speed
	.i_wr(wr),							// starts spi command sequence
	.i_hold(hold),						// tells module that another command sequence will be issued
	.i_word(i_word),					// SPI data to be written
	.i_len(len),						// 0=>8bits, 1=>16 bits, 2=>24 bits, 3=>32 bits
	.i_spd(spd),						// 0 -> normal SPI, 1 -> QSPI
	.i_dir(dir), 						// 0 -> read from SPI, 1 -> write to SPI
	.o_word(o_word),					// data received from SPI
	.o_valid(valid),					// SPI read data valid
	.o_busy(busy),						// SPI cycle being executed
	.o_sck(qspi_sck),					// SPI clock = clk/2 for spi_write and clk/4 for spi_read
	.o_cs_n(qspi_cs_n),				// SPI chip select
	.o_mod(mode[1:0]),				// mode=0x spi_mode 
											// mode=10 qspi_mode reading
											// mode=11 qspi_mode writing
	.o_dat(dout[3:0]), 				// for spi_mode {HOLDn, WPn, z, mosi}
											// for qspi_mode write_data[3:0]
	.i_dat(din[3:0])					// for spi_mode {HOLDn, WPn, miso, mosi}
);											// for qspi_mode read_data[3:0]

assign qspi_dat[3:0] = ~mode[1] ? {2'b11, 1'bz, dout[0]} : (dir & busy) ? dout[3:0] : 4'bzzzz;
assign din[3:0] = qspi_dat[3:0];

// clk_enb reduces rate of qspi_sck for SPI reads
always @ (posedge clk or posedge reset) begin
	if (reset) begin
		clk_enb <= 0;
		clk_cnt <= 0;
	end
	else begin
	  if ((clk_cnt == 5) || (dir && !busy)) begin
       clk_enb <= 1'b1;
		 clk_cnt <= 0;
	end
	else begin
       clk_enb <= 0;
       clk_cnt <= clk_cnt + 1'b1;
     end
        end
end

// State Machine for issuing SPI commands
always @ (posedge clk or posedge reset) begin
	if (reset) begin
		wr   <= 1'b0;
		hold <= 1'b0;
		spd  <= 1'b0;
		dir  <= 1'b0;
		ack  <= 1'b0;
		len  <= 2'b00;
		status_reg <= 8'b0;
		rd_sts_flg <= 1'b0;
		state <= QSPI_CMD_IDLE;
	end
	else begin
		case (state)
			QSPI_CMD_IDLE: begin  // wait here until host issues a command
				wr   <= 1'b0;
				hold <= 1'b0;
				spd  <= 1'b0;
				dir  <= 1'b0;
				ack  <= 1'b0;
				rd_sts_flg <= 1'b0;
				if (read || write)
					state <= QSPI_CMD_BEGIN;
			end
			
			QSPI_CMD_BEGIN: begin  // decode the command here 
				if (write) begin
					if (sts_cmd) begin // host wants to write to SPI status register
						cmd_seq1 <= {CMD_WRSR, writedata, 16'h0, 5'b01010};  // len[1:0]=01, spd=0, dir=1, hold=0
						state <= QSPI_SEQ_BEGIN;
					end
					else if (spi_cmd) begin // host wants to issue a SPI command
						case (writedata)
							CMD_RDSR: begin	// Read Status Register - for testing only
								cmd_seq1 <= {CMD_RDSR, 24'h0, 5'b00011};  // len[1:0]=00, spd=0, dir=1, hold=1
								cmd_seq2 <= {32'h0, 5'b00000};  				// len[1:0]=00, spd=0, dir=0, hold=0
								rd_sts_flg <= 1'b1;
								state <= QSPI_SEQ_BEGIN;
							end
							CMD_WREN: begin  	// Write Enable
								cmd_seq1 <= {CMD_WREN, 24'h0, 5'b00010};  // len[1:0]=00, spd=0, dir=1, hold=0
								state <= QSPI_SEQ_BEGIN;
							end
							CMD_WRDI: begin  	// Write Disable
								cmd_seq1 <= {CMD_WRDI, 24'h0, 5'b00010};  // len[1:0]=00, spd=0, dir=1, hold=0
								state <= QSPI_SEQ_BEGIN;
							end
							CMD_SLEEP: begin  // Enter Sleep Mode
								cmd_seq1 <= {CMD_SLEEP, 24'h0, 5'b00010};  // len[1:0]=00, spd=0, dir=1, hold=0
								state <= QSPI_SEQ_BEGIN;
							end
							CMD_WAKE: begin  	// Exit Sleep Mode
								cmd_seq1 <= {CMD_WAKE, 24'h0, 5'b00010};  // len[1:0]=00, spd=0, dir=1, hold=0
								state <= QSPI_SEQ_BEGIN;
							end
							CMD_DQPI: begin  	// Disable QPI Mode
								cmd_seq1 <= {CMD_DQPI, 24'h0, 5'b00110};  // len[1:0]=00, spd=1, dir=1, hold=0
								state <= QSPI_SEQ_BEGIN;
							end
							default: begin  // not a supported SPI command
								ack <= 1'b1;
								state <= QSPI_CMD_END;  
							end
						endcase
					end
					else begin	// host wants to write to SPI memory
                        if (QSPI_DISABLE == 0) begin  // QSPI mode
                            cmd_seq1 <= {CMD_FWQAD, 24'h0, 5'b00011}; 	// len[1:0]=00, spd=0, dir=1, hold=1
    						cmd_seq2 <= {address, writedata, 5'b11110};  // len[1:0]=11, spd=1, dir=1, hold=0
    						state <= QSPI_SEQ_BEGIN;
                        end
                        else begin  // SPI mode
                            cmd_seq1 <= {CMD_WRITE, 24'h0, 5'b00011}; 	// len[1:0]=00, spd=0, dir=1, hold=1
    						cmd_seq2 <= {address, writedata, 5'b11010};  // len[1:0]=11, spd=0, dir=1, hold=0
    						state <= QSPI_SEQ_BEGIN;
						end
					end
				end
				else if (read) begin
					if (sts_cmd) begin	// host wants to read SPI status reg
						cmd_seq1 <= {CMD_RDSR, 24'h0, 5'b00011};  // len[1:0]=00, spd=0, dir=1, hold=1
						cmd_seq2 <= {32'h0, 5'b00000};  				// len[1:0]=00, spd=0, dir=0, hold=0
						rd_sts_flg <= 1'b1;
						state <= QSPI_SEQ_BEGIN;
					end
					else if (spi_cmd) begin  // reading a SPI command is not a supported
						readdata <= 8'h0;
						ack <= 1'b1;
						state <= QSPI_CMD_END;
					end
					else begin  // host wants to read from SPI memory
                        if (QSPI_DISABLE == 0) begin    // QSPI mode
                            cmd_seq1 <= {CMD_FRQAD, 24'h0, 5'b00011}; 		// len[1:0]=00, spd=0, dir=1, hold=1
    						cmd_seq2 <= {address, RST_XIP_MODE, 5'b11111}; 	// len[1:0]=11, spd=1, dir=1, hold=1
    						cmd_seq3 <= {32'h0, 5'b00100};  						// len[1:0]=00, spd=1, dir=0, hold=0
    						state <= QSPI_SEQ_BEGIN;
						end
						else begin    // SPI mode
                            cmd_seq1 <= {CMD_READ, 24'h0, 5'b00011}; 		// len[1:0]=00, spd=0, dir=1, hold=1
    						cmd_seq2 <= {address, 8'h0, 5'b10011}; 	        // len[1:0]=10, spd=0, dir=1, hold=1
    						cmd_seq3 <= {32'h0, 5'b00000};  						// len[1:0]=00, spd=0, dir=0, hold=0
    						state <= QSPI_SEQ_BEGIN;
						end
					end
				end
				else begin  // read or write was not set
					state <= QSPI_CMD_IDLE;
				end
			end

			QSPI_SEQ_BEGIN: begin  // start first command sequence
				{i_word, len, spd, dir, hold} <= cmd_seq1;
				wr <= 1'b1;
				state <= QSPI_SEQ1_BEGIN;
			end

			QSPI_SEQ1_BEGIN: begin  // wait for busy to set before continuing
				if (busy) begin
					wr <= 1'b0;
					state <= QSPI_SEQ1_END;
				end
			end
			
			QSPI_SEQ1_END: begin  // wait for seq to end then check if there's another seq
				if (~busy) begin
					if (hold) begin  // start second sequence
						{i_word, len, spd, dir, hold} <= cmd_seq2;
						wr <= 1'b1;
						state  <= QSPI_SEQ2_BEGIN;
					end
					else begin
						state <= QSPI_SEQ_END;
					end
				end
			end
			
			QSPI_SEQ2_BEGIN: begin  // wait for busy to set before continuing
				if (busy) begin
					wr <= 1'b0;
					state <= QSPI_SEQ2_END;
				end
			end
			
			QSPI_SEQ2_END: begin  // wait for seq to end then check if there's another seq
				if (~busy) begin
					if (hold) begin  // start third sequence
						{i_word, len, spd, dir, hold} <= cmd_seq3;
						wr <= 1'b1;
						state  <= QSPI_SEQ3_BEGIN;
					end
					else begin
						state <= QSPI_SEQ_END;
					end
				end
			end
			
			QSPI_SEQ3_BEGIN: begin  // wait for busy to set before continuing
				if (busy) begin
					wr <= 1'b0;
					state <= QSPI_SEQ3_END;
				end
			end
			
			QSPI_SEQ3_END: begin  // wait for last seq to end
				if (~busy) begin
					state <= QSPI_SEQ_END;
				end
			end
			
			QSPI_SEQ_END: begin  // all sequences are done now
				if (rd_sts_flg) begin // check if RDSR command was being executed
					status_reg <= o_word[7:0];
				end
				readdata <= o_word[7:0];  // if read command it will need this read data
				ack <= 1'b1;  // let the host know that we are done
				state <= QSPI_CMD_END;
			end
			
			QSPI_CMD_END: begin  // wait for host to finish
				if (~read && ~write) begin
					ack <= 1'b0;  // reset ack and return to idle state
					state <= QSPI_CMD_IDLE;
				end
			end

			default: begin
				state <= QSPI_CMD_IDLE;
			end
		endcase
	end
end

endmodule 
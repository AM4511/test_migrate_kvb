`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Kulicke and Soffa Industries Inc
// Engineer: Richard Carickhoff
// 
// Create Date:    1/21/2016 
// Design Name: 
// Module Name:    vme_intf.v 
// Project Name:   c4gx_gen1x1_vme_bridge
// Target Devices: EP4CGX30CF23C8
// Tool versions:  Quartus Version 14.0
// Description:    VME Interface
//
// Dependencies: 
//
// Version  Date        Author          Change
// ----------------------------------------------------------------------------------
// 1.0      01/21/2016  R. Carickhoff   Created.
// 1.1      10/25/2016  R. Carickhoff   Synchronized IRQ inputs.
// 1.2      12/14/2017  R. Carickhoff   Delayed additional clock cycle to DS0 and DS1.
// 1.3	    03/13/2018	D. Rauth	Added WIDTH for A32.
// 1.4      03/28/2018  K. Paist	Make vme outputs to pins --> registers
//
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module	vme_intf #(
parameter A32_WIDTH = 30,		// A32 width (4-byte word address)
parameter A32_OFFSET = 30'h0,	// A32 offset (4-byte word address)
parameter BIG_ENDIAN = 1'b1		// convert Little Endian to Big Endian
)(
//	global clk/reset
input		clk, // 125mhz clock (8nsec)
input 	reset,
	
// avalon 16-bit slave interface	
input		s_write_0,
input		s_read_0,  
input		[24:0] s_address_0,
input		[15:0] s_writedata_0,
input		[1:0] s_byteenable_0,
output	[15:0] s_readdata_0,
output	s_waitrequest_0,
output   s_irq_0,

// avalon 32-bit slave interface 	
input		s_write_1,
input		s_read_1,  
input		[(A32_WIDTH-1):0] s_address_1,
input		[31:0] s_writedata_1,
input		[3:0] s_byteenable_1,
output	[31:0] s_readdata_1,
output	s_waitrequest_1,

// VME Interface Signals
inout		[31:0] vme_db,			// data bus
output	[31:1] vme_a,			// address bus
output	[5:0]  vme_am,			// address modifier
output	vme_lword_n,			// long word
output	vme_sysrst_n,			// system reset
//output	vme_as_n,				// address strobe
//output	vme_ds0_n,				// data strobe 0
//output	vme_ds1_n,				// data strobe 1
output	reg vme_as_n,				// address strobe
output	reg vme_ds0_n,				// data strobe 0
output	reg vme_ds1_n,				// data strobe 1
output	vme_write_n,			// write
output	vme_iack_n,				// interrupt acknowledge
output	vme_iackout_n,			// interrupt acknowledge out
input		vme_dtack_n,			// data transfer acknowledge
input		vme_sysfail_n,			// system fail
input		[7:1] vme_irq_n		// interrupt request
//input 	vme_berr_n,				// bus error
//input 	vme_bbsy_n,				// bus busy
//output	vme_bclr_n,				// bus clear
//input		[3:0] vme_br_n,		// bus request
//input		[3:0] vme_bgin_n,		// bus grant in
//output	[3:0] vme_bgout_n		// bus grant out
);


// variables 
wire		A32_memory;
wire		A24_memory;
wire		A16_memory;
wire		AIRQ_memory;
wire     DS0;
wire     DS1;
wire     A01;
wire     BYTE;
wire     LWORD;
wire     read;
wire     write;
wire     s_read;
wire     s_write;
wire		clk_1mhz;
wire     iack;
wire		dtack;
reg		access_done = 0;
wire		dtack_to_err;
wire		iackout;
wire     brd_dtack;
wire		write_0;
wire		write_1;
wire		read_0;
wire		read_1;
reg		vme_dtack_q;
reg      vme_access = 0;
reg      vme_access2 = 0;
reg      vme_write = 0;
wire		[2:0] vec_addr;
reg		[4:0] cntl_out = 5'b00000;
wire		[3:0] byteenable;
wire     [15:0] vme_db_0;
wire     [31:0] vme_db_1;
wire     [31:0] vme_data_bus;
wire		[31:0] vme_dbin;
wire		[7:0] brd_vector;
wire		[7:1] brd_irq_n;
wire		[7:1] irq_n;
reg         [7:1] vme_irq_nq;
wire		[15:0] readdata_0;
wire		[31:0] readdata_1;
wire		[15:0] writedata_0;
wire		[31:0] writedata_1;
wire		[1:0] byteenable_0;
wire		[3:0] byteenable_1;
reg      [9:0] state = IDLE;

localparam IDLE   = 10'b0000000001;
localparam STATE1 = 10'b0000000010;
localparam STATE2 = 10'b0000000100;
localparam STATE3 = 10'b0000001000;
localparam STATE4 = 10'b0000010000;
localparam STATE5 = 10'b0000100000;
localparam STATE6 = 10'b0001000000;
localparam STATE7 = 10'b0010000000;
localparam STATE8 = 10'b0100000000;
localparam STATE9 = 10'b1000000000;


// DTACK Timer
dtack_timer dtack_timer_inst (
	.reset(reset),							// input
	.clk(clk),								// input
	.start(vme_access),					// input  (starts timer when active, resets when inactive)
	.dtack_to_err(dtack_to_err)   	// output (200usec timeout)
);

// Bus Arbiter			
//arbiter arbiter_inst (
//	.reset(reset),							// input
//	.clk(clk_1mhz),						// input
//	.vme_br_n(vme_br_n[3:0]),			// input  (bus request low active)
//	.vme_bbsy_n(vme_bbsy_n),			// input  (bus busy low active)
//	.vme_bgout_n(vme_bgout_n[3:0]),	// output (bus grant low active)
//	.vme_bclr_n(vme_bclr_n)				// output (bus clear low active)
//);

// Interrupt Handler for all vme interrupts
interrupt_handler interrupt_handler_inst (
	.reset(reset),							// input
	.clk(clk),								// input
	.iack(iack), 							// input  (interrupt acknowledge cycle)
	.dtack(access_done),					// input	 (data transfer complete when active)
	.irq_n(irq_n[7:1]), 					// input  (irqs generated by board and vme backplane low active)
	.vec_addr(vec_addr[2:0]),			// output (8-bit vector associated with irq)
	.irq(s_irq_0)							// output (irq sent to host)
);

// Interrupt Controller for board interrupts
interrupt_control interrupt_control_inst (
	.reset(reset),							// input
	.clk(clk),								// input
	.iack(iack && ~vme_as_n ), 		// input  (interrupt acknowledge cycle)
	.dtack_to_err(dtack_to_err && ~iack && (s_read || s_write)),		// input (interrupt input) don't generate error for iack cycles
	.vec_addr(vec_addr[2:0]),			// input  (irq number being addressed)
	.iackout(iackout),					// output (inactive when board irq is being acknowledged)
	.dtack(brd_dtack),					// output (interrupt controller dtack)
	.irq_n(brd_irq_n[7:1]), 			// output (irqs generated by board only)
	.vector(brd_vector[7:0]) 			// output (8-bit vector associated with board irq)
);

always @ (posedge clk or posedge reset) begin
    if (reset) begin
        vme_dtack_q <= 1'b0;
        vme_irq_nq[7:1] <= 7'b1111111;
    end
    else begin  // sync to clk
        vme_dtack_q <= ~vme_dtack_n;
        vme_irq_nq[7:1] <= vme_irq_n[7:1];
    end
end

assign dtack = vme_dtack_q || brd_dtack || dtack_to_err;

assign iack = AIRQ_memory && s_read;  // IACK access

assign irq_n[7:1] = vme_irq_nq[7:1] & brd_irq_n[7:1];  // combine vme and board interrupts

assign s_waitrequest_0 = (s_read_0 || s_write_0) && ~access_done;
assign s_waitrequest_1 = (s_read_1 || s_write_1) && ~access_done;

assign read_0 = s_read_0 && s_waitrequest_0;   
assign write_0 = s_write_0 && s_waitrequest_0; 

assign read_1 = s_read_1 && s_waitrequest_1;   
assign write_1 = s_write_1 && s_waitrequest_1; 

assign read = read_0 || read_1;
assign write = write_0 || write_1;

assign s_read = s_read_0 || s_read_1;
assign s_write = s_write_0 || s_write_1;

// vme address space assignments
assign A32_memory  = (s_read_1 || s_write_1);
assign A24_memory  = (s_read_0 || s_write_0) && (s_address_0[24:23] == 2'b00);
assign A16_memory  = (s_read_0 || s_write_0) && (s_address_0[24:23] == 2'b01);
assign AIRQ_memory = (s_read_0 || s_write_0) && (s_address_0[24:23] == 2'b10); // interrupt acknowledge (IACK) space

// vme address selection							
assign vme_a[31:1] = AIRQ_memory ? {28'h0, vec_addr[2:0]} :
	                   A32_memory ? {({{30-A32_WIDTH{1'b0}}, s_address_1[(A32_WIDTH-1):0]}), A01} + {A32_OFFSET, 1'b0} :
							 A24_memory ? {8'h0, s_address_0[22:0]} : 
							 A16_memory ? {16'h0, s_address_0[14:0]} : 31'h0 ;
							 
// vme address modifier selection
assign vme_am[5:0] = A32_memory ? 6'h0D :			// extended supervisory data access
                     A24_memory ? 6'h3D :			// standard supervisory data access
							A16_memory ? 6'h2D : 6'h0;	// short supervisory data access

// Convert little Endian to Big Endian 
assign s_readdata_0[15:0] = BIG_ENDIAN ? {readdata_0[7:0], readdata_0[15:8]} : readdata_0[15:0] ;
assign s_readdata_1[31:0] = BIG_ENDIAN ? {readdata_1[7:0], readdata_1[15:8], readdata_1[23:16], readdata_1[31:24]} : readdata_1[31:0] ;
assign writedata_0[15:0]  = BIG_ENDIAN ? {s_writedata_0[7:0], s_writedata_0[15:8]} : s_writedata_0[15:0] ;
assign writedata_1[31:0]  = BIG_ENDIAN ? {s_writedata_1[7:0], s_writedata_1[15:8], s_writedata_1[23:16], s_writedata_1[31:24]} : s_writedata_1[31:0] ;
assign byteenable_0[1:0]  = BIG_ENDIAN ? {s_byteenable_0[0], s_byteenable_0[1]} : s_byteenable_0[1:0] ;
assign byteenable_1[3:0]  = BIG_ENDIAN ? {s_byteenable_1[0], s_byteenable_1[1], s_byteenable_1[2], s_byteenable_1[3]} : s_byteenable_1[3:0]  ;

// D16 vme write data selection								
assign vme_db_0[15:0] = ( s_write_0 && ~BYTE ) ? writedata_0[15:0] : 
							   ( s_write_0 &&  BYTE &&  DS0 ) ? {8'h0, writedata_0[7:0]} :
							   ( s_write_0 &&  BYTE &&  DS1 ) ? {writedata_0[15:8], 8'h0} : 16'h0 ;

// D16 Avalon read data selection includes board IACK vector data								
assign readdata_0[15:0] = ( s_read_0 && ~BYTE ) ? vme_dbin[15:0] :
								  ( s_read_0 &&  BYTE && DS0 ) ? {8'h0, vme_dbin[7:0]} :
								  ( s_read_0 &&  BYTE && DS1 ) ? {vme_dbin[15:8], 8'h0} : 16'h0 ;

// D32 vme write data selection 
assign vme_db_1[31:16] = ( s_write_1 &&  LWORD ) ? writedata_1[31:16]  : 16'h0 ;							  
assign vme_db_1[15:0]  = ( s_write_1 &&  LWORD ) ? writedata_1[15:0]  :
							    ( s_write_1 && ~LWORD && ~BYTE && ~A01 ) ? writedata_1[31:16] :
							    ( s_write_1 && ~LWORD && ~BYTE &&  A01 ) ? writedata_1[15:0] : 
							    ( s_write_1 && ~LWORD &&  BYTE && ~A01 &&  DS0 ) ? {8'h0, writedata_1[23:16]} :
							    ( s_write_1 && ~LWORD &&  BYTE && ~A01 &&  DS1 ) ? {writedata_1[31:24], 8'h0} : 
							    ( s_write_1 && ~LWORD &&  BYTE &&  A01 &&  DS0 ) ? {8'h0, writedata_1[7:0]} :
							    ( s_write_1 && ~LWORD &&  BYTE &&  A01 &&  DS1 ) ? {writedata_1[15:8], 8'h0} : 16'h0 ;

// D32 Avalon read data selection																	 
assign readdata_1[31:0] = ( s_read_1 &&  LWORD ) ? vme_dbin[31:0] :
								  ( s_read_1 && ~LWORD && ~BYTE && ~A01 ) ? {vme_dbin[15:0], 16'h0} :
                          ( s_read_1 && ~LWORD && ~BYTE &&  A01 ) ? {16'h0, vme_dbin[15:0]} :
								  ( s_read_1 && ~LWORD &&  BYTE && ~A01 && DS0 ) ? {8'h0, vme_dbin[7:0], 16'h0} : 
								  ( s_read_1 && ~LWORD &&  BYTE && ~A01 && DS1 ) ? {vme_dbin[15:8], 24'h0} :
								  ( s_read_1 && ~LWORD &&  BYTE &&  A01 && DS0 ) ? {24'h0, vme_dbin[7:0]} : 
								  ( s_read_1 && ~LWORD &&  BYTE &&  A01 && DS1 ) ? {16'h0, vme_dbin[15:8], 8'h0} : 32'h0 ;

// vme data bus selection
assign vme_data_bus[31:0] = A32_memory ? vme_db_1[31:0] : {16'h0, vme_db_0[15:0]} ;
assign vme_db[31:0] = write ? vme_data_bus[31:0]: 32'hz ;
assign vme_dbin[31:16] = vme_db[31:16] ;
assign vme_dbin[15:0]  = AIRQ_memory && ~iackout ? {8'hff, brd_vector[7:0]} : vme_db[15:0] ; // board irq vector : vme bus vector

// vme control signals assignments
assign vme_lword_n   = ~((s_read || s_write) && LWORD);
assign vme_write_n   = ~vme_write;
assign vme_iack_n    = ~iack;
assign vme_iackout_n = ~(iackout && ~vme_as_n);
assign vme_sysrst_n  = ~reset;

// vme spec for DS0, DS1 and AS is a min. 35ns delay after vme address becomes active
// using state6 for AS provides a 48nsec delay
// using state7 for DS0 and DS1 provides a 56nsec delay
// master must not drive DS0 or DS1 active until AS is active. delay 8ns after AS
//assign vme_as_n  = ~(vme_access && (s_read || s_write));
//assign vme_ds0_n = ~(vme_access2 && (s_read || s_write) && DS0);  // delay 8ns from AS
//assign vme_ds1_n = ~(vme_access2 && (s_read || s_write) && DS1);  // delay 8ns from AS

assign byteenable[3:0] = A32_memory ? byteenable_1[3:0] : {2'b00, byteenable_0[1:0]};

// determine vme control signals based on Avalon byte enables signals
// used VMEbus Handbook, 2nd Edition Pg50 to establish these values
// cntl_out = {DS1(4), DS0(3), A01(2), LWORD(1), BYTE(0)}
always @ (byteenable) begin 
	case (byteenable)
		4'b1111 : cntl_out <= 5'b11010; 
		4'b0011 : cntl_out <= 5'b11100;
		4'b1100 : cntl_out <= 5'b11000;
		4'b0001 : cntl_out <= 5'b01101;
		4'b0010 : cntl_out <= 5'b10101;
		4'b0100 : cntl_out <= 5'b01001;
		4'b1000 : cntl_out <= 5'b10001;
		default : cntl_out <= 5'b00000;
	endcase
end

assign BYTE  = cntl_out[0];
assign LWORD = cntl_out[1];
assign A01   = cntl_out[2];
assign DS0   = cntl_out[3];
assign DS1   = cntl_out[4];

// wait 3 clocks before starting vme access.  Allow address and data to settle.
always @ (posedge clk or posedge reset) begin
	if (reset) begin
        vme_as_n <= 1'b1;
        vme_ds0_n <= 1'b1;
        vme_ds1_n <= 1'b1;
        vme_write <= 1'b0;
        vme_access <= 1'b0;
        vme_access2 <= 1'b0;
		access_done <= 1'b0;
		state <= IDLE;
	end
	else begin
		case(state)
      		
		IDLE: begin
            vme_as_n <= 1'b1;
            vme_ds0_n <= 1'b1;
            vme_ds1_n <= 1'b1;
            vme_access <= 1'b0;
            vme_access2 <= 1'b0;
            access_done <= 1'b0;
            if (read || write) begin
                vme_write <= s_write; 
				state <= STATE1;
			end
		end
			
		STATE1: begin
			state <= STATE2;
		end
		
		STATE2: begin
			state <= STATE3;
		end
		
		STATE3: begin
			state <= STATE4;
		end
		
		STATE4: begin
			state <= STATE5;
		end
		
		STATE5: begin
            vme_as_n <= !(s_read || s_write);
            vme_access <= 1'b1;		    
			state <= STATE6;
		end
		
		STATE6: begin
            vme_ds0_n <= !((s_read || s_write) && DS0);  // delay 8ns from AS
            vme_ds1_n <= !((s_read || s_write) && DS1);  // delay 8ns from AS
            vme_access2 <= 1'b1;		    
			state <= STATE7;
		end
		
		STATE7: begin
			state <= STATE8;
		end
		
		STATE8: begin // check for dtack
			if(dtack) begin
				access_done <= 1'b1;
				state <= STATE9;
			end
		end
				
		STATE9: begin // wait for dtack to go inactive
            vme_as_n <= 1'b1;
            vme_ds0_n <= 1'b1;
            vme_ds1_n <= 1'b1;
			vme_access <= 1'b0;
			vme_access2 <= 1'b0;
            access_done <= 1'b0;
			if (~dtack) begin 
				state <= IDLE;
			end
		end

		default: state <= IDLE;
		
		endcase
	end
end	

endmodule

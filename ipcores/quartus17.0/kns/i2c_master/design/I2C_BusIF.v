// FILE: I2C_BusIF.v
// DATE: 5/17/2017
//
//  This is block connects the I2C bus to the main I2C state machine. It is
//  just the I2C I/O with open drain output controls.
//
// Revision History:
// ****************************************************************************
module I2C_BusIF(
	inout  SCL,	// Serial Clock (bus connection)		
	inout  SDA,	// Serial Data (bus connection)
	input  SCL_out,	// clock output control signal from MainSM
	output SCL_in,	// clock signal from I2C bus
	input  SDA_out,	// data output control signal from MainSM
	output SDA_in	// data signal from I2C bus
);

assign SCL_in = SCL;	// clock input buffer
assign SDA_in = SDA;	// data input buffer

assign SCL = SCL_out ? 1'bz : 1'b0;	// clock open drain output
assign SDA = SDA_out ? 1'bz : 1'b0;	// clock open drain output

endmodule


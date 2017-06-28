// FILE: dtack_timer.v
// DATE: 10/29/2015
`timescale 1ns / 1ps

module dtack_timer (
input		reset,
input 	clk, 
input		start,
output	reg dtack_to_err
);

// constants
parameter DTACK_TIMEOUT = 8'd200; // 200usec max. access time. USG's DTACK requires this much delay
parameter TIME_1USEC = 7'd125; // 8ns x 125 = 1us

// variables
reg		[6:0] divby125;
reg		[7:0] timer;

// DTACK Timer
always @ (posedge clk) begin
	if (~start) begin
		dtack_to_err <= 0;
		divby125 <= 1'b1; 
		timer <= 1'b1;
	end
	else if (start && ~dtack_to_err) begin
		if (divby125 == TIME_1USEC) begin
			if (timer == DTACK_TIMEOUT) begin  
				dtack_to_err <= 1;  // set timeout error
			end
			else begin
			   divby125 <= 1'b1;  	  // reset value
			   timer <= timer + 1'b1;  // 1us increments
			end
		end
		else begin
			divby125 <= divby125 + 1'b1;  // 8ns x 125 = 1us
	   end		 
	end
end

endmodule
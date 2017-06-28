// FILE: interrupt_control.v
// DATE: 10/27/2015
`timescale 1ns / 1ps

// interrupt control for board interrupts
module interrupt_control (
input		reset,
input 	clk, 
input		iack,
input		dtack_to_err,
input		[2:0] vec_addr,
output	reg iackout,
output	reg dtack,
output	[7:1] irq_n,
output	reg [7:0] vector  // board vector values from f8-ff 
);

// variables
reg		buserr_irq;
reg		buserr_irq_reset;
reg		iack1;

always @ (posedge clk or posedge reset) begin
	if (reset) 
		buserr_irq <= 0;
	else if (dtack_to_err) 
		buserr_irq <= 1;
	else if (buserr_irq_reset) 
		buserr_irq <= 0;
end

assign irq_n[7:1] = buserr_irq ? 7'b101_1111 : 7'b111_1111; // assign IRQ6 to vme buserr

// check for board interrupt
always @ (posedge clk or posedge reset) begin
	if (reset) begin
		iack1 <= 0;
		iackout <= 0;
		dtack <= 0;
		vector[7:0] <= 8'hff;  // spurious vector value
		buserr_irq_reset <= 0;
	end
	else if (iack) begin 
		if (~iack1) begin  // check if IACK matches any board interrupts
			iack1 <= 1;
			if (buserr_irq  && vec_addr == 3'h6) begin  // IRQ6
				dtack <= 1;
				vector[7:0] <= 8'hfe;  // assigned vector = FE for vme buserr
				buserr_irq_reset <= 1;
			end
			else begin  // interrupt is external to board
				iackout <= 1;
			end
		end
	end 
	else begin  
		iack1 <= 0;
		iackout <= 0;
		dtack <= 0;
		vector[7:0] <= 8'hff;  
		buserr_irq_reset <= 0;
	end
end 

endmodule
// FILE: interrupt_handler.v
// DATE: 10/26/2015
`timescale 1ns / 1ps

module interrupt_handler (
input		reset,
input 	clk, 
input		iack,
input		dtack,
input		[7:1] irq_n,
output	reg [2:0] vec_addr,
output	reg irq
);

// Interrupt Handler		
always @ (posedge clk or posedge reset) begin
	if (reset) begin
		irq <= 0;
		vec_addr <= 3'b000;
	end
	else if ((irq_n[7:1] != 7'h7f) && ~irq) begin
		irq <= 1;
		if (~irq_n[7]) 				// highest priority
			vec_addr <= 3'b111; 		
		else if (~irq_n[6]) 
			vec_addr <= 3'b110;
		else if (~irq_n[5]) 
			vec_addr <= 3'b101;
		else if (~irq_n[4])
			vec_addr <= 3'b100;
		else if (~irq_n[3])
			vec_addr <= 3'b011;
		else if (~irq_n[2])
			vec_addr <= 3'b010;
		else 								// lowest priority
			vec_addr <= 3'b001;		
	end
	else if (iack && dtack) begin // IACK cycle done
		irq <= 0;
	end		
end

endmodule
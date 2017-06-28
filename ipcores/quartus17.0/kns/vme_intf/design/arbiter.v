// FILE: arbiter.v
// DATE: 10/19/2015
`timescale 1ns / 1ps

module arbiter (
input		reset,
input 	clk, // 1MHz clock (1usec)
input		[3:0] vme_br_n,
input		vme_bbsy_n,
output	reg [3:0] vme_bgout_n,
output	reg vme_bclr_n
);

// constants
parameter BG_TIMEOUT = 5'd16; // 16usec max. to complete bus grant cycle

// variables 
reg		[4:0] timer;
reg		[1:0] round;
reg		[3:0] last_bgout_n;
reg		bg_inprogress;
reg		bg_pending_flg;
reg		bg_to_err;
wire		vme_bclr_reset;

// Round-Robin Arbiter
always @ (posedge clk or posedge reset) begin
	if (reset) begin
		vme_bgout_n <= 4'b1111;
		bg_inprogress <= 0;
		bg_pending_flg <= 0;
		round <= 2'b00;
	end
	else if ((vme_br_n[3:0] != 4'b1111) && vme_bbsy_n && ~bg_inprogress && ~bg_pending_flg) begin
		bg_pending_flg <= 1; // wait one more cycle to filter any glitches on br or bbsy
	end
	else if ((vme_br_n[3:0] != 4'b1111) && vme_bbsy_n && ~bg_inprogress && bg_pending_flg) begin
		if (~vme_br_n[0] && round == 2'b00) begin			
			vme_bgout_n <= 4'b1110; 
			bg_inprogress <= 1;
			bg_pending_flg <= 0; 
		end
		else if (~vme_br_n[1] && round == 2'b01) begin		
			vme_bgout_n <= 4'b1101; 
			bg_inprogress <= 1;
			bg_pending_flg <= 0; 
		end
		else if (~vme_br_n[2] && round == 2'b10) begin		
			vme_bgout_n <= 4'b1011; 
			bg_inprogress <= 1;
			bg_pending_flg <= 0; 
		end
		else if (~vme_br_n[3] && round == 2'b11) begin								
			vme_bgout_n <= 4'b0111; 
			bg_inprogress <= 1;
			bg_pending_flg <= 0; 
		end
		round <= round + 1'b1;
	end
	else if (bg_pending_flg) begin
		bg_pending_flg <= 0; // if you get here a glitch must have occurred
	end
	else if (~vme_bbsy_n && bg_inprogress) begin // bus request cycle done
		last_bgout_n <= vme_bgout_n;
		vme_bgout_n <= 4'b1111;
		bg_inprogress <= 0;
		bg_pending_flg <= 0;
	end	
	else if (vme_bbsy_n && bg_inprogress && bg_to_err) begin
		vme_bgout_n <= 4'b1111;  // if timeout error remove bus grant
		bg_inprogress <= 0;
		bg_pending_flg <= 0;
	end
end

assign vme_bclr_reset = vme_bbsy_n || reset;

// check for a different bus request while bus busy, if so issue bclr
always @ (posedge clk or posedge vme_bclr_reset) begin
	if (vme_bclr_reset) begin
		vme_bclr_n <= 1'b1;
	end
	else if ((vme_br_n[3:0] != 4'b1111) && ~vme_bbsy_n && ~bg_inprogress) begin
		if (~vme_br_n[0] && last_bgout_n[0]) begin			
			vme_bclr_n <= 1'b0; 
		end
		else if (~vme_br_n[1] && last_bgout_n[1]) begin		
			vme_bclr_n <= 1'b0; 
		end
		else if (~vme_br_n[2] && last_bgout_n[2]) begin		
			vme_bclr_n <= 1'b0; 
		end
		else if (~vme_br_n[3] && last_bgout_n[3]) begin								
			vme_bclr_n <= 1'b0; 
		end
	end
	else if (vme_bbsy_n) begin
		vme_bclr_n <= 1'b1; // put this here to make sure bclr is removed when bus not busy
	end
end	

// Bus Grant Timer
always @ (posedge clk) begin
	if (~bg_inprogress) begin
		bg_to_err <= 0;
		timer <= 1'b1;
	end
	else if (bg_inprogress && ~bg_to_err) begin
		if (timer == BG_TIMEOUT) begin  
			bg_to_err <= 1;  // set timeout error
		end
		else begin
			timer <= timer + 1'b1;  // 1us increments
		end
	end
end

endmodule
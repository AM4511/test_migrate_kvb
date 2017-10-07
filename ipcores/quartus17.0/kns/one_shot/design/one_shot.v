`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: Kulicke and Soffa Industries Inc
// Engineer: David Rauth
// 
// Create Date:    9/26/2017
// Design Name: 
// Module Name:    one_shot.v
// Project Name:   cpuskl_kvb
// Target Devices: EP4CGX30CF23C8
// Tool versions:  Quartus Version 17.0
// Description:    Avalon-MM one-shot timer
//
// Dependencies: 
//
// Revision: 
//    1.0 - File Created
////////////////////////////////////////////////////////////////////////////////

module one_shot #(
    parameter WIDTH = 32,
    parameter MAX_PULSE = 32,
    parameter [(WIDTH-1):0] INVERT_DEFAULT = 0,
    parameter [(WIDTH-1):0] ENABLE_DEFAULT = 0,
    parameter [(MAX_PULSE-1):0] TIME_DEFAULT = 100
)(
	input                    clk,
	input                    reset,
	input                    s_write,
	input                    s_read,
	input      [1:0]         s_address,
	input      [31:0]        s_writedata,
	output reg [31:0]        s_readdata,
    output reg [(WIDTH-1):0] pulse_out
);

localparam TRIGGER_ADDR = 2'h0;
localparam ENABLE_ADDR = 2'h1;
localparam INVERT_ADDR = 2'h2;
localparam TIME_ADDR = 2'h3;

reg [(WIDTH-1):0] overflow;
reg [(WIDTH-1):0] invert;
reg [(WIDTH-1):0] enable;
reg [(MAX_PULSE-1):0] timeval;
reg [(MAX_PULSE-1):0] count [0:(WIDTH-1)];

integer n;
always @ (posedge clk or posedge reset) begin
    if (reset) begin
        overflow <= {WIDTH{1'b0}};
        invert <= INVERT_DEFAULT;
        enable <= ENABLE_DEFAULT;
        timeval <= TIME_DEFAULT;
        pulse_out <= INVERT_DEFAULT;
    end
    else begin
        if (s_write) begin
            case (s_address)
                TRIGGER_ADDR: begin
                    for (n = 0; n < WIDTH; n = n + 1) begin
                        if (s_writedata[n] && enable[n]) begin
                            if (count[n] == 0) begin
                                count[n] <= timeval;
                            end
                            else begin
                                overflow[n] <= 1'b1;
                            end
                        end
                    end
                end
                ENABLE_ADDR:    enable <= s_writedata[(WIDTH-1):0];
                INVERT_ADDR:    invert <= s_writedata[(WIDTH-1):0];
                TIME_ADDR:      timeval <= s_writedata[(MAX_PULSE-1):0];
                default:;
            endcase
        end
        if (s_read) begin
            case (s_address)
                TRIGGER_ADDR:   s_readdata <= {{32-WIDTH{1'b0}}, overflow};
                ENABLE_ADDR:    s_readdata <= {{32-WIDTH{1'b0}}, enable};
                INVERT_ADDR:    s_readdata <= {{32-WIDTH{1'b0}}, invert};
                TIME_ADDR:      s_readdata <= {{32-MAX_PULSE{1'b0}}, timeval};
                default:        s_readdata <= 0;
            endcase
        end
        for (n = 0; n < WIDTH; n = n + 1) begin
            if (count[n] > 0) begin
                count[n] <= count[n] - {{MAX_PULSE-1{1'b0}}, 1'b1};
                pulse_out[n] <= ~invert[n];
            end
            else begin
                pulse_out[n] <= invert[n];
            end
            if (enable[n] == 1'b0) begin
                overflow[n] <= 1'b0;
            end
        end
    end
end

endmodule

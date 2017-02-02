`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/17/2017 09:55:59 AM
// Design Name: 
// Module Name: debouncer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module debouncer(
    input clk,
    input din,
    output reg dout
);
    parameter COUNT_MAX = 2**16-1;
    parameter COUNT_WIDTH = 16;
    reg [COUNT_WIDTH-1:0] counter = 0;
    reg transitioning = 0;
    initial dout = 0;
    always@(posedge clk)
        if (transitioning == 1) // for (counter=0; counter<MAX; counter++)
            if (dout != din)
                if (counter >= COUNT_MAX) begin // end of delay
                    transitioning <= 0;
                    dout <= din;
                end else
                    counter <= counter + 1;
            else
                transitioning <= 0;
        else if (dout != din) begin
            transitioning = 1;
            counter <= 0;
        end
endmodule

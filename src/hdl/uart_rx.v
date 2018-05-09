`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2018 03:49:49 PM
// Design Name: 
// Module Name: uart_rx
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


module uart_rx #(
    parameter BAUD = 9600,
    parameter CLOCK_FREQ = 100000000
) (
    input wire clk,
    input wire rx,
    output wire flag,
    output wire [6:0] data
);
    localparam COUNT_MAX = CLOCK_FREQ / BAUD;
    reg [$clog2(COUNT_MAX)-1:0] count_d = 0;
    always@(posedge clk)
        if (count_d >= COUNT_MAX-1)
            count_d <= 'b0;
        else
            count_d <= count_d + 1;
    reg [1:0] _rx = 2'b11;
    always@(posedge clk)
        _rx <= {_rx[0], rx};
    reg [10:0] shift = 11'h7ff;
    always@(posedge clk)
        if (count_d >= COUNT_MAX-1) begin
            if (shift[0] == 1'b0)
                shift <= {_rx[1], {10{1'b1}}};
            else
                shift <= {_rx[1], shift[10:1]};
        end
    assign flag = (shift[0] == 1'b0 && count_d >= COUNT_MAX-1) ? 1'b1 : 1'b0;
    assign data = shift[7:1];
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/13/2017 12:19:16 PM
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


//`include "math.vh"
module uart_rx(
    input clk,
    output reg flag,
    output reg [7:0] data,
    input rx
);
    parameter   BAUD        = 9600,
                CLOCK       = 100000000;
    localparam  COUNT_MAX   = CLOCK / BAUD,
                COUNT_WIDTH = 32;
    reg state = 0;
    reg [COUNT_WIDTH-1:0] counter = 0;
    reg [8:0] shift = 9'h1ff;
    always@(posedge clk)
        if (counter == COUNT_MAX) begin
            counter <= 0;
            if (shift[0] == 0) begin
                shift <= {rx, 8'hff};
                data <= shift[8:1];
                flag <= 1;
            end else begin
                shift <= {rx, shift[8:1]};
                flag <= 0;
            end
        end else begin
            counter <= counter + 1;
            flag <= 0;
        end
            
endmodule

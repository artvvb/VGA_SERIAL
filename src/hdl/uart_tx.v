`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/13/2017 12:19:16 PM
// Design Name: 
// Module Name: uart_tx
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
module uart_tx(
    input wire clk,
    input wire [7:0] data,
    input wire start,
    output wire tx,
    output wire ready 
    );
    parameter   BAUD        = 9600,
                CLOCK       = 100000000;
    localparam  COUNT_MAX   = CLOCK / BAUD,
                COUNT_WIDTH = 32;
    reg [COUNT_WIDTH-1:0] cd_count=0;
    reg [3:0] count=0;
    reg running=0;
    reg [10:0] shift=11'h7ff;
    reg [7:0] buf_data = 0;
    always@(posedge clk) begin
        if (running == 1'b0) begin
            shift <= {2'b11, data, 1'b0};
            running <= start;
            cd_count <= 'b0;
            count <= 'b0;
        end else if (cd_count == COUNT_MAX) begin
            shift <= {1'b1, shift[10:1]};
            cd_count <= 'b0;
            if (count >= 4'd10) begin
                shift <= {2'b11, data, 1'b0};
                running <= start;
                cd_count <= 'b0;
                count <= 'b0;
            end
            else
                count <= count + 1'b1;
        end else
            cd_count <= cd_count + 1'b1;
    end
    assign tx = (running == 1'b1) ? shift[0] : 1'b1;
    assign ready = ((running == 1'b0 && start == 1'b0) || (cd_count == COUNT_MAX && count == 4'd10)) ? 1'b1 : 1'b0;
endmodule

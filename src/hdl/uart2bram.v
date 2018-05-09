`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/07/2018 09:51:54 AM
// Design Name: 
// Module Name: uart2bram
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


module uart2bram #(
    parameter SCREEN_ADDRESS_WIDTH = 13,
    parameter HORIZONTAL_SLOT_COUNT = 80,
    parameter VERTICAL_SLOT_COUNT = 60
) (
    input wire clk,
    input wire uart_flag,
    input wire [6:0] uart_data,
    output reg bram_wen,
    output reg [6:0] bram_data,
    output reg [SCREEN_ADDRESS_WIDTH-1:0] bram_addr = 0
);
    localparam TOTAL_SLOT_COUNT = HORIZONTAL_SLOT_COUNT * VERTICAL_SLOT_COUNT;
    reg [SCREEN_ADDRESS_WIDTH-1:0] n_bram_addr;
    reg [SCREEN_ADDRESS_WIDTH-1:0] start_of_line_addr = 0, line_number = 0;
    always@(posedge clk) begin
        line_number = bram_addr % HORIZONTAL_SLOT_COUNT;
        start_of_line_addr = bram_addr - line_number;
    end
    always@(uart_flag, uart_data, bram_addr)
        if (uart_flag == 1'b1) begin
            if (uart_data == 8'hA) begin // LINE FEED
                bram_wen = 1'b0;
                bram_data = 'b0;
                if (bram_addr + HORIZONTAL_SLOT_COUNT >= TOTAL_SLOT_COUNT)
                    n_bram_addr = bram_addr + HORIZONTAL_SLOT_COUNT - TOTAL_SLOT_COUNT;
                else
                    n_bram_addr = bram_addr + HORIZONTAL_SLOT_COUNT;
            end else if (uart_data == 8'hD) begin // CARRIAGE RETURN
                bram_wen = 1'b0;
                bram_data = 'b0;
                n_bram_addr = start_of_line_addr;
            end else begin
                bram_wen = 1'b1;
                bram_data = uart_data;
                if (bram_addr+1 >= TOTAL_SLOT_COUNT)
                    n_bram_addr = 'b0;
                else
                    n_bram_addr = bram_addr + 1;
            end
        end else begin
            bram_wen = 1'b0;
            bram_data = 'b0;
            n_bram_addr = bram_addr;
        end
    always@(posedge clk)
        bram_addr <= n_bram_addr;
endmodule

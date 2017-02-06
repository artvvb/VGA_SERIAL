`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2017 12:35:17 PM
// Design Name: 
// Module Name: top-ascii
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


module top_ascii(
    input clk,
    input btn,
    input [7:0] sw,
    output [15:0] led,
    output vs,
    output hs,
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b,
    input rx,
    input tx
);
    localparam Idle       = 0,
               Done       = 1,
               MoveCursor = 2;
    wire [12:0] ascii_address;
    reg  [1:0] state = Idle;
    reg        ascii_wr_en = 0;
    reg  [7:0] ascii_data;
    reg [15:0] l_ascii_data;
//    wire       dbtn;
    wire       rx_flag;
    wire [7:0] rx_data;
    
    reg  [12:0] cy=0, cx=0, dy=0, dx=0;
    reg bselect;
    
    localparam MAXX = 79, MAXY = 59;
    
    assign led = ascii_address;
    assign ascii_address = cy * (MAXX+1) + cx;
    
    always@(posedge clk)
        case(state)
        Idle: begin
            if (rx_flag == 1) begin
                state <= Done;
                ascii_data <= rx_data;
                l_ascii_data <= {l_ascii_data[7:0], ascii_data};
                if (rx_data >= 32 && l_ascii_data[7:0] != 8'h1b && ascii_data != 8'h1b)
                    ascii_wr_en <= 1;
            end
        end
        Done: begin
            ascii_wr_en <= 0;
            if (rx_flag == 0) begin
                state <= Idle;
                if (l_ascii_data[7:0] == 8'h1b || l_ascii_data[15:8] == 8'h1b) begin
                    if (ascii_data == 8'h41 && l_ascii_data == {8'h1b, 8'h5b})begin // up arrow
                        cy <= (cy == 0) ? MAXY : (cy - 1);
                    end else if (ascii_data == 8'h42 && l_ascii_data == {8'h1b, 8'h5b}) begin // down arrow
                        cy <= (cy == MAXY) ? 0 : (cy + 1);
                    end else if (ascii_data == 8'h43 && l_ascii_data == {8'h1b, 8'h5b}) begin // right arrow
                        cx <= (cx == MAXX) ? 0 : (cx + 1);
                    end else if (ascii_data == 8'h44 && l_ascii_data == {8'h1b, 8'h5b}) begin // left arrow
                        cx <= (cx == 0) ? MAXX : (cx - 1);
                    end
                end else if (ascii_data >= 32) begin
                    cx <= (cx == MAXX) ? 0 : (cx + 1);
                end else if (ascii_data == 13) begin
                    cx <= (cx/(MAXX+1))*(MAXX+1);
                end else if (ascii_data == 10) begin
                    cy <= (cy == MAXY) ? 0 : (cy + 1);
                end
            end
        end
        endcase
    
    vga_2buf mVGA (
        clk,
        ascii_address,
        ascii_data,
        ascii_wr_en,
        vs,
        hs,
        vga_r,
        vga_g,
        vga_b,
        ascii_address,
        0
    );
    
    uart_rx mRX (
        clk,
        rx_flag,
        rx_data,
        btn ? rx : tx
    );
//    uart_tx mTX (
//        clk,  
//        rx_data, 
//        rx_flag,
//        tx,   
//        1'bz
//    );
endmodule

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
//    input btn,
//    input [7:0] sw,
//    output [15:0] led,
    output vs,
    output hs,
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b,
//    input rx,
    input tx
);
    localparam  Idle        = 0,
                MoveCursor  = 1,
                EvalOp      = 2;
    reg         ascii_wr_en = 0;
    reg   [1:0] state       = Idle;
    reg  [12:0] cy          = 0,
                cx          = 0;
    wire        rx_flag;
    wire  [7:0] rx_data;
    wire [12:0] ascii_address;
    
    localparam MAXX = 79, MAXY = 59;
    
//    assign led = ascii_address;
    assign ascii_address = cy * (MAXX+1) + cx;
    
    reg [23:0] rx_shift;
    always@(posedge clk)
        case(state)
        Idle: begin
            if (rx_flag == 1) begin // ensured to be one clock cycle long pulse
                state <= EvalOp;
                rx_shift <= {rx_shift[15:0], rx_data}; // enter received data into the shift register
            end
        end
        EvalOp: begin
            state <= MoveCursor;
            if (rx_shift[7:0] < 32)            ascii_wr_en <= 0; // character is not typable
            else if (rx_shift[23:16] == 8'h1b) ascii_wr_en <= 0; // recent escape code
            else if (rx_shift[15:8]  == 8'h1b) ascii_wr_en <= 0; // recent escape code
            else                               ascii_wr_en <= 1; // enter the character into the vga bram
        end
        MoveCursor: begin
            ascii_wr_en <= 0; // ensure write enable is one clock cycle long
            state <= Idle;
            if (rx_shift[23:16] == 8'h1b || rx_shift[15:8] == 8'h1b) begin
                if      (rx_shift == {8'h1b, 8'h5b, 8'h41})     cy <= (cy == 0)    ? MAXY : (cy - 1); // up arrow
                else if (rx_shift == {8'h1b, 8'h5b, 8'h42})     cy <= (cy == MAXY) ? 0    : (cy + 1); // down arrow
                else if (rx_shift == {8'h1b, 8'h5b, 8'h43})     cx <= (cx == MAXX) ? 0    : (cx + 1); // right arrow
                else if (rx_shift == {8'h1b, 8'h5b, 8'h44})     cx <= (cx == 0)    ? MAXX : (cx - 1); // left arrow
            end else if (rx_shift[7:0] >= 32)   cx <= (cx == MAXX) ? 0 : (cx + 1); // any typable character
            else if     (rx_shift[7:0] == 13)   cx <= 0;                           // CR
            else if     (rx_shift[7:0] == 10)   cy <= (cy == MAXY) ? 0 : (cy + 1); // LF
        end
        default: state <= Idle;
        endcase
    
    vga_2buf mVGA ( clk, ascii_address, rx_shift[7:0], ascii_wr_en, vs, hs, vga_r, vga_g, vga_b, ascii_address, 0 );
    uart_rx  mRX  ( clk, rx_flag, rx_data, tx );
    
endmodule

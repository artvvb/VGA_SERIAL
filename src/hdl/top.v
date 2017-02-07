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
    output [15:0] led,
    output vs,
    output hs,
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b,
//    input rx,
    input tx
);
    localparam  Idle                                 = 0,
                MoveCursor                           = 1,
                Write                                = 2,
                UpdateLength                         = 3,
                STATE_BITS                           = 2,
                MAXX                                 = 79,
                MAXY                                 = 59,
                SHIFT_DEPTH                          = 3;
    reg         ascii_wr_en                          = 0;
    reg  [STATE_BITS-1:0]             state          = Idle;
    reg  [STATE_BITS*SHIFT_DEPTH-1:0] state_shifter  = {Idle, Idle, Idle};
    reg  [12:0] cy                                   = 0,
                cx                                   = 0;
    reg  [23:0] rx_shift                             = 0;
    wire        rx_flag;
    wire  [7:0] rx_data;
    wire [12:0] ascii_address;
    
    reg   [6:0] line_length [5:0];
    reg   [6:0] tlen;
    integer i;
    initial for (i=0; i<2**6; i=i+1) line_length[i] = 0;
    
    assign ascii_address = cy * (MAXX+1) + cx;
    assign led = line_length[cy];
     
    always@(posedge clk)
        case(state)
        Idle: begin
            if (rx_flag == 1) begin // ensured to be one clock cycle long pulse
                state <= Write;
                state_shifter <= {Idle[1:0], MoveCursor[1:0], UpdateLength[1:0]};
                rx_shift <= {rx_shift[15:0], rx_data}; // enter received data into the shift register
            end
        end
        Write: begin
            state         <= state_shifter[1:0];
            state_shifter <= (state_shifter >> 2);
            tlen = line_length[cy];
            if (rx_shift[7:0] < 32)            ascii_wr_en <= 0; // character is not typable
            else if (rx_shift[23:16] == 8'h1b) ascii_wr_en <= 0; // recent escape code
            else if (rx_shift[15:8]  == 8'h1b) ascii_wr_en <= 0; // recent escape code
            else                               ascii_wr_en <= 1; // enter the character into the vga bram
        end
        MoveCursor: begin
            ascii_wr_en   <= 0; // ensure write enable is one clock cycle long
            state         <= state_shifter[1:0];
            state_shifter <= (state_shifter >> 2);
            if (rx_shift[23:16] == 8'h1b || rx_shift[15:8] == 8'h1b) begin
                if      (rx_shift == {8'h1b, 8'h5b, 8'h41})     cy <= (cy == 0)    ? MAXY : (cy - 1); // up arrow
                else if (rx_shift == {8'h1b, 8'h5b, 8'h42})     cy <= (cy == MAXY) ? 0    : (cy + 1); // down arrow
                else if (rx_shift == {8'h1b, 8'h5b, 8'h43})     cx <= (cx == MAXX) ? 0    : (cx + 1); // right arrow
                else if (rx_shift == {8'h1b, 8'h5b, 8'h44})     cx <= (cx == 0)    ? MAXX : (cx - 1); // left arrow
            end else if (rx_shift[7:0] >= 32)   cx <= (cx == MAXX) ? 0 : (cx + 1); // any typable character
            else if     (rx_shift[7:0] == 13)   cx <= 0;                           // CR
            else if     (rx_shift[7:0] == 10)   cy <= (cy == MAXY) ? 0 : (cy + 1); // LF
        end
        UpdateLength: begin
            ascii_wr_en   <= 0; // ensure write enable is one clock cycle long
            state         <= state_shifter[1:0];
            state_shifter <= (state_shifter >> 2);
            if (ascii_wr_en == 0) line_length[cy] <= tlen;
            else                  line_length[cy] <= tlen + 1;
        end
        endcase
    
    vga_2buf mVGA ( clk, ascii_address, rx_shift[7:0], ascii_wr_en, vs, hs, vga_r, vga_g, vga_b, ascii_address, 0 );
    uart_rx  mRX  ( clk, rx_flag, rx_data, tx );
    
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/17/2017 02:54:53 PM
// Design Name: 
// Module Name: vga
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


module vga_2buf (
    input clk,

    input [12:0] ascii_address, // begin bram control ports
    input  [7:0] ascii_data,    
    input        ascii_wr_en,   //end bram ports
    
    output vs,              // begin vga output ports
    output hs,
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b,     // end vga ports

    input [12:0] cursor,        // cursor address
    input switch_buffers        // buffer select
    );
    reg [7:0] tdata;
    reg [7:0] mem  [2**14-1:0];
    reg [7:0] rdata;
    wire rbuf, wbuf;
    wire [12:0] raddr;
    wire eof;
    
    integer i;
    initial for (i=0; i<2**14; i=i+1)
        mem[i] = 0;
    
    assign wbuf = 0;//(buffer_select == 0) ? 1 : 0;
    assign rbuf = 0;//(buffer_select == 1) ? 1 : 0;
    
    vga_flsm VGA_CONTROL (
        clk,
        vga_r,
        vga_g,
        vga_b,
        vs,
        hs,
        cursor,
        raddr,
        rdata,
        eof
    );
    
    always@(posedge clk) begin
        if (ascii_wr_en == 1)
            mem[{wbuf, ascii_address}] <= ascii_data;
        rdata <= mem[{rbuf, raddr}];
    end
endmodule

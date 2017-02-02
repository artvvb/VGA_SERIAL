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


module vga_ascii (
    input clk,
//    input switch_buffers,
    input [12:0] ascii_address,
    input  [7:0] ascii_data,
    input        ascii_wr_en,
    output reg vs,
    output reg hs,
    output reg [3:0] vga_r,
    output reg [3:0] vga_g,
    output reg [3:0] vga_b,
    input [12:0] cursor
    );
    localparam  HTS = 800,
                VTS = 521,
                HTD = 640,
                VTD = 480,
                HTPW = 96,
                VTPW = 2,
                HTFP = 16,
                VTFP = 10,
                HTBP = 48,
                VTBP = 29;
    reg   [1:0] ccount=0;
    reg   [9:0] hcount=0;
    reg   [9:0] vcount=0;
    wire        disp_in_bounds;
//    reg  [13:0] pixel_raddr;
    wire  [9:0] px, py;
    //reg [11:0] pixel_rdata;
    
    reg [7:0] mem  [2**13-1:0];
    reg [7:0] clib [2**10-1:0];
    initial $readmemh("ascii_init.dat", mem);
    initial $readmemh("charLib.dat", clib);
    reg [7:0] tdata;
    always@(posedge clk) begin
        ccount <= ccount + 1;
        if (ccount == 0) begin
            if (disp_in_bounds == 1) begin
                tdata <= mem[(py/8)*80 + (px/8)];
            end
        end else if (ccount == 1) begin
            if (disp_in_bounds == 1) begin
                tdata <= clib[{tdata[6:0], px[2:0]}];
            end
        end else if (ccount == 2) begin
            vs <= (vcount < VTPW) ? 0 : 1;
            hs <= (hcount < HTPW) ? 0 : 1;
            if ((py/8)*80 + (px/8) == cursor) begin
                vga_r <= (disp_in_bounds == 1 && (tdata & (1 << py[2:0])) == 0) ? 4'hf : 0;
                vga_g <= (disp_in_bounds == 1 && (tdata & (1 << py[2:0])) == 0) ? 4'hf : 0;
                vga_b <= (disp_in_bounds == 1 && (tdata & (1 << py[2:0])) == 0) ? 4'hf : 0;
            end else begin
                vga_r <= (disp_in_bounds == 1 && (tdata & (1 << py[2:0])) != 0) ? 4'hf : 0;
                vga_g <= (disp_in_bounds == 1 && (tdata & (1 << py[2:0])) != 0) ? 4'hf : 0;
                vga_b <= (disp_in_bounds == 1 && (tdata & (1 << py[2:0])) != 0) ? 4'hf : 0;
            end
        end else if (ccount == 3) begin
            ccount <= 0;
            hcount <= hcount + 1;
            if (hcount >= HTS-1) begin
                hcount <= 0;
                vcount <= vcount + 1;
                if (vcount >= VTS-1)
                    vcount <= 0;
            end
        end
    end
    assign disp_in_bounds = (vcount >= VTFP + VTPW && vcount < VTFP + VTPW + VTD && hcount >= HTFP + HTPW && hcount < HTFP + HTPW + HTD) ? 1 : 0;
    assign px = (disp_in_bounds) ? (hcount - HTFP - HTPW) : 'bz;
    assign py = (disp_in_bounds) ? (vcount - VTFP - VTPW) : 'bz;
    
    always@(posedge clk) begin
        if (ascii_wr_en == 1)
            mem[ascii_address] <= ascii_data;
    end
endmodule

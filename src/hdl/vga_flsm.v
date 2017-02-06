`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/06/2017 11:52:41 AM
// Design Name: 
// Module Name: vga_flsm
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


module vga_flsm (
    input clk,
    output reg [3:0] vga_r,
    output reg [3:0] vga_g,
    output reg [3:0] vga_b,
    output reg vs,
    output reg hs,
    
    input  [12:0] cursor,
    output [12:0] raddr,
    input   [7:0] rdata,
    
    output eof
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
    
    reg [1:0] ccount=0;
    reg [9:0] hcount=0;
    reg [9:0] vcount=0;
    reg [7:0] tdata;
    reg [7:0] clib [2**10-1:0];
    
    wire       disp_in_bounds;
    wire [9:0] px, py;
    
    initial $readmemh("charLib.dat", clib);
    assign eof = (hcount == HTS && vcount == VTS);
    
    always@(posedge clk) begin
        ccount <= ccount + 1;
        if (ccount == 0) begin
            if (disp_in_bounds == 1) begin
                tdata <= rdata;
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
                if (vcount >= VTS-1) begin
                    vcount <= 0;
                end
            end
        end
    end
    assign disp_in_bounds = (vcount >= VTFP + VTPW && vcount < VTFP + VTPW + VTD && hcount >= HTFP + HTPW && hcount < HTFP + HTPW + HTD) ? 1 : 0;
    assign px = (disp_in_bounds) ? (hcount - HTFP - HTPW) : 'bz;
    assign py = (disp_in_bounds) ? (vcount - VTFP - VTPW) : 'bz;
    assign raddr = (py>>3)*80 + (px>>3);
endmodule

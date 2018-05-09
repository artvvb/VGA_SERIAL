`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2018 11:11:54 AM
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


module vga #(
    parameter COLOR_BITS = 1,
    parameter PIXEL_INTERFACE_LATENCY = 4,
    parameter PIXEL_DIM_WIDTH = 10
) (
    input wire clk,
    output wire n_px_valid,
    output wire [PIXEL_DIM_WIDTH-1:0] n_px_x,
    output wire [PIXEL_DIM_WIDTH-1:0] n_px_y,
    input wire [COLOR_BITS-1:0] n_px_color,
    output wire vga_vs,
    output wire vga_hs,
    output wire [3:0] vga_r,
    output wire [3:0] vga_g,
    output wire [3:0] vga_b,
    output wire eof_flag
    ,input wire [15:0] sw
);
//    //640x480@60Hz Params; f_clk = 25.175 MHz
//    localparam HTS=800, VTS=525, HTD=640, VTD=480, HTPW=96, VTPW=2, HTFP=16, VTFP=10, HTBP=48, VTBP=33, SYNC_POL=0;
    //1920x1080@60Hz Params; f_clk = 145.5 MHz
    localparam HTS=2200, VTS=1125, HTD=1920, VTD=1080, HTPW=44, VTPW=5, HTFP=88, VTFP=4, HTBP=148, VTBP=36, SYNC_POL=1;
    reg [PIXEL_DIM_WIDTH-1:0] count_x = 0;
    reg [PIXEL_DIM_WIDTH-1:0] count_y = 0;
    wire count_x_tc = (count_x >= HTS-1) ? 1'b1 : 1'b0;
    wire count_y_tc = (count_x_tc == 1'b1 && count_y >= VTS-1) ? 1'b1 : 1'b0;
    wire [PIXEL_DIM_WIDTH-1:0] n_count_x = (count_x_tc == 1'b1) ? ('b0) : (count_x + 1'b1);
    wire [PIXEL_DIM_WIDTH-1:0] n_count_y = (count_x_tc == 1'b1) ? ((count_y_tc == 1'b1) ? ('b0) : (count_y + 1'b1)) : (count_y);
    assign eof_flag = count_y_tc;
    assign n_px_x = n_count_x;// - sw[7:0];// - HTFP - HTPW;
    assign n_px_y = n_count_y;// - sw[15:8];// - VTFP - VTPW;
//    assign n_px_valid = (n_count_x >= HTFP + HTPW && n_count_y >= VTFP + VTPW && n_count_x < HTFP + HTPW + HTD && n_count_y < VTFP + VTPW + VTD) ? 1'b1 : 1'b0;
    assign n_px_valid = (n_count_x < HTD && n_count_y < VTD) ? 1'b1 : 1'b0;
    reg [COLOR_BITS-1:0] color = 0;
    wire [COLOR_BITS-1:0] n_color = (n_px_valid == 1'b1) ? n_px_color : 'b0;
    always@(posedge clk) begin
        count_x <= n_count_x;
        count_y <= n_count_y;
        color <= n_color;
    end
    wire hs, vs;
//    assign hs = (n_count_x >= HTPW) ? 1'b1 : 1'b0;
//    assign vs = (n_count_y >= VTPW) ? 1'b1 : 1'b0;
    assign hs = (n_count_x >= HTD + HTBP && n_count_x < HTD + HTBP + HTPW) ? 1'b1 : 1'b0;
    assign vs = (n_count_y >= VTD + VTBP && n_count_y < VTD + VTBP + VTPW) ? 1'b1 : 1'b0;
    assign {vga_r, vga_g, vga_b} = {12/COLOR_BITS{color}};
    reg [PIXEL_INTERFACE_LATENCY-1:0] hs_buf = 'b0;
    reg [PIXEL_INTERFACE_LATENCY-1:0] vs_buf = 'b0;
    always@(posedge clk) hs_buf[0] <= hs;
    always@(posedge clk) vs_buf[0] <= vs;
    genvar i;
    generate for (i=1; i<PIXEL_INTERFACE_LATENCY; i=i+1) begin : PIXEL_BUFFER_STAGE_i
        always@(posedge clk) hs_buf[i] <= hs_buf[i-1];
        always@(posedge clk) vs_buf[i] <= vs_buf[i-1];
    end endgenerate
    assign vga_hs = SYNC_POL ^ hs_buf[PIXEL_INTERFACE_LATENCY-1];
    assign vga_vs = SYNC_POL ^ vs_buf[PIXEL_INTERFACE_LATENCY-1];
endmodule

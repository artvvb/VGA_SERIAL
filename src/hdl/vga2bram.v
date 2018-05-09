`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2018 11:44:01 AM
// Design Name: 
// Module Name: vga2bram
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


module vga2bram #(
    parameter COLOR_BITS = 1,
    parameter HORIZONTAL_SLOT_COUNT = 80,
    parameter VERTICAL_SLOT_COUNT = 60,
    parameter PIXEL_DIM_WIDTH = 10,
    parameter SCREEN_ADDRESS_WIDTH = 13
) (
    input  wire clk,
    
    // PIXEL LOOKUP INTERFACE
    input  wire px_valid,
    input  wire [PIXEL_DIM_WIDTH-1:0] px_x,
    input  wire [PIXEL_DIM_WIDTH-1:0] px_y,
    output wire [COLOR_BITS-1:0] px_color,
    
    // SCREEN BRAM READ-ONLY INTERFACE
    output wire [SCREEN_ADDRESS_WIDTH-1:0] screen_addr,
    input  wire [6:0] screen_data,
    output wire screen_ren,
    // TEXTURE BRAM READ-ONLY INTERFACE
    output wire [9:0] tex_addr,
    input  wire [7:0] tex_data,
    output wire tex_ren
);
    wire px_valid_0;
    wire [PIXEL_DIM_WIDTH-1:0] px_x_0;
    wire [PIXEL_DIM_WIDTH-1:0] px_y_0;
    wire [COLOR_BITS-1:0] px_color_0;
    wire screen_addr_0;
    wire [6:0] screen_data_1;
    wire [6:0] tex_addr_1;
    wire [6:0] tex_data_2;
    reg [6:0] tex_ren_1;
    reg [2:0] tex_chr_x_idx_1;
    reg [2:0] tex_chr_y_idx_1;
    reg [2:0] tex_chr_y_idx_2;
    wire screen_ren_0;
    
    assign screen_ren = screen_ren_0;
    assign screen_addr = screen_addr_0;
    assign tex_ren = tex_ren_1;
    assign tex_addr = tex_addr_1;
    
    assign px_color_0 = px_color;
    assign tex_data_2 = tex_data;
    assign screen_data_1 = screen_data;
    assign px_x_0 = px_x;
    assign px_y_0 = px_y;
    assign px_valid_0 = px_valid;
    
    assign screen_ren_0 = px_valid_0;
    assign screen_addr_0 = (px_y_0[PIXEL_DIM_WIDTH-1:3]*HORIZONTAL_SLOT_COUNT) + px_x_0[PIXEL_DIM_WIDTH-1:3];
    always@(posedge clk) tex_chr_x_idx_1 <= px_x_0[2:0];
    always@(posedge clk) tex_chr_y_idx_1 <= px_y_0[2:0];
    always@(posedge clk) tex_ren_1 <= screen_ren_0;
    always@(posedge clk) tex_chr_y_idx_2 <= tex_chr_y_idx_1;
    assign tex_addr = {screen_data_1[6:0], tex_chr_x_idx_1};
    assign px_color = tex_data_2[tex_chr_y_idx_2];
endmodule

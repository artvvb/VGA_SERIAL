`timescale 1ns / 1ps
`default_nettype none

module top(
    input wire clk,
    
    output wire [3:0] vga_r,
    output wire [3:0] vga_g,
    output wire [3:0] vga_b,
    output wire vga_hs,
    output wire vga_vs,
    
    input wire rx,
    output wire tx
);
    localparam RES = "1920x1080"; // else 640x480
    localparam SCREEN_ADDRESS_WIDTH = (RES == "1920x1080") ? 15 : 13;
    localparam HORIZONTAL_SLOT_COUNT = (RES == "1920x1080") ? 240 : 80;
    localparam VERTICAL_SLOT_COUNT = (RES == "1920x1080") ? 135 : 60;
    localparam PIXEL_DIM_WIDTH = (RES == "1920x1080") ? 12 : 10;
    localparam CLOCK_FREQUENCY = (RES == "1920x1080") ? 148500000 : 25173000;
    wire pixel_clk;
    wire [PIXEL_DIM_WIDTH-1:0] px_y, px_x;
    wire px_valid, px_color;
    wire [6:0] uart_data;
    wire uart_flag;
    wire [SCREEN_ADDRESS_WIDTH-1:0] screen_addr_a;
    wire [6:0] screen_data_a;
    wire screen_wen_a;
    wire [SCREEN_ADDRESS_WIDTH-1:0] screen_addr_b;
    wire [6:0] screen_data_b;
    wire screen_ren_b;
    wire [9:0] tex_addr_b;
    wire [7:0] tex_data_b;
    wire tex_ren_b;
    
    clk_wiz_0 m_clk_wiz (
        .clk_in1(clk),
        .clk_out1(pixel_clk)
    );
        
    uart_rx #(
        .BAUD(9600),
        .CLOCK_FREQ(CLOCK_FREQUENCY)
    ) m_uart_rx (
        .clk(pixel_clk),
        .rx(rx),
        .flag(uart_flag),
        .data(uart_data)
    );
    uart2bram #(
        .SCREEN_ADDRESS_WIDTH(SCREEN_ADDRESS_WIDTH),
        .HORIZONTAL_SLOT_COUNT(HORIZONTAL_SLOT_COUNT),
        .VERTICAL_SLOT_COUNT(VERTICAL_SLOT_COUNT)
    ) m_uart2bram (
        .clk(pixel_clk),
        .uart_flag(uart_flag),
        .uart_data(uart_data),
        .bram_wen(screen_wen_a),
        .bram_addr(screen_addr_a),
        .bram_data(screen_data_a)
    );
    block_ram #(
        .DATA_WIDTH(7),
        .ADDR_WIDTH(SCREEN_ADDRESS_WIDTH),
        .INIT_FROM_FILE(1),
        .INIT_FILE_IS_HEX(1),
        .INIT_FILENAME("ascii_init.dat")
    ) m_screen_bram (
        .clk(pixel_clk),
        .wen_a(screen_wen_a),
        .addr_a(screen_addr_a),
        .din_a(screen_data_a),
        .ren_b(screen_ren_b),
        .addr_b(screen_addr_b),
        .dout_b(screen_data_b)
    );
    block_ram #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(10),
        .INIT_FROM_FILE(1),
        .INIT_FILE_IS_HEX(1),
        .INIT_FILENAME("charLib.dat")
    ) m_tex_rom (
        .clk(pixel_clk),
        .wen_a(1'b0),
        .addr_a(0),
        .din_a(0),
        .ren_b(tex_ren_b),
        .addr_b(tex_addr_b),
        .dout_b(tex_data_b)
    );
    vga2bram #(
        .COLOR_BITS(1),
        .HORIZONTAL_SLOT_COUNT(HORIZONTAL_SLOT_COUNT),
        .VERTICAL_SLOT_COUNT(VERTICAL_SLOT_COUNT),
        .PIXEL_DIM_WIDTH(PIXEL_DIM_WIDTH),
        .SCREEN_ADDRESS_WIDTH(SCREEN_ADDRESS_WIDTH)
    ) m_vga2bram (
        .clk(pixel_clk),
        .px_valid(px_valid),
        .px_x(px_x),
        .px_y(px_y),
        .px_color(px_color),
        .screen_addr(screen_addr_b),
        .screen_data(screen_data_b),
        .screen_ren(screen_ren_b),
        .tex_addr(tex_addr_b),
        .tex_data(tex_data_b),
        .tex_ren(tex_ren_b)
    ); 
    vga #(
        .COLOR_BITS(1),
        .PIXEL_DIM_WIDTH(PIXEL_DIM_WIDTH),
        .PIXEL_INTERFACE_LATENCY(2)
    ) m_vga (
        .clk(pixel_clk),
        .n_px_valid(px_valid),
        .n_px_x(px_x),
        .n_px_y(px_y),
        .n_px_color(px_color),
        .vga_vs(vga_vs),
        .vga_hs(vga_hs),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b),
        .eof_flag()
    );
    wire tx_ready;
    uart_tx #(
        .BAUD(9600),
        .CLOCK(CLOCK_FREQUENCY)
    ) m_uart_tx (
        .clk(pixel_clk),
        .data({1'b0, uart_data}),
        .start(uart_flag),
        .tx(tx),
        .ready(tx_ready)
    );
endmodule

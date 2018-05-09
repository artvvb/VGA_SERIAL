`timescale 1ns / 1ps

module block_ram #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 8,
    parameter INIT_FROM_FILE = 0,
    parameter INIT_FILE_IS_HEX = 0,
    parameter INIT_FILENAME = ""
) (
    input wire clk,
    input wire wen_a,
    input wire [ADDR_WIDTH-1:0] addr_a,
    input wire [DATA_WIDTH-1:0] din_a,
    input wire ren_b,
    input wire [ADDR_WIDTH-1:0] addr_b,
    output reg [DATA_WIDTH-1:0] dout_b
);
    reg [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH-1:0];
    initial if (INIT_FROM_FILE != 0) begin
        if (INIT_FILE_IS_HEX != 0)
            $readmemh(INIT_FILENAME, mem);
        else
            $readmemb(INIT_FILENAME, mem);
    end
    always@(posedge clk) begin
        if (ren_b == 1'b1)
           dout_b = mem[addr_b];
        if (wen_a == 1'b1)
            mem[addr_a] = din_a;
    end
    
endmodule

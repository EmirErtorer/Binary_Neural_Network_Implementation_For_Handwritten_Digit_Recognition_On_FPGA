`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2025 09:49:18 AM
// Design Name: 
// Module Name: model_rom
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


// LAYER 1: 128 neurons, each with 784 input weights
// ------------------------------------------------
module dense_kernel_rom_dualport(input clk, input wire [6:0] addr_a, input wire [6:0] addr_b, output reg [783:0] data_a, output reg [783:0] data_b);
    // Dual port BRAMs for storing layer 1 trained weights
    reg [783:0] rom [0:127];
    initial $readmemb("dense_kernel_transposed.mem", rom);
    always @(posedge clk) begin
        data_a <= rom[addr_a];
        data_b <= rom[addr_b];
    end
endmodule

module dense_kernel_thresholds_rom_lut(input wire [6:0] addr, output reg signed [10:0] data);
     // Single port LUT ROM for storing layer 1 thresholds
    (* rom_style = "distributed" *) reg signed [10:0] rom [0:127]; // to force LUT usage
    initial $readmemb("dense_kernel_thresholds.mem", rom);  
    always @(*) begin
        data = rom[addr];
    end
endmodule


// LAYER 2: 64 neurons, each with 128 input weights
// ------------------------------------------------
module dense_1_kernel_rom_dualport(input clk, input wire [5:0] addr_a, input wire [5:0] addr_b, output reg [127:0] data_a, output reg [127:0] data_b);
     // Dual port BRAMs for storing layer 2 trained weights
    reg [127:0] rom [0:63];
    initial $readmemb("dense_1_kernel_transposed.mem", rom);
    always @(posedge clk) begin
        data_a <= rom[addr_a];
        data_b <= rom[addr_b];
    end
endmodule

module dense_1_kernel_thresholds_rom_lut(input wire [5:0] addr, output reg signed [10:0] data);
    // Single port LUT ROM for storing layer 2 thresholds
    (* rom_style = "distributed" *) reg signed [10:0] rom [0:63]; // to force LUT RAM
    initial $readmemb("dense_1_kernel_thresholds.mem", rom);
    always @(*) begin
        data = rom[addr];
    end
endmodule


// LAYER 3: 10 neurons, each with 64 input weights
// ------------------------------------------------
module dense_2_kernel_rom_dualport(input clk, input wire [3:0] addr_a, input wire [3:0] addr_b, output reg [63:0] data_a, output reg [63:0] data_b);
     // Dual port BRAMs for storing output layer trained weights
    reg [63:0] rom [0:9];
    initial $readmemb("dense_2_kernel_transposed.mem", rom);
    always @(posedge clk) begin
        data_a <= rom[addr_a];
        data_b <= rom[addr_b];
    end
endmodule
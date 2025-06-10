`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2025 10:25:13 PM
// Design Name: 
// Module Name: dense_2_kernel_thresholds_rom_tb
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


module dense_2_kernel_thresholds_rom_tb;

    reg [3:0] addr = 0; // Address for 10 rows = 4 bits
    wire signed [4:0] data; // Each threshold is signed 5-bit

    dense_2_kernel_thresholds_rom uut(.addr(addr), .data(data));

    initial begin
        $display("Testing dense_2_kernel_thresholds_rom:");
        for (addr = 0; addr < 10; addr = addr + 1)
        begin
            #10; // wait 10 ns for each read
            $display("addr = %0d => threshold = %0d", addr, data);
        end
        $finish;
    end 

endmodule


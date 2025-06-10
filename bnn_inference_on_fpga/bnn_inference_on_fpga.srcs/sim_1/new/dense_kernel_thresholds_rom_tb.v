`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2025 07:56:42 PM
// Design Name: 
// Module Name: dense_kernel_thresholds_rom_tb
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


module dense_kernel_thresholds_rom_tb;

    reg [6:0] addr = 0; // Address for 128 rows = 7 bits
    wire signed [4:0] data; // Each row is 4 bits

    dense_kernel_thresholds_rom uut(.addr(addr), .data(data));
    
    initial begin
        $display("Testing dense_kernel_thresholds_rom:");
        for (addr = 0; addr < 128; addr = addr + 1)
        begin
            #10; // wait 10 ns for each read
            $display("addr = %d => threshold = %0d", addr, data);
        end
        $finish;
    end 

endmodule

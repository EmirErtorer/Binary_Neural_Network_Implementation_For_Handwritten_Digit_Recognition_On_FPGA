`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 0/27/2025 11:59:38 PM
// Design Name: 
// Module Name: dense_1_kernel_thresholds_rom_tb
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


module dense_1_kernel_thresholds_rom_tb;

    reg [5:0] addr = 0; // Address for 64 rows = 6 bits
    wire signed [4:0] data; // Each threshold is signed 5-bit

    // Instantiate the module under test
    dense_1_kernel_thresholds_rom uut(.addr(addr), .data(data));

    initial begin
        $display("Testing dense_1_kernel_thresholds_rom:");
        for (addr = 0; addr < 64; addr = addr + 1)
        begin
            #10; // wait 10 ns for each read
            $display("addr = %d => threshold = %0d", addr, data);
        end
        $finish;
    end 

endmodule

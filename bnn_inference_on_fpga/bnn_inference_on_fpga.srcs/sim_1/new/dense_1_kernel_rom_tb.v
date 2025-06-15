`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2025 10:27:59 PM
// Design Name: 
// Module Name: dense_1_kernel_rom_tb
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


module dense_1_kernel_rom_tb;

    reg [6:0] addr = 0; // Address for 128 rows = 7 bits
    wire [63:0] data;   // Each row is 64 bits

    // Instantiate the module under test
    dense_1_kernel_rom uut (.addr(addr), .data(data));

    initial begin
        $display("Testing dense_1_kernel_rom:");
        for (addr = 0; addr < 128; addr = addr + 1)
        begin
            #10; // wait 10 ns for each read
            $display("addr = %0d => data = %b", addr, data);
        end
        $finish;
    end

endmodule


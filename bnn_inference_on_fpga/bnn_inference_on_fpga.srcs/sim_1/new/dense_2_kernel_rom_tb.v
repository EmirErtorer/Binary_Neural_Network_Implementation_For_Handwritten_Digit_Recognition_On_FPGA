`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2025 10:28:19 PM
// Design Name: 
// Module Name: dense_2_kernel_rom_tb
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


module dense_2_kernel_rom_tb;

    reg [5:0] addr = 0; // Address for 64 rows = 6 bits
    wire [9:0] data;    // Each row is 10 bits

    // Instantiate the module under test
    dense_2_kernel_rom uut (.addr(addr), .data(data));

    initial begin
        $display("Testing dense_2_kernel_rom:");
        for (addr = 0; addr < 64; addr = addr + 1)
        begin
            #10; // wait 10 ns for each read
            $display("addr = %0d => data = %b", addr, data);
        end
        $finish;
    end

endmodule

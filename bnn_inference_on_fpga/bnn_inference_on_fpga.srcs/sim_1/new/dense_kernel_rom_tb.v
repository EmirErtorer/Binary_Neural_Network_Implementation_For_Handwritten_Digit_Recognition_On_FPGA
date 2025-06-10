`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2025 04:06:12 PM
// Design Name: 
// Module Name: dense_kernel_rom_tb
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

// Testbench to test the dense_kernel ROM

module dense_kernel_rom_tb;

  reg [9:0] addr = 0; // Address for 784 rows = 10 bits
  wire [127:0] data; // Each row is 128 bits

  // Instantiate the module under test
  dense_kernel_rom uut (.addr(addr), .data(data));

    initial begin
        $display("Testing dense_kernel_rom:");
        for (addr = 0; addr < 784; addr = addr + 1)
        begin
            #10; // wait 10 ns for each read
            $display("addr = %d => data = %b", addr, data);
        end
        $finish;
    end 

endmodule

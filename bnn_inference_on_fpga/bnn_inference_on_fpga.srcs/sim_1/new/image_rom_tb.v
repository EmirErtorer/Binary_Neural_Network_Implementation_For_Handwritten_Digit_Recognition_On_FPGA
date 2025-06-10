`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2025 05:12:58 PM
// Design Name: 
// Module Name: image_rom_tb
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


module image_rom_tb;

    wire [783:0] image_data;

    // instantiate the image_rom module
    image_rom uut (.image_data(image_data));
    integer i;

    initial begin
        #10; 

        $display("Testing image_rom output:");
        for (i = 0; i < 784; i = i + 1) begin
            $display("Pixel[%0d] = %b", i, image_data[i]);
        end

        $finish;
    end

endmodule

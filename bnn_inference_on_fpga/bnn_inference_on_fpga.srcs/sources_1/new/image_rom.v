`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2025 09:38:40 AM
// Design Name: 
// Module Name: image_rom
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

// ROM for storing the test image
module image_rom(output reg [783:0] image_data);
    reg [0:0] rom_data [0:783];
    integer i;

    initial begin
        $readmemb("d1_img_11.mem", rom_data);

        for (i = 0; i < 784; i = i + 1)
            image_data[i] = rom_data[i];
    end
endmodule


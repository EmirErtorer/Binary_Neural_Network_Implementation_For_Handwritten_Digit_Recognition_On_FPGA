`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2025 09:37:03 AM
// Design Name: 
// Module Name: bnn_top
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

// Top level module
module bnn_top (input clk, input reset, output wire [3:0] digit, output wire [6:0] segment, output wire done);

    wire [783:0] image_data;
    
    image_rom image (.image_data(image_data)); // intialize the image
    bnn_inference inference(.clk(clk), .reset(reset), .image(image_data), .digit(digit), .done(done)); // provide input to bnn_inference
    
    seven_segment_decoder digit_display(.bcd(digit), .segment(segment)); // provide predicted digit to seven_segment_decoder
    
endmodule

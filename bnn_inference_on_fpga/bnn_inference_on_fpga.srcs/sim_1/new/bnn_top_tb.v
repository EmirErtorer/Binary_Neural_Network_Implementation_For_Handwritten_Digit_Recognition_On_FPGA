`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2025 04:27:30 PM
// Design Name: 
// Module Name: bnn_top_tb
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

module bnn_top_tb;

    // Inputs
    reg clk;
    reg reset;

    // Outputs
    wire [3:0] digit;
    wire [6:0] segment;
    wire done;

    // instantiating the Unit Under Test
    bnn_top uut (.clk(clk), .reset(reset), .digit(digit), .segment(segment), .done(done));

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    initial begin
        // Initializing Inputs
        clk = 0;
        reset = 1;

        // Wait for global reset
        #20;
        reset = 0;    
    end

endmodule



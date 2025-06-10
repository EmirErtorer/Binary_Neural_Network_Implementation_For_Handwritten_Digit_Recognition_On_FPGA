`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2025 01:39:32 PM
// Design Name: 
// Module Name: seven_segment_decoder
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

module seven_segment_decoder(input [3:0] bcd, output reg[6:0] segment);
    always @(*)begin
        case (bcd)
          4'b0000: segment = 7'b0000001;
          4'b0001: segment = 7'b1001111;
          4'b0010: segment = 7'b0010010;
          4'b0011: segment = 7'b0000110;
          4'b0100: segment = 7'b1001100;
          4'b0101: segment = 7'b0100100;
          4'b0110: segment = 7'b0100000;
          4'b0111: segment = 7'b0001111;
          4'b1000: segment = 7'b0000000;
          4'b1001: segment = 7'b0000100;
          default: segment = 7'bxxxxxxx;
        endcase
      end
endmodule

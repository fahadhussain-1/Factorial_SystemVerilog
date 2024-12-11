`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2024 11:04:28 PM
// Design Name: 
// Module Name: register2
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


module register2(
    input clk,
    input rst,
    input logic [31:0] d_in,
    output logic [31:0] d_out
    );
    
    reg [31:0] x2;
     always@ (posedge clk) begin
        x2 <= d_in - 32'b1 ;
        end 
     assign d_out = x2;
endmodule

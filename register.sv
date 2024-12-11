`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2024 02:37:51 PM
// Design Name: 
// Module Name: register
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


module register(
    input clk,
    input rst,
    input logic [31:0] d_in,
    output logic [31:0] d_out
    );
    
    reg [31:0] x0;
     always@ (posedge clk) begin
        x0 <= d_in;
        end
        
        assign d_out=x0;
endmodule

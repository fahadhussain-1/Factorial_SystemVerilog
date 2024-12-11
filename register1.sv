`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2024 11:29:34 PM
// Design Name: 
// Module Name: register1
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


module register1(
    input clk,
    input rst,
    output logic [31:0] d_out
    );
    
    reg [31:0] x1;
        always@ (posedge clk) begin
        x1 <= 32'b1;
        end
        
        assign d_out = x1;
        
endmodule

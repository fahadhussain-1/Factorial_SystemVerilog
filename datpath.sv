`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2024 02:38:28 PM
// Design Name: 
// Module Name: datpath
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


module datpath(
    input clk,
    input rst,
    input logic [31:0] in,
    //input logic [31:0] one,
    input en,
    output result
    );
    
    //register wires 
    wire [31:0] x0,x1,x2;
    
    //registers instantiation
    register r0(clk, rst, in, x0);
    register1 r1(clk, rst, one, x1);
    
    // 3rd register instantiation
    register2 r2(clk, rst, x2);    
    
    //wires of multiplier
    wire [31:0] mul_a, mul_b;
    wire [31:0] mul_out;
    
    //multiplier instantiation
    multiplier mul( mul_a, mul_b, mul_out);
    
    
    
    //wire of subtractor
    wire [31:0] sub_a, sub_b;
    wire [31:0] sub_out;
    
    //subtractor instantiation
    subtractor sub( sub_a, sub_b, sub_out);
    
    //comparator instantiation
    comparator comp(
endmodule

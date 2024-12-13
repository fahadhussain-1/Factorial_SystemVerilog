`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Fahad Hussain <chipengineer.fahad@gmail.com>
// 
// Create Date: 12/09/2024 11:49:12 AM
// Design Name: 
// Module Name: datapath
// Project Name: Factorial
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
module datapath (
    input clk,
    input rst,
    //input reg [31:0] num,
   // input en,
    input logic [1:0] a_sel,
    input logic [1:0] b_sel,
    input w_sel,
    input w_en,
    input op_sel,
    output z,
    output logic [31:0] Result
);
wire [31:0] alu_out;

//registers
reg [31:0] x0,x1,x2;
always@(posedge clk or posedge rst) begin
    if (rst) begin
        x0 <= 1;
        x1 <= 100;
        x2 <= 1;
             end
     else if (w_sel==0 && w_en)
        x0 <= alu_out;
     
     else if (w_sel==1 &&  w_en)
        x1 <= alu_out;
     
     else begin 
        x0 <= x0;
        x1 <= x1;
        x2 <= x2;
        end
end 

wire [31:0] asel_out, bsel_out;
//register reading
assign asel_out = (a_sel ==2'b00) ? x0:
                  (a_sel ==2'b01) ? x1:
                  (a_sel ==2'b10) ? x2:
                  32'bx;

assign bsel_out = (b_sel ==2'b00) ? x0:
                  (b_sel ==2'b01) ? x1:
                  (b_sel ==2'b10) ? x2:
                  32'bx;


//ALU
assign alu_out = (op_sel)? asel_out - bsel_out : asel_out * bsel_out ;

//comparison
 
 assign z = ( x2 == x1);
  
  assign  Result = x0;
endmodule
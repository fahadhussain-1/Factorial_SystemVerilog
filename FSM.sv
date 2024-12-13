`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2024 11:49:12 AM
// Design Name: 
// Module Name: FSM
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


module FSM(
   input clk,
   input rst,
   input z,
   output logic [1:0] a_sel,
   output logic [1:0] b_sel,
   output op_sel,
   output w_sel,
   output w_en
   //output en;
    );
    
    reg [1:0] state,nstate;
    
    parameter loop_mul=2'b00;
    parameter loop_sub=2'b01;
    parameter loop_beq=2'b10;
    parameter     done=2'b11;
    
    //present state logic
    always@ (posedge clk or posedge rst)
    begin
        if(rst)
            state <= loop_mul;
        else
            state <= nstate;
     end
     
     //nest state logic
     
     always@(*) begin
     case(state)
        loop_mul: nstate <= loop_sub;
        loop_sub: nstate <= loop_beq;
        loop_beq: if(z)
                    nstate <= done;
                  else
                    nstate <= loop_mul;
      endcase
     end 
 //output combinational logic
 assign {a_sel, b_sel, op_sel, w_sel, w_en} = (state == loop_mul) ? {2'b00, 2'b01,1'b0, 1'b0, 1'b1}:
                                              (state == loop_sub) ? {2'b01, 2'b10,1'b1, 1'b1, 1'b1}:
                                              (state == loop_beq) ? {2'b01, 2'b10,1'bx, 1'bx, 1'b0}:
                                              (state ==     done) ? {2'b01, 2'b10,1'bx, 1'bx, 1'b0}:
                                              {2'bx,2'bx,1'bx,1'bx,1'b0};
     
     
     
endmodule

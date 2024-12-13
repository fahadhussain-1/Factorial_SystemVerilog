`timescale 1ns / 1ps

module top(
    input reg clk,
    input reg rst,
    //input reg [31:0] num,
    //input reg en,
    output logic [31:0] Result
    );
    
    assign #10 clk =~clk;
    
    //wires
    wire [1:0] a_sel, b_sel;
    wire z, w_en, w_sel, op_sel;
    //wire [31:0] Result;
    
    
    // datapath instantiation
    datapath dp(
                clk,
                rst,
                //num,
                //en,
                a_sel,
                b_sel,
                w_sel,
                w_en,
                op_sel,
                z,
                Result
                );
                
    FSM control(
                clk,
                rst,
                z,
                a_sel,
                b_sel,
                op_sel,
                w_sel,
                w_en
                );
    
        initial begin
        rst=1;
        clk=1;
        //en <=1;
        //num <= 5;
        #20;
       // en<= 0;
        rst=0;
        #240;
        $stop;
    end
    
    endmodule 
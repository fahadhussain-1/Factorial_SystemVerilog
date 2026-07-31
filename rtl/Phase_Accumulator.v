`timescale 1ns / 1ps



module Phase_Accumulator(

    input  wire        clk,
    input  wire        rst,
    input  wire        CFR1_DIGITAL_PWRDN,
    input  wire        clr_phase_acc_auto,
    input  wire        clr_phase_acc_manual,
    input  wire [31:0] ftw,
    output reg  [31:0] phase_acc_out
);

always @(posedge clk) begin
    if (rst | CFR1_DIGITAL_PWRDN | clr_phase_acc_auto | clr_phase_acc_manual)
        phase_acc_out <= 32'd0;
    else
        phase_acc_out <= phase_acc_out + ftw;
end
endmodule



/////HEllo World
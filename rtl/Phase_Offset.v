`timescale 1ns / 1ps

module Phase_Offset(
    input  wire         clk,
    input  wire         rst,
    input  wire         CFR1_DIGITAL_PWRDN,
    input  wire [31:0]  phase_acc,
    input  wire [13:0]  phase_offset,
    output reg  [18:0]  phase_offset_out
);
    reg [31:0] phase_off_d;

    always @(posedge clk) begin
        if (rst | CFR1_DIGITAL_PWRDN) begin
            phase_off_d      <= 32'd0;
            phase_offset_out <= 19'd0;
        end
        else begin
            phase_off_d      <= phase_acc + {phase_offset, 18'b0};  // align offset to MSBs
            phase_offset_out <= phase_off_d[31:13];
        end
    end

endmodule

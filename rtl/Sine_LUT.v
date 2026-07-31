`timescale 1ns / 1ps



module Sine_LUT (
    input  wire               clk,
    input  wire               rst,
    input  wire               CFR1_DIGITAL_PWRDN,
    input  wire               CFR1_SINE_OUT,
    input  wire [18:0]        phase_adjusted,
    output reg  signed [13:0] sine_out
);

    // --------------------------------------------------------
    // LUT Memory (Q1 only: 0� to 90�, 131072 entries)
    // --------------------------------------------------------
    reg [13:0] sine_mem [0:131071];
    initial begin
        $readmemh("../rtl/sine_lut_90.txt", sine_mem);
    end

    // --------------------------------------------------------
    // Address decomposition
    // --------------------------------------------------------
    wire [1:0]  quadrant = phase_adjusted[18:17];
    wire [16:0] lut_addr = phase_adjusted[16:0];
    reg delay;
    reg [1:0] counter;
    // --------------------------------------------------------
    // Mirror address
    // SINE:   mirror on Q1, Q3 (odd quadrants  = falling)
    // COSINE: mirror on Q0, Q2 (even quadrants = falling, 90� shifted)
    // --------------------------------------------------------
    wire [16:0] mirrored_addr = 17'h1FFFF - lut_addr;

    wire sine_mirror = (quadrant == 2'b01 || quadrant == 2'b11);
    wire cos_mirror  = (quadrant == 2'b00 || quadrant == 2'b10);

    wire [16:0] effective_addr = (CFR1_SINE_OUT ? sine_mirror : cos_mirror)
                                  ? mirrored_addr
                                  : lut_addr;
    wire [16:0] effective_addr2 = delay ? effective_addr : 17'd0;
    // --------------------------------------------------------
    // Registered quadrant + LUT read (same pipeline stage)
    // --------------------------------------------------------
    reg [1:0]  quadrant_reg;
    reg        sine_mode_reg;
    reg [13:0] lut_value;


    always @(posedge clk) begin
        if (rst | CFR1_DIGITAL_PWRDN) begin
            delay   <= 1'b0;
            counter <= 2'd0;
        end
        else begin
            if (counter == 2'd2) begin   // next cycle counter will be 3
                delay   <= 1'b1;
                counter <= counter + 1;
            end
            else if (counter == 2'd3) begin
                delay   <= 1'b1;         // stay high, stop incrementing
            end
            else begin
                counter <= counter + 1;
            end
        end
    end

    always @(posedge clk) begin
        if (rst | CFR1_DIGITAL_PWRDN) begin
            quadrant_reg  <= 2'd0;
            sine_mode_reg <= 1'b1;
            lut_value     <= 14'd0;
        end
        else begin
            quadrant_reg  <= quadrant;
            sine_mode_reg <= CFR1_SINE_OUT;       // pipeline CFR1 alongside quadrant
            lut_value     <= sine_mem[effective_addr2];
        end
    end

    // --------------------------------------------------------
    // Quadrant reconstruction
    // --------------------------------------------------------
    always @(posedge clk) begin
        if (rst | CFR1_DIGITAL_PWRDN)
            sine_out <= 14'd0;
        else begin
            if (sine_mode_reg) begin
                // SINE
                case (quadrant_reg)
                    2'b00: sine_out <=  $signed({1'b0, lut_value}); // Q1: +rising
                    2'b01: sine_out <=  $signed({1'b0, lut_value}); // Q2: +falling
                    2'b10: sine_out <= -$signed({1'b0, lut_value}); // Q3: -rising
                    2'b11: sine_out <= -$signed({1'b0, lut_value}); // Q4: -falling
                endcase
            end
            else begin
                // COSINE (90� ahead of sine)
                case (quadrant_reg)
                    2'b00: sine_out <=  $signed({1'b0, lut_value}); // cos Q0: +falling
                    2'b01: sine_out <= -$signed({1'b0, lut_value}); // cos Q1: -rising
                    2'b10: sine_out <= -$signed({1'b0, lut_value}); // cos Q2: -falling
                    2'b11: sine_out <=  $signed({1'b0, lut_value}); // cos Q3: +rising
                endcase
            end
        end
    end
endmodule



`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/23 21:48:04
// Design Name: 
// Module Name: adder
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


module Adder32(
    input [31:0] a,
    input [31:0] b,
    output [31:0] sum,
    output carry_out
    );
    wire carry_out_in [30:0];
    Adder1 add0(a[0], b[0], 0, carry_out_in[0], sum[0]);
    Adder1 add1(a[1], b[1], carry_out_in[0], carry_out_in[1], sum[1]);
    Adder1 add2(a[2], b[2], carry_out_in[1], carry_out_in[2], sum[2]);
    Adder1 add3(a[3], b[3], carry_out_in[2], carry_out_in[3], sum[3]);
    Adder1 add4(a[4], b[4], carry_out_in[3], carry_out_in[4], sum[4]);
    Adder1 add5(a[5], b[5], carry_out_in[4], carry_out_in[5], sum[5]);
    Adder1 add6(a[6], b[6], carry_out_in[5], carry_out_in[6], sum[6]);
    Adder1 add7(a[7], b[7], carry_out_in[6], carry_out_in[7], sum[7]);
    Adder1 add8(a[8], b[8], carry_out_in[7], carry_out_in[8], sum[8]);
    Adder1 add9(a[9], b[9], carry_out_in[8], carry_out_in[9], sum[9]);
    Adder1 add10(a[10], b[10], carry_out_in[9], carry_out_in[10], sum[10]);
    Adder1 add11(a[11], b[11], carry_out_in[10], carry_out_in[11], sum[11]);
    Adder1 add12(a[12], b[12], carry_out_in[11], carry_out_in[12], sum[12]);
    Adder1 add13(a[13], b[13], carry_out_in[12], carry_out_in[13], sum[13]);
    Adder1 add14(a[14], b[14], carry_out_in[13], carry_out_in[14], sum[14]);
    Adder1 add15(a[15], b[15], carry_out_in[14], carry_out_in[15], sum[15]);
    Adder1 add16(a[16], b[16], carry_out_in[15], carry_out_in[16], sum[16]);
    Adder1 add17(a[17], b[17], carry_out_in[16], carry_out_in[17], sum[17]);
    Adder1 add18(a[18], b[18], carry_out_in[17], carry_out_in[18], sum[18]);
    Adder1 add19(a[19], b[19], carry_out_in[18], carry_out_in[19], sum[19]);
    Adder1 add20(a[20], b[20], carry_out_in[19], carry_out_in[20], sum[20]);
    Adder1 add21(a[21], b[21], carry_out_in[20], carry_out_in[21], sum[21]);
    Adder1 add22(a[22], b[22], carry_out_in[21], carry_out_in[22], sum[22]);
    Adder1 add23(a[23], b[23], carry_out_in[22], carry_out_in[23], sum[23]);
    Adder1 add24(a[24], b[24], carry_out_in[23], carry_out_in[24], sum[24]);
    Adder1 add25(a[25], b[25], carry_out_in[24], carry_out_in[25], sum[25]);
    Adder1 add26(a[26], b[26], carry_out_in[25], carry_out_in[26], sum[26]);
    Adder1 add27(a[27], b[27], carry_out_in[26], carry_out_in[27], sum[27]);
    Adder1 add28(a[28], b[28], carry_out_in[27], carry_out_in[28], sum[28]);
    Adder1 add29(a[29], b[29], carry_out_in[28], carry_out_in[29], sum[29]);
    Adder1 add30(a[30], b[30], carry_out_in[29], carry_out_in[30], sum[30]);
    Adder1 add31(a[31], b[31], carry_out_in[30], carry_out, sum[31]);
endmodule
module Adder1(
    input a,
    input b,
    input carry_in,
    output carry_out,
    output sum
);
    assign sum = a ^ b ^ carry_in;
    assign carry_out = a & b | (a ^ b) & carry_in;
endmodule
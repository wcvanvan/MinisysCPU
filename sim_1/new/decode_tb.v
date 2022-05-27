`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/16 11:07:19
// Design Name: 
// Module Name: decode_tb
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


module decode_tb(
    );
    wire [31:0] dat1;
    wire [31:0] dat2;
    wire [31:0] instr = 32'b00110101001010010000000000000000;
    reg [31:0] mem = 32'b0;
    reg [31:0] res = 32'b0;
    reg jal = 1'b1;
    reg regwrite = 1'b1;
    reg memtoreg = 1'b1;
    reg regdst = 1'b1;
    wire [31:0] extend;
    reg clock, reset;
    reg [31:0] opcplus4 = 32'b0;
    decode32 dec(
        .read_data_1(dat1),
        .read_data_2(dat2),
        .Instruction(instr),
        .mem_data(mem),
        .ALU_result(res),
        .Jal(jal),
        .RegWrite(regwrite),
        .MemtoReg(memtoreg),
        .RegDst(regdst),
        .Sign_extend(extend),
        .clock(clock),
        .reset(reset),
        .opcplus4(opcplus4)
    );
    initial clock = 1'b0;
    always #10 clock = ~clock;
    initial begin
        reset = 1'b1;
        #20 reset = 1'b0;
        regwrite = 1'b0;
        #100 regwrite = 1'b1;
        #500 regwrite = 1'b0;
    end
endmodule

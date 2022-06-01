`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/14 15:27:39
// Design Name: 
// Module Name: decoder
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
module regfiles(        // A submodule of the decoder, which is down below.
    // Cannot put into another file due to some unkown Vivado bugs.
    input clock, reset,
    input regWrite,      // Whether or not write data to the registers.
    // following two are for mult/div, if they are valid, regWrite must be zero!
    // when using HI_LO_move, writeDst is also used
    input HI_LO_write,       // 1 for write both (mult, div), 0 for do not write
    input [1:0] HI_LO_move,  // 10 for mfhi; 01 for mflo; 00 for do not move HI or LO
    input [32:0] HI_data,    // data going to write HI
    input [32:0] LO_data,    // data going to write LO

    input [4:0] read1,          // The first address to read from.
    input [4:0] read2,          // The second address to read from.
    input [4:0] writeDst,      // The address to write to.
    input [31:0] writeData,  // The data to be written.
    output [31:0] data1,      // The data in the register read1.
    output [31:0] data2      // The data in the register read2.
    );
    reg [31:0] registers[0:31];

    reg [31:0] HI;
    reg [31:0] LO;

    always @(posedge clock) begin
        if(reset == 1'b1) begin
            registers[0] <= 32'b0;
            registers[1] <= 32'b0;
            registers[2] <= 32'b0;
            registers[3] <= 32'b0;
            registers[4] <= 32'b0;
            registers[5] <= 32'b0;
            registers[6] <= 32'b0;
            registers[7] <= 32'b0;
            registers[8] <= 32'b0;
            registers[9] <= 32'b0;
            registers[10] <= 32'b0;
            registers[11] <= 32'b0;
            registers[12] <= 32'b0;
            registers[13] <= 32'b0;
            registers[14] <= 32'b0;
            registers[15] <= 32'b0;
            registers[16] <= 32'b0;
            registers[17] <= 32'b0;
            registers[18] <= 32'b0;
            registers[19] <= 32'b0;
            registers[20] <= 32'b0;
            registers[21] <= 32'b0;
            registers[22] <= 32'b0;
            registers[23] <= 32'b0;
            registers[24] <= 32'b0;
            registers[25] <= 32'b0;
            registers[26] <= 32'b0;
            registers[27] <= 32'b0;
            registers[28] <= 32'b0;
            registers[29] <= 32'b0;
            registers[30] <= 32'b0;
            registers[31] <= 32'b0;
            HI            <= 32'b0;
            LO            <= 32'b0;
        end
        else if(regWrite == 1'b1 && writeDst != 5'b0) registers[writeDst] <= writeData;      // Write data if regWrite is 1 and it is not $0.
        else begin
            case (HI_LO_move)
                2'b10: registers[writeDst] <= HI;
                2'b01: registers[writeDst] <= LO;
            endcase
            if (HI_LO_write) begin
                HI <= HI_data;
                LO <= LO_data;
            end
        end
    end
    assign data1 = registers[read1];
    assign data2 = registers[read2];
endmodule

module Decode32(
    input clock, reset,
    input RegWrite,         // 1 for writing to reg
    input RegDst,           // 0 for write to rt, 1 for write to rd
    input MemOrIOToReg,         // 1 for reading data from the mem to regs
    input Jal,              // 1 for jal instruction
    input [31:0] mem_or_io_data,      // data from mem or io
    input [31:0] ALU_result,    // data from alu
    input [31:0] opcplus4,      // PC + 4
    input [31:0] Instruction,   // the 32-bit instruction

    input write_HI_LO,           // 1 for write, 0 for not.
    input [1:0] move_HI_LO,  // 10 for mfhi, 01 for mflo, otherwise nothing.
    input [31:0] ALU_HI,        // HI data from ALU
    input [31:0] ALU_LO,        // LO data from ALU

    output [31:0] read_data_1,    // the data in the reg determined by rs
    output [31:0] read_data_2,    // the data in the reg determined by rt
    output [31:0] Sign_extend     // the extended 32-bit immediate
    );
    wire [4:0] rs = Instruction[25:21];
    wire [4:0] rt = Instruction[20:16];
    wire [4:0] rd = Instruction[15:11];
    wire [4:0] writeDst = (RegDst == 1'b1) ? rd : rt;
    wire [31:0] writeData = (MemOrIOToReg == 1'b1) ? mem_or_io_data : ALU_result;
    wire [31:0] writeAddrorData = (Jal == 1'b1) ? opcplus4 : writeData;
    wire [4:0] writeOrJal = (Jal == 1'b1) ? 31 : writeDst;
    regfiles registers(
        .clock(clock),
        .reset(reset),
        .regWrite(RegWrite),

        .HI_LO_write(write_HI_LO),
        .HI_LO_move(move_HI_LO),
        .HI_data(ALU_HI),
        .LO_data(ALU_LO),

        .read1(rs),
        .read2(rt),
        .writeDst(writeOrJal),
        .writeData(writeAddrorData),
        .data1(read_data_1),
        .data2(read_data_2)
    );
    wire [15:0] imm = Instruction[15:0];
    reg [31:0] Sign_extend_reg;
    always @(*) begin
        Sign_extend_reg <= {{16{imm[15]}}, imm};
    end
    assign Sign_extend = Sign_extend_reg;
endmodule

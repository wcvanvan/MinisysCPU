`timescale 1ns / 1ps


module Control32(Opcode,
                 Function_opcode,
                 RegDST,
                 ALUSrc,
                 MemOrIOtoReg,
                 RegWrite,
                 write_HI_LO,
                 move_HI_LO,
                 MemWrite,
                 MemRead,
                 IORead,
                 IOWrite,
                 Branch,
                 nBranch,
                 Jmp,
                 Jal,
                 I_format,
                 Sftmd,
                 ALUOp,
                 Jr,
                 ALUResultHigh);
    // new :ALUResultHigh, MemOrIOtoReg, MemRead, IORead, IOWrite, write_HI_LO, move_HI_LO
    input [5:0] Opcode;
    input [5:0] Function_opcode;
    output Jr;
    output RegDST;
    output ALUSrc;
    output MemOrIOtoReg;
    output RegWrite;

    output write_HI_LO;
    output [1:0] move_HI_LO;

    output MemRead;
    output MemWrite;
    output IORead;
    output IOWrite;
    output Branch;
    output nBranch;
    output Jmp;
    output Jal;
    wire R_type;
    output I_format;  // I-Type instruction except Branch, nBranch, lw, sw
    output Sftmd;
    output [1:0]ALUOp;
    input [21:0] ALUResultHigh; // From the execution unit Alu_Result[31..10]
    wire Lw;
    wire Sw;
    wire HI_LO;  // meaning the instruction involve HI/LO

    assign R_type       = (Opcode == 6'b000000)? 1'b1:1'b0;
    assign HI_LO        = (R_type && Function_opcode[5:4] == 2'b01) ? 1'b1 : 1'b0;
    assign RegDST       = R_type;
    assign I_format     = (Opcode[5:3] == 3'b001)?1'b1:1'b0;
    assign lw           = (Opcode == 6'b100011)? 1'b1:1'b0;
    assign sw           = (Opcode == 6'b101011)? 1'b1:1'b0;
    assign Jal          = (Opcode == 6'b000011)?1'b1:1'b0;
    assign Jr           = (R_type && Function_opcode == 6'b001000)?1'b1:1'b0;
    assign Jmp          = (Opcode == 6'b000010)? 1'b1:1'b0;
    assign Branch       = (Opcode == 6'b000100)? 1'b1:1'b0;
    assign nBranch      = (Opcode == 6'b000101)? 1'b1:1'b0;
    assign RegWrite     = ((R_type && !HI_LO && !Jr) || I_format || lw || Jal);
    assign ALUSrc       = (I_format || Opcode == 6'b10_0011 || Opcode == 6'b10_1011) ? 1'b1 : 1'b0;
    assign MemWrite     = ((sw == 1) && (ALUResultHigh != 22'h3FFFFF)) ? 1'b1:1'b0;
    assign MemRead      = ((lw == 1) && (ALUResultHigh != 22'h3FFFFF)) ? 1'b1:1'b0;
    assign IORead       = ((lw == 1) && (ALUResultHigh == 22'h3FFFFF)) ? 1'b1:1'b0;
    assign IOWrite      = ((sw == 1) && (ALUResultHigh == 22'h3FFFFF)) ? 1'b1:1'b0;
    assign MemOrIOtoReg = IORead || MemRead;
    assign Sftmd        = (R_type && Function_opcode[5:3] == 3'b000)? 1'b1:1'b0 ;
    assign ALUOp        = {(R_type || I_format),(Branch || nBranch)};

    assign write_HI_LO  = (R_type && Function_opcode[5:2] == 4'b0110) ? 1'b1 : 1'b0;
    assign move_HI_LO   = (R_type && Function_opcode == 6'b01_0000) ? 2'b10
                        : ((R_type && Function_opcode == 6'b01_0010) ? 2'b01 : 2'b00);
endmodule

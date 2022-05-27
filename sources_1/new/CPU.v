`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2022/05/18 22:12:18
// Design Name:
// Module Name: CPU
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


module CPU(input clk,
           input rst,
           input [23:0] io_rdata,
           output [23:0] io_wdata
           );
    
    wire [31:0] pcplus4;
    wire [31:0] addr_in;
    wire [31:0] addr_out;
    wire zero;
    wire jr;
    wire jal;
    wire jmp;
    wire branch;
    wire nbranch;
    wire [31:0] read_data_1; 
    wire [31:0] instruction;
    wire [31:0] branch_base_addr;
    wire [31:0] link_addr;
    Ifetc32 ifetc32(
    .clock(clk),
    .reset(rst),
    .Zero(zero),
    .Jr(jr),
    .Jal(jal),
    .Jmp(jmp),
    .Read_data_1(read_data_1),
    .Addr_result(addr_result),
    .Instruction(instruction),
    .branch_base_addr(pcplus4),
    .link_addr(link_addr),
    .Branch(branch),
    .nBranch(nbranch)
    );
    wire [5:0] opcode = instruction[31:26];
    wire [5:0] funct  = instruction[5:0];
    wire regdst;
    wire alusrc;
    wire mem_or_io_to_reg;
    wire regwrite;
    wire memwrite;
    wire memread;
    wire ioread;
    wire iowrite;
    wire iformat;
    wire sftmd;
    wire [1:0] aluop;
    
    wire [31:0] mem_or_io_data;
    wire [31:0] alu_result;
    wire [31:0] read_data_2;
    wire [31:0] sign_extend;
    
    Control32 control32(
    .ALUResultHigh(addr_in[31:10]),
    .Opcode(opcode),
    .Function_opcode(funct),
    .RegDST(regdst),
    .ALUSrc(alusrc),
    .MemOrIOtoReg(mem_or_io_to_reg), // modify
    .RegWrite(regwrite),
    .MemWrite(memwrite),
    .MemRead(memread), // modify
    .IORead(ioread), // modify
    .IOWrite(iowrite), // modify
    .Branch(branch),
    .nBranch(nbranch),
    .Jmp(jmp),
    .Jal(jal),
    .I_format(iformat),
    .Sftmd(sftmd),
    .ALUOp(aluop),
    .Jr(jr)
    );
    
    wire [31:0] r_wdata;
    Decode32 decode32(
    .clock(clk),
    .reset(rst),
    .RegWrite(regwrite),
    .RegDst(regdst),
    .MemOrIOToReg(mem_or_io_to_reg),
    .Jal(jal),
    .mem_or_io_data(r_wdata),
    .ALU_result(alu_result),
    .opcplus4(pcplus4),
    .Instruction(instruction),
    .read_data_1(read_data_1),
    .read_data_2(mem_or_io_data),
    .Sign_extend(sign_extend)
    );
    
    wire [4:0] shamt = instruction[10:6];
    Executs32 alu(
    .Read_data_1(read_data_1),
    .Read_data_2(mem_or_io_data),
    .Sign_extend(sign_extend),
    .Exe_opcode(opcode),
    .Function_opcode(funct),
    .Shamt(shamt),
    .PC_plus_4(pcplus4),
    .ALUOp(aluop),
    .ALUSrc(alusrc),
    .I_format(iformat),
    .Sftmd(sftmd),
    .Jr(jr),
    .Zero(zero),
    .ALU_Result(alu_result),
    .Addr_Result(addr_in)
    );
    
    wire [31:0] m_wdata;
    Dmemory32 dmemory32(
    .clock(clk),
    .memWrite(memwrite),
    .address(addr_out),
    .writeData(m_wdata),
    .readData(m_rdata)
    );
    
    wire [31:0] sign_extend_shift_left = sign_extend << 2;
    Adder32 jmp_adder(
    .a(pcplus4),
    .b(sign_extend_shift_left),
    .sum(addr_result),
    .carry_out()
    );
    
    MemOrIO mem_or_io(
    .mRead(memread),
    .mWrite(memwrite),
    .ioRead(ioread),
    .ioWrite(iowrite),
    .addr_in(addr_in),
    .addr_out(addr_out),
    .m_rdata(m_rdata),
    .io_rdata(io_rdata),
    .r_wdata(r_wdata),
    .r_rdata(mem_or_io_data),
    .data_to_dmem(m_wdata),
    .data_to_io(io_wdata));
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module Ifetc32(Instruction_i,
               Instruction,
               branch_base_addr,
               Addr_result,
               Read_data_1,
               Branch,
               nBranch,
               Jmp,
               Jal,
               Jr,
               Zero,
               clock,
               reset,
               link_addr,
               rom_addr_o);
    input[31:0] Instruction_i; // read instruction from outside prgrom
    output[31:0] Instruction;			// 根据PC的�?�从存放指令的prgrom中取出的指令
    output[31:0] branch_base_addr;      // 对于有条件跳转类的指令�?�言，该值为(pc+4)送往ALU
    input[31:0]  Addr_result;            // 来自ALU,为ALU计算出的跳转地址
    input[31:0]  Read_data_1;           // 来自Decoder，jr指令用的地址
    input        Branch;                // 来自控制单元
    input        nBranch;               // 来自控制单元
    input        Jmp;                   // 来自控制单元
    input        Jal;                   // 来自控制单元
    input        Jr;                   // 来自控制单元
    input        Zero;                  //来自ALU，Zero�????1表示两个值相等，反之表示不相�????
    input        clock,reset;           //时钟与复�????,复位信号用于给PC赋初始�?�，复位信号高电平有�????
    output[31:0] link_addr;             // JAL指令专用的PC+4
    output[13:0] rom_addr_o; // give the current pc to prgrom`
    reg [31:0]pc;
    reg [31:0]next_pc;
    reg [31:0]link_addr;
    assign rom_addr_o = pc[15:2];
    
    assign Instruction = Instruction_i;
    
    assign branch_base_addr = pc + 3'b100;
    // once any signal is triggered, next_pc will be calculated
    always @* begin
        if (Jr)
            next_pc = Read_data_1;
        else if ((Branch && (Zero == 1)) || (nBranch && (Zero == 0)))
            next_pc = Addr_result;
        else
            next_pc = branch_base_addr;
            // because one Instruction contains 4 bytes, shift is compulsory
    end
    
    always @(negedge clock) begin
        if (reset) begin
            pc = 32'd0;
        end
        else begin
            pc = next_pc;
            if (Jal || Jmp) begin
                if (Jal) begin
                    // if Jal happens, first pass the current address to decoder to get stored, second set current pc to ...
                    link_addr = next_pc;
                end
                pc = {4'b0000,Instruction[25:0],2'b00};
            end
        end
    end
endmodule

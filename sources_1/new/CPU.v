`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SUSTech
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
           input [23:0] io_rdata,
           output reg [23:0] io_wdata,
           input fpga_rst,         // active high
           input start_uart,       // active high
           input rx,               // receive data by uart
           output tx);             // send data by uart
    
    wire clk_out1, clk_out2;
    cpuclk cpuclk0(
    .clk_in1(clk),             // on-board 100MHz clock
    .clk_out1(clk_out1), // for cpu use, 23MHz
    .clk_out2(clk_out2) // for uart device use, 10MHz
    );
    
    wire rst;
    wire [31:0] pcplus4;
    wire [31:0] addr_in; // alu calculated current address + imm
    wire [31:0] addr_out;  // = addr_in for now, reserved for the future extension, and to avoid multi-driven net
    wire zero;
    wire jr;
    wire jal;
    wire jmp;
    wire branch;
    wire nbranch;
    wire [31:0] read_data_1;
    wire [31:0] instruction;
    wire [31:0] branch_base_addr;  // original addr_in, bu gan delete
    wire [31:0] link_addr;          // used for jal to store in $ra
    wire [13:0] rom_addr_o;     // current pc, do not use pc, which could lead to multi-driven net
    
    // UART Programmer Pinouts
    wire upg_clk_o;
    wire upg_wen_o; //Uart write out enable
    wire upg_done_o; //Uart rx data have done
    //data to which memory unit of program_rom/dmemory32
    wire [14:0] upg_adr_o;
    //data to program_rom or dmemory32
    wire [31:0] upg_dat_o;
    
    wire spg_bufg;
    BUFG U1(.I(start_uart), .O(spg_bufg)); // de-twitter
    // Generate UART Programmer reset signal
    reg upg_rst;
    always @ (posedge clk) begin
        if (spg_bufg) upg_rst = 0;
        if (fpga_rst) upg_rst = 1;
    end
    assign rst = fpga_rst | !upg_rst;
    
    uart_bmpg_0 uart (
    .upg_clk_i(clk_out2),
    .upg_rst_i(upg_rst),
    .upg_rx_i(rx),
    .upg_clk_o(upg_clk_o),
    .upg_wen_o(upg_wen_o),
    .upg_adr_o(upg_adr_o),
    .upg_dat_o(upg_dat_o),
    .upg_done_o(upg_done_o),
    .upg_tx_o(tx)
    );
    
    wire[31:0] Instruction_o;
    wire upg_wen_i_for_prgrom; // uart enable for prgrom
    assign upg_wen_i_for_prgrom = upg_wen_o  & (!upg_adr_o[14]);
    
    programrom pr(
    .rom_clk_i(clk_out1),
    .rom_adr_i(rom_addr_o),
    .upg_rst_i(upg_rst),
    .upg_clk_i(upg_clk_o),
    .upg_wen_i(upg_wen_i_for_prgrom),
    .upg_adr_i(upg_adr_o[13:0]),
    .upg_dat_i(upg_dat_o),
    .upg_done_i(upg_done_o),
    .Instruction_o(Instruction_o)
    );
    
    
    Ifetc32 ifetc32(
    .clock(clk_out1),
    .reset(rst),
    .Zero(zero),
    .Jr(jr),
    .Jal(jal),
    .Jmp(jmp),
    .Read_data_1(read_data_1),
    .Addr_result(addr_in),
    .Instruction(instruction),
    .Instruction_i(Instruction_o),
    .branch_base_addr(pcplus4),
    .link_addr(link_addr),
    .Branch(branch),
    .nBranch(nbranch),
    .rom_addr_o(rom_addr_o)
    );
    
    wire [5:0] opcode = instruction[31:26];
    wire [5:0] funct  = instruction[5:0];
    wire regdst;
    wire alusrc;
    wire mem_or_io_to_reg;
    wire regwrite;
    wire [3:0] memwrite;
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

    wire HI_LO_write;      // whether or not write to HI or LO
    wire [1:0] HI_LO_move;
    wire Do_Byte, Do_Half, Do_load, Do_signed;
    
    Control32 control32(
    .ALUResultHigh(alu_result[31:10]),
    .Opcode(opcode),
    .Function_opcode(funct),
    .RegDST(regdst),
    .ALUSrc(alusrc),
    .MemOrIOtoReg(mem_or_io_to_reg), 
    .RegWrite(regwrite),
    .MemWrite(memwrite),
    .MemRead(memread), 
    .IORead(ioread), 
    .IOWrite(iowrite), 
    .Branch(branch),
    .nBranch(nbranch),
    .Jmp(jmp),
    .Jal(jal),
    .I_format(iformat),
    .Sftmd(sftmd),
    .ALUOp(aluop),
    .Jr(jr),
    .HI_LO_write(HI_LO_write),
    .HI_LO_move(HI_LO_move),
    .Do_Byte(Do_Byte),
    .Do_Half(Do_Half),
    .Do_load(Do_load),
    .Do_signed(Do_signed)
    );


    wire [31:0] r_wdata;        // register write data
    wire [31:0] HI_data, LO_data;
    wire [31:0] extended_load_data;
    wire [31:0] m_rdata;       // memory read data
    // extend to 32 bits, after read mem (lh, lb)
    extender extend_load(
        .Do_load(Do_load),
        .Do_signed(Do_signed),
        .Do_Byte(Do_Byte),
        .Do_Half(Do_Half),
        .Word_in(m_rdata),
        .Extended_out(extended_load_data)
    );

    Decode32 decode32(
    .clock(clk_out1),
    .reset(rst),
    .RegWrite(regwrite),
    .write_HI_LO(HI_LO_write),
    .move_HI_LO(HI_LO_move),
    .ALU_HI(HI_data),
    .ALU_LO(LO_data),

    .RegDst(regdst),
    .MemOrIOToReg(mem_or_io_to_reg),
    .Jal(jal),
    .mem_or_io_data(r_wdata),
    .ALU_result(alu_result),
    .opcplus4(link_addr),
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
    .Addr_Result(addr_in),
    .HI_result(HI_data),
    .LO_result(LO_data)
    );

    wire [31:0] Address_out;     // standard address, used for sh, sb, lh, lb...
    wire [3:0]  memwrite_out;  // memWrite enable
    // standard new address for store/load halfword/byte
    new_dmem_address new_addre(
        .Do_load(Do_load),
        .Do_Byte(Do_Byte),
        .Do_Half(Do_Half),
        .Address_in(addr_out),
        .Address_out(Address_out),
        .MemWrite_ori(memwrite), 
        .MemWrite(memwrite_out)
    );

    wire [31:0] extended_word;
    wire [31:0] data_to_dmem_or_io;
    // extend to 32 bits, for store halfword/byte
    extender extend_store(
        .Do_load(Do_load),
        .Do_signed(Do_signed),
        .Do_Byte(Do_Byte),
        .Do_Half(Do_Half),
        .Word_in(data_to_dmem_or_io),
        .Extended_out(extended_word)
    );

    wire upg_wen_i_for_dmem; // uart enable for dmem
    assign upg_wen_i_for_dmem = (upg_wen_o & upg_adr_o[14]) ? 4'b1111 : 4'b0000; 
    Dmemory32 dmemory32(
    .clock(clk_out1),
    .memWrite(memwrite_out),
    .address(Address_out),
    .writeData(extended_word),
    .readData(m_rdata),
    .upg_rst_i(upg_rst),
    .upg_clk_i(upg_clk_o),
    .upg_wen_i(upg_wen_i_for_dmem),
    .upg_adr_i(upg_adr_o[13:0]),
    .upg_dat_i(upg_dat_o),
    .upg_done_i(upg_done_o)
    );


    MemOrIO mem_or_io(
    .mRead(memread),
    .mWrite(memwrite_out),
    .ioRead(ioread),
    .ioWrite(iowrite),
    .addr_in(alu_result),
    .addr_out(addr_out),
    .m_rdata(extended_load_data),
    .io_rdata(io_rdata),
    .r_wdata(r_wdata),
    .r_rdata(mem_or_io_data),
    .data_to_dmem_or_io(data_to_dmem_or_io)
    );
    
    
    always @(*) begin
        if (iowrite) begin
            io_wdata = data_to_dmem_or_io[23:0];
        end
    end
    
endmodule

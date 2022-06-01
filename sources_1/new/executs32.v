module Executs32(Read_data_1,Read_data_2,Sign_extend,Function_opcode,Exe_opcode,ALUOp,
                 Shamt,ALUSrc,I_format,Zero,Jr,Sftmd,ALU_Result,Addr_Result,PC_plus_4,
                 HI_result,
                 LO_result
                 );
    input[31:0]  Read_data_1;       // from Decoder, Read_data_1
    input[31:0]  Read_data_2;       // from Decoder, Read_data_2
    input[31:0]  Sign_extend;       // from Decoder, extended immediate

    input[5:0]   Exe_opcode;        // from I-fetch, Op-code of instruction
    input[5:0]   Function_opcode;   // from I-fetch, R-form instructions[5:0]
    input[4:0]   Shamt;             // from I-fetch, instruction[10:6], determine the shift amount
    input[31:0]  PC_plus_4;         // from I-fetch, PC+4

    input[1:0]   ALUOp;             // from Controller
    input        ALUSrc;            // from Controller, meaning the 2nd operand is immediate (except beq£¬bne)
    input        I_format;          // from Controller, meaning I-form instruction, except beq, bne, lw, sw
    input        Sftmd;             // from Controller, meaning shift instruction
    input        Jr;                // from Controller, meaning jr instruction

    output  Zero;                   // high for result 0
    output reg [31:0] ALU_Result;   // calculation results
    output [31:0] Addr_Result;      // calculated address results

    output reg [31:0] HI_result;    // mult, multu, div, divu
    output reg [31:0] LO_result;    // mult, multu, div, divu

    wire[31:0] Ainput,Binput;       // two operands for calculation
    wire[5:0] Exe_code;             // for generating ALU_contrl
    wire[2:0] ALU_ctl;              // control signals which affact operation in ALU directely
    wire[2:0] Sftm_code;            // identify the types of shift instruction, equals to Function_opcode[2:0]
    reg[31:0] Shift_Result;         // the result of shift operation
    reg[31:0] ALU_output_mux;       // the result of arithmetic or logic calculation

    assign Ainput = Read_data_1;
    assign Binput = (ALUSrc == 0) ? Read_data_2 : Sign_extend[31:0];

    assign Exe_code = (I_format == 0) ? Function_opcode : {3'b000, Exe_opcode[2:0]};

    assign ALU_ctl[0] = (Exe_code[0] | Exe_code[3]) & ALUOp[1];
    assign ALU_ctl[1] = ((~Exe_code[2]) | (~ALUOp[1]));
    assign ALU_ctl[2] = (Exe_code[1] & ALUOp[1]) | ALUOp[0];

    assign Sftm_code = Function_opcode[2:0]; //the code of shift operation

    assign Addr_Result = PC_plus_4 + (Sign_extend << 2);
    assign Zero = ALU_output_mux == 0 ? 1 : 0;

    always @* begin
        if (Exe_opcode == 6'b000000) begin
            case(Function_opcode)
                6'b01_1000: {HI_result, LO_result} = $signed(Read_data_1) * $signed(Read_data_2); // mult
                6'b01_1001: {HI_result, LO_result} = Read_data_1 * Read_data_2;                   // multu
                6'b01_1010: begin                                                                 // div
                    LO_result = $signed(Read_data_1) / $signed(Read_data_2);
                    HI_result = $signed(Read_data_1) % $signed(Read_data_2);
                end
                6'b01_1011: begin                                                                 // divu
                    LO_result = Read_data_1 / Read_data_2;
                    HI_result = Read_data_1 % Read_data_2;
                end
                default: {HI_result, LO_result} = 64'h0000_0000_0000_0000;
            endcase
        end
    end

    always @* begin
        if (Exe_opcode[5:4] == 2'b10) ALU_output_mux = Ainput + Binput;
        else begin
        case(ALU_ctl)
            3'b000: ALU_output_mux = Ainput & Binput;   // and, andi
            3'b001: ALU_output_mux = Ainput | Binput;   // or, ori
            3'b010: ALU_output_mux = Ainput + Binput;   // add, addi, lw, sw
            3'b011: ALU_output_mux = Ainput + Binput;   // addu, addiu
            3'b100: ALU_output_mux = Ainput ^ Binput;   // xor, xori
            3'b101: ALU_output_mux = ~(Ainput | Binput);// nor, !! lui
            3'b110: ALU_output_mux = $signed(Ainput) - $signed(Binput);   // sub, slti, beq, bne
            3'b111: ALU_output_mux = Ainput - Binput;   // subu, sltiu, slt, sltu
            default: ALU_output_mux = 32'h0000_0000;
        endcase
        end
    end

    always @* begin // six types of shift instructions
        if(Sftmd) begin
            case(Sftm_code[2:0])
                3'b000:Shift_Result = Binput << Shamt;              // sll rd,rt,shamt 00000
                3'b010:Shift_Result = Binput >> Shamt;              // srl rd,rt,shamt 00010
                3'b100:Shift_Result = Binput << Ainput;             // sllv rd,rt,rs 00010
                3'b110:Shift_Result = Binput >> Ainput;             // srlv rd,rt,rs 00110
                3'b011:Shift_Result = $signed(Binput) >>> Shamt;    // sra rd,rt,shamt 00011
                3'b111:Shift_Result = $signed(Binput) >>> Ainput;   // srav rd,rt,rs 00111
                default:Shift_Result = Binput;
            endcase
        end
        else
            Shift_Result = Binput;
    end

    always @* begin
        //set operation (slt, slti, sltu, sltiu)
        if((Function_opcode == 6'b101010 && Exe_opcode == 6'b000000) || Exe_opcode == 6'b001010) // slt, slti
            ALU_Result = ($signed(Ainput) < $signed(Binput)) ? 1 : 0;
        else if ((Function_opcode == 6'b101011 && Exe_opcode == 6'b000000) || Exe_opcode == 6'b001011) // sltu, sltiu
            ALU_Result = (Ainput < Binput) ? 1 : 0;
        //lui operation
        else if(Exe_opcode == 6'b001111)
            ALU_Result[31:0]= {Sign_extend[15:0], 16'h0000};
        //shift operation
        else if(Sftmd == 1)
            ALU_Result = Shift_Result;
        //other types of operation in ALU (arithmatic or logic calculation)
        else if(Jr == 1)
            ALU_Result = 0;
        else
            ALU_Result = ALU_output_mux[31:0];
    end

endmodule
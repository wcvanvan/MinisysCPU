`timescale 1ns / 1ps

module extender(Do_load,
                Do_signed,
                Do_Byte,
                Word_in,
                Extended_out
                );
    input Do_load;      // high for load, low for save
    input Do_signed;    // high for signed extend, low for unsigned extend
    input Do_Byte;      // high for Byte, low for Half word
    input[31:0] Word_in;// if load, from DMem, else save, from Reg
    output reg[31:0] Extended_out;
    
    
    always @(*) begin
        if (Do_load) begin
            if (Do_Byte) begin
                if (Do_signed) Extended_out <= {{24{Word_in[7]}}, Word_in[7:0]}; // signed Byte
                else Extended_out <= {24'h000_000, Word_in[7:0]}; // unsigned Byte
            end
            else begin
                if (Do_signed) Extended_out <= {{16{Word_in[15]}}, Word_in[15:0]}; // signed Half word
                else Extended_out <= {16'h0000, Word_in[15:0]}; // unsigned Half word
            end
        end
        else begin // save
            if (Do_Byte) begin
                Extended_out <= {4{Word_in[7:0]}};
            end
            else begin
                Extended_out <= {2{Word_in[15:0]}};
            end
        end
    end
endmodule


module new_dmem_address(Do_Byte, Address_in, Address_out, MemWrite);
    input Do_Byte;              // Byte or Half word   
    input[31:0] Address_in;
    output[31:0] Address_out;   // standardized address
    output reg[3:0] MemWrite;   // only for sh/sb, to DMem, for '.wea'

    assign Address_out = {Address_in[31:2], 2'b00};

    always @(*) begin
        case({Do_Byte, Address_in[1:0]}) 
            // Byte:
            3'b000   : MemWrite <= 4'b1000;
            3'b001   : MemWrite <= 4'b0100;
            3'b010   : MemWrite <= 4'b0010;
            3'b011   : MemWrite <= 4'b0001;
            //Half word:
            3'b100   : MemWrite <= 4'b1100;
            3'b110   : MemWrite <= 4'b0011;
            default  : MemWrite <= 4'b0000; // for invalid address
        endcase
    end
endmodule


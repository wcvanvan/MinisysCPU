module new_dmem_address(Do_Byte, Do_Half, Address_in, Address_out, MemWrite_ori, MemWrite);
    input Do_Byte;              // Byte
    input Do_Half;              // Halfword   
    input [31:0] Address_in;
    output [31:0] Address_out;   // standardized address
    output reg [3:0] MemWrite;   // only for sh/sb, to DMem, for '.wea'

    assign Address_out = {Address_in[31:2], 2'b00};

    always @(*) begin
        if (Do_Byte || Do_Half) begin // else  it's lw/sw
        case({Do_Byte, Do_Half, Address_in[1:0]})
            // Byte:
            3'b1000   : MemWrite <= 4'b1000;
            3'b1001   : MemWrite <= 4'b0100;
            3'b1010   : MemWrite <= 4'b0010;
            3'b1011   : MemWrite <= 4'b0001;
            //Halfword:
            3'b0100   : MemWrite <= 4'b1100;
            3'b0110   : MemWrite <= 4'b0011;
            default  : MemWrite <= 4'b0000; // for invalid address
        endcase
        end
        else begin // it's lw/sw
            MemWrite <= MemWrite_ori;
        end
    end
endmodule
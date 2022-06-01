`timescale 1ns / 1ps

module extender(Do_load,
                Do_signed,
                Do_Byte,
                Do_Half,
                Word_in,
                Extended_out
                );
    input Do_load;      // high for load, low for save
    input Do_signed;    // high for signed extend, low for unsigned extend
    input Do_Byte;      // high for Byte
    input Do_Half;      // high for Halfword
    input[31:0] Word_in;// if load, from DMem, else save, from Reg
    output reg[31:0] Extended_out;
    
    
    always @(*) begin
        if (Do_load) begin
            if (Do_Byte) begin
                if (Do_signed) Extended_out <= {{24{Word_in[7]}}, Word_in[7:0]}; // signed Byte
                else Extended_out <= {24'h000_000, Word_in[7:0]}; // unsigned Byte
            end
            else if (Do_Half) begin
                if (Do_signed) Extended_out <= {{16{Word_in[15]}}, Word_in[15:0]}; // signed Halfword
                else Extended_out <= {16'h0000, Word_in[15:0]}; // unsigned Halfword
            end
            else
                Extended_out <= Word_in;
        end
        else begin // save
            if (Do_Byte) begin
                Extended_out <= {4{Word_in[7:0]}};
            end
            else if (Do_Half) begin
                Extended_out <= {2{Word_in[15:0]}};
            end
            else
                Extended_out <= Word_in;
        end
    end
endmodule





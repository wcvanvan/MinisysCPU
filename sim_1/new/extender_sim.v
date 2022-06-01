`timescale 1ns / 1ps

module extender_sim(

    );
    reg [2:0] flag_in;
    reg [31:0] word_in;
    wire [31:0] out;
    extender ex(flag_in[2], flag_in[1], flag_in[0], word_in, out);
    
    initial begin
        word_in = 32'h1234_abcd;
        flag_in = 0;
        while (flag_in < 3'b111) begin
            #10 flag_in = flag_in + 1;
        end
    end
    
endmodule

`timescale 1ns / 1ps

module sh_sb_tb(

    );
    reg clock = 0;
//    reg [3:0] memWrite;
    reg  memWrite;
    reg [31:0] address;
    reg [31:0] writeData;
    wire [31:0] readData;
    Dmemory32 dmem(clock,memWrite,address,writeData,readData);
    always #10 clock = ~clock;
    initial begin
        address = 32'h0000_0010;
//        memWrite = 4'b1111;
        memWrite = 1;
        writeData = 32'habcd1234;
        #100
//        memWrite = 4'b1111;
        memWrite = 1;
        writeData = 32'h0000_0000;
        #100
//        memWrite = 4'b0011;
        memWrite = 0;
        writeData = 32'habcd1234;
        #100
        memWrite = 1;        
    end
    
endmodule

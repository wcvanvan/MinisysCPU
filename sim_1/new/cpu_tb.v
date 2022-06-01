`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2022/05/24 18:44:33
// Design Name:
// Module Name: cpu_tb
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


module cpu_tb();
    reg clk        = 1'b0;
    reg rst        = 1'b1;
    always #10 clk = ~clk;
    reg[23:0] io_rdata;
    wire[23:0] io_wdata;
    reg start_uart;
    wire rx;
    wire tx;
    initial begin
        #10000 rst = 1'b0;
        #5000 io_rdata = 32'b1000_0000_0000_0001_0000_0111;
                                                      //case
        #5000 io_rdata = 32'b0111_1111_000_00_0000_000_000;
        #5000 io_rdata = 32'b0000_0001_000_00_0001_000_000;
        #5000 io_rdata = 32'b0011_0010_000_00_0010_000_000;
        #5000 io_rdata = 32'b1000_1000_000_00_0011_000_000;
        #5000 io_rdata = 32'b0111_0111_000_00_0100_000_000;
        #5000 io_rdata = 32'b1100_0011_000_00_0101_000_000;
        #5000 io_rdata = 32'b0000_0000_000_00_0110_000_000;
        #5000 io_rdata = 32'b1101_1101_000_00_0111_000_000;
        #5000 io_rdata = 32'b0101_0011_000_00_1000_000_000;
        #5000 io_rdata = 32'b0000_0101_000_00_1001_000_000;

        #5000 io_rdata = 32'b1001_0011_000_00_0111_000_101;  // case 101
        
    end
    CPU cpu(
    .clk(clk),
    .fpga_rst(rst),
    .start_uart(start_uart),
    .rx(rx),
    .tx(tx),
    .io_rdata(io_rdata),
    .io_wdata(io_wdata)
    );
endmodule

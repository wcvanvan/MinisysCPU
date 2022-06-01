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
    reg start_uart = 0;
    wire rx;
    wire tx;
    initial begin
        #100000 rst = 1'b0;
        // {8 bits data,3 bits 0, 2 bits set_num, 4 bits index, 4 bits input place, 3 bits case}
        #1000000 io_rdata = 32'b0000_0010_000_00_0000_1111_000;
        #1000000 io_rdata = 32'b1000_0000_000_00_0000_0000_000;
        #1000000 io_rdata = 32'b0100_0000_000_00_0000_0001_000;
        // #5000000 io_rdata = 32'b0001_0000_000_00_0000_0010_000;
        // #5000000 io_rdata = 32'b0000_1000_000_00_0000_0011_000;
        // #5000000 io_rdata = 32'b0000_0010_000_00_0000_0100_000;
        // #5000000 io_rdata = 32'b0000_0001_000_00_0000_0101_000;
        // #5000000 io_rdata = 32'b0000_0011_000_00_0000_0110_000;
        // #5000000 io_rdata = 32'b1100_0000_000_00_0000_0111_000;

        #1000000 io_rdata = 32'b1100_0000_000_00_0000_0000_001;

        // #5000000 io_rdata = 32'b1100_0000_000_00_0000_0000_010;

        // #5000000 io_rdata = 32'b1100_0000_000_00_0000_0000_011;

        // #5000000 io_rdata = 32'b1100_0000_000_00_0000_0000_100;

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

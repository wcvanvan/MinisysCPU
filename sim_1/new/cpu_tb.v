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
    always #1 clk = ~clk;
    reg[23:0] io_rdata;
    wire[23:0] io_wdata;
    reg start_uart;
    wire rx;
    wire tx;
    initial begin
        #10000 rst = 1'b0;
//        #5000 io_rdata = 32'b1000_0000_0000_0001_0000_0111;
                                                      //case
        #10000 io_rdata = 32'b0000_1010_000_00_0000_1111_000;
        #10000 io_rdata = 32'b1110_1111_000_00_0000_0000_000;
        #10000 io_rdata = 32'b0000_0001_000_00_0000_0001_000;
        #10000 io_rdata = 32'b0011_0010_000_00_0000_0010_000;
        #10000 io_rdata = 32'b1000_1000_000_00_0000_0011_000;
        #10000 io_rdata = 32'b0111_0111_000_00_0000_0100_000;
        #10000 io_rdata = 32'b1100_0011_000_00_0000_0101_000;
        #10000 io_rdata = 32'b0000_0000_000_00_0000_0110_000;
        #10000 io_rdata = 32'b1101_1101_000_00_0000_0111_000;
        #10000 io_rdata = 32'b0101_0011_000_00_0000_1000_000;
        #10000 io_rdata = 32'b0000_0101_000_00_0000_1001_000;
        

          #10000 io_rdata = 32'b1001_0011_000_00_0111_0000_001;  // case 101
          #10000 io_rdata = 32'b1001_0011_000_00_0111_0000_010;  // case 101
          #10000 io_rdata = 32'b1001_0011_000_00_0111_0000_011;  // case 101
          #10000 io_rdata = 32'b1001_0011_000_00_0111_0000_100;  // case 101
          #10000 io_rdata = 32'b1001_0011_000_00_0111_0000_101;  // case 101
          #10000 io_rdata = 32'b1001_0000_000_01_0111_0000_110;  // case 101
          #10000 io_rdata = 32'b0000_0000_000_11_0011_0000_110;  // case 101
          #10000 io_rdata = 32'b0000_0000_000_00_0000_0000_111;  // case 101
          #10000 io_rdata = 32'b0000_0000_000_00_1001_0000_111;  // case 101
          
          
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
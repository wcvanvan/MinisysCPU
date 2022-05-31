`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2022/05/09 11:39:39
// Design Name:
// Module Name: dmemory32
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


module Dmemory32(input clock,
                 input memWrite,
                 input [31:0] address,
                 input [31:0] writeData,
                 output [31:0] readData,
                 input upg_rst_i,        // UPG reset (Active High)
                 input upg_clk_i,        // UPG clk_i (10MHz)
                 input upg_wen_i,        // UPG write enable
                 input [13:0] upg_adr_i, // UPG write address
                 input [31:0] upg_dat_i, // UPG write data
                 input upg_done_i);      // 1 if programming is finished);
    assign clk = !clock;
    
    /* CPU work on normal mode when kickOff is 1. CPU work on Uart communicate mode when kickOff is 0.*/
    wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);
    RAM ram (
    .clka (kickOff ? clk : upg_clk_i),
    .wea (kickOff ? memWrite : upg_wen_i),
    .addra (kickOff ? address[15:2] : upg_adr_i),
    .dina (kickOff ? writeData : upg_dat_i),
    .douta (readData)
    );
    
endmodule

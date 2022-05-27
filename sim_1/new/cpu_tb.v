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


module cpu_tb(

    );
    reg clk = 1'b0;
    reg rst = 1'b1;
    always #10 clk = ~clk;
    initial begin
        #50 rst = 1'b0;
    end;
    CPU cpu(
        .clk(clk),
        .rst(rst)
    );
endmodule

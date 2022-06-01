`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2022/05/25 19:58:12
// Design Name:
// Module Name: mem_or_io
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


module MemOrIO(mRead,
               mWrite,
               ioRead,
               ioWrite,
               addr_in,
               addr_out,
               m_rdata,
               io_rdata,
               r_wdata,
               r_rdata,
               data_to_dmem_or_io);
    
    input mRead; // read memory, from Controller
    input [3:0] mWrite; // write memory, from Controller
    input ioRead; // read IO, from Controller
    input ioWrite; // write IO, from Controller
    input[31:0] addr_in; // from alu_result in ALU
    output[31:0] addr_out; // address to Data-Memory
    input[31:0] m_rdata; // data read from Data-Memory
    input[23:0] io_rdata; // data read from IO,16 bits
    output [31:0] r_wdata; // data to register
    input[31:0] r_rdata; // data read from register
    output reg[31:0] data_to_dmem_or_io;
    
    assign addr_out = addr_in;
    // The data write to register may be from memory or io.
    // While the data is from io, it should be the lower 16bit of r_wdata.
    assign r_wdata = (mRead == 1'b1) ? m_rdata : {8'b0, io_rdata};
    // Chip select signal of Led and Switch are all active high;
    
    always @(*) begin
        if ((mWrite != 4'b0000)||(ioWrite == 1)) begin
            data_to_dmem_or_io = r_rdata;
            end
        else begin
            data_to_dmem_or_io = 32'hZZZZZZZZ;
        end
    end
        
        endmodule

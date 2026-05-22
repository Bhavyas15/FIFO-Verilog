`timescale 1ns / 1ps

module fifo_sync#(
  parameter depth=8,
  parameter width=32
)(
  input clk, rst_n,
  input wr_en, rd_en, 
  input [width-1:0] data_in,
  output reg [width-1:0] data_out,
  output empty,
  output full
);
  
// SV feature
//  localparam depth_log=$clog2(depth); // number of bits to represent depth
    localparam depth_log=2; // change according to TB depth
  // not subtract one, to keep account of 'full'
  
  reg [width-1:0] mem [depth-1:0];
  
  reg [depth_log:0] wr_ptr, rd_ptr;
  
  //Write
  always @(posedge clk or negedge rst_n) begin 
    if(!rst_n) wr_ptr<=0;
    else if (wr_en && !full) begin 
      mem[wr_ptr[depth_log-1:0]]<=data_in;
      wr_ptr <= wr_ptr+1'b1;
    end
  end 
  
  //Read
  always @(posedge clk or negedge rst_n) begin 
    if(!rst_n) rd_ptr<=0;
    else if (rd_en && !empty)begin 
      data_out <= mem[rd_ptr[depth_log-1:0]];
      rd_ptr <= rd_ptr+1'b1;
    end
  end 
  
  assign empty = (rd_ptr==wr_ptr);
  assign full = ( rd_ptr[depth_log]!=wr_ptr[depth_log] && rd_ptr[depth_log-1:0]==wr_ptr[depth_log-1:0]);
endmodule

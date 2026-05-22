`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.05.2026 17:51:09
// Design Name: 
// Module Name: tb_async
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


module tb_fifo_async(
    );
    parameter depth = 4;
    parameter width = 8;

    reg wr_clk, rd_clk;
    reg wr_rst_n, rd_rst_n;
    reg wr_en, rd_en;
    reg [width-1:0] wr_data;
    wire [width-1:0] rd_data;
    wire wr_full, rd_empty;
    
    integer i;
    integer j;

    fifo_async #(
        .depth(depth),
        .width(width)
    ) uut (
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .wr_full(wr_full),
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .rd_empty(rd_empty)
    );

    // Write clock: 100 MHz
    initial begin
        wr_clk = 0;
        forever #5 wr_clk = ~wr_clk;
    end

    // Read clock: 66 MHz (slower)
    initial begin
        rd_clk = 0;
        forever #7.5 rd_clk = ~rd_clk;
    end

    // Test
    initial begin
        $display("Asynchronous FIFO Test");
        $display("======================");
        $display("Write Clock: 100 MHz, Read Clock: 66 MHz");

        wr_rst_n = 0; rd_rst_n = 0;
        wr_en = 0; rd_en = 0; wr_data = 0;
        #50;
        wr_rst_n = 1; rd_rst_n = 1;
        #20;

//        Sequential operations -
        $display("\n** Fast writer, slow reader **\n");

        for(i=0;i<depth+2;i=i+1) begin
            @(posedge wr_clk)
            wr_en=1;
            wr_data=i;
        end 
        wr_en=0;
        for(i=0;i<depth+1;i=i+1) begin
            @(posedge rd_clk)
            rd_en=1;
        end 
        rd_en=0; 

//        Simultaneous operations - 
        fork
            begin : writer
                for (i = 0; i < 12; i=i+1) begin
                    @(posedge wr_clk);
                    wr_en = 1;
                    wr_data = i;
                    #1;
                    $display("T=%0t WR: data=0x%h, full=%b",
                             $time, wr_data, wr_full);
                end
                wr_en = 0;
            end

            begin : reader
//                #40;  // Delay reader start
                for (j = 0; j < 12; j=j+1) begin
                    @(posedge rd_clk);
                    rd_en = 1;
//                    #1;
                    $display("T=%0t RD: data=0x%h, empty=%b",
                             $time, rd_data, rd_empty);
                end
                rd_en = 0;
            end
        join
        
        #100 $finish;
    end
endmodule

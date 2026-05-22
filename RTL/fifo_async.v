`timescale 1ns / 1ps

// with gray coide pointers for CDC
module fifo_async #(
    parameter depth=8,
    parameter width=32
    )(
        // Write clock domain
        input wire wr_clk,
        input wire wr_rst_n,
        input wire wr_en,
        input wire [width-1:0] wr_data,
        output wire wr_full,
    
        // Read clock domain
        input wire rd_clk,
        input wire rd_rst_n,
        input wire rd_en,
        output reg [width-1:0] rd_data,
        output wire rd_empty
    );
    
//    localparam ADDR_WIDTH = $clog2(DEPTH);
    localparam ADDR_WIDTH=2;
    localparam PTR_WIDTH = ADDR_WIDTH + 1;

    // Memory (accessible from both domains)
    reg [width-1:0] mem [0:depth-1];

    // Binary pointers (in respective clock domains)
    reg [PTR_WIDTH-1:0] wr_ptr_bin, rd_ptr_bin;

    // Gray code pointers (for synchronization)
    reg [PTR_WIDTH-1:0] wr_ptr_gray, rd_ptr_gray;

    // Synchronized Gray pointers
    reg [PTR_WIDTH-1:0] wr_ptr_gray_sync1, wr_ptr_gray_sync2;
    reg [PTR_WIDTH-1:0] rd_ptr_gray_sync1, rd_ptr_gray_sync2;

    // Binary to Gray conversion
    function [PTR_WIDTH-1:0] bin2gray;
        input [PTR_WIDTH-1:0] bin;
        begin
            bin2gray = bin ^ (bin >> 1);
        end
    endfunction
    
    // Gray to Binary conversion
        function [PTR_WIDTH-1:0] gray2bin;
            input [PTR_WIDTH-1:0] gray;
            integer i;
            begin
                gray2bin[PTR_WIDTH-1] = gray[PTR_WIDTH-1];
                for (i = PTR_WIDTH-2; i >= 0; i = i - 1)
                    gray2bin[i] = gray2bin[i+1] ^ gray[i];
            end
        endfunction
    
    //========================================
    // Write Clock Domain
    //========================================

    // Synchronize read pointer to write clock domain
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            rd_ptr_gray_sync1 <= 0;
            rd_ptr_gray_sync2 <= 0;
        end else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end
    
    // Write pointer management
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_ptr_bin <= 0;
            wr_ptr_gray <= 0;
        end else if (wr_en && !wr_full) begin
            wr_ptr_bin <= wr_ptr_bin + 1;
            wr_ptr_gray <= bin2gray(wr_ptr_bin + 1);
        end
    end
    
    // Write to memory
    always @(posedge wr_clk) begin
        if (wr_en && !wr_full)
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;
    end
    
    // Full flag generation
    wire [PTR_WIDTH-1:0] rd_ptr_bin_sync = gray2bin(rd_ptr_gray_sync2);
    assign wr_full = (wr_ptr_bin[PTR_WIDTH-1] != rd_ptr_bin_sync[PTR_WIDTH-1]) &&
                     (wr_ptr_bin[PTR_WIDTH-2:0] == rd_ptr_bin_sync[PTR_WIDTH-2:0]);
    
    //========================================
    // Read Clock Domain
    //========================================

    always @(posedge rd_clk or negedge rd_rst_n) begin 
        if(!rd_rst_n) begin 
            wr_ptr_gray_sync1 <=0;
            wr_ptr_gray_sync2 <=0;
        end 
        else begin 
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        end 
    end 
    
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if(!rd_rst_n) begin
            rd_ptr_bin <=0;
            rd_ptr_gray <=0;
        end 
        else if (rd_en && !rd_empty) begin
            rd_ptr_bin <= rd_ptr_bin+1;
            rd_ptr_gray <= bin2gray(rd_ptr_bin+1);
        end 
    end 
    
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if(!rd_rst_n)
            rd_data <= 0;
        else if (rd_en && !rd_empty)
            rd_data <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
    end 
    
    wire [PTR_WIDTH-1:0] wr_ptr_bin_sync = gray2bin(wr_ptr_gray_sync2);
    assign rd_empty = (rd_ptr_bin == wr_ptr_bin_sync);

endmodule

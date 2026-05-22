`timescale 1ns / 1ps

module tb_fifo_sync(
    );
     parameter depth=4;
     parameter width=16;
     reg clk=0;
     reg rst_n;
     reg wr_en, rd_en;
     reg [width-1:0] data_in;
     wire [width-1:0] data_out;
     wire empty,full;
           
     integer i;
     
     fifo_sync #(
       .depth(depth), 
       .width(width)
     ) dut(
       .clk(clk), 
       .rst_n(rst_n),
       .wr_en(wr_en),
       .rd_en(rd_en),
       .data_in(data_in),
       .data_out(data_out), 
       .empty(empty),
       .full(full)
     );
   
     always begin #5 clk=~clk; end 
   
      task read_data();
        begin 
          @(posedge clk);
          rd_en=1;
          @(posedge clk);
          $display($time, "read_data data_out= %0d",data_out);
          rd_en=0;
        end 
      endtask
   
      task write_data(input [width-1:0] din);
        begin 
          @(posedge clk);
          wr_en=1;
          data_in=din;
          @(posedge clk);
          $display($time, "written_data data_in= %0d",data_in);
          wr_en=0;
        end 
      endtask
      
     // Create stimulus 
     initial begin 
       rst_n=0; rd_en=0; wr_en=0;
   
       @(posedge clk)
       rst_n=1;
       
       $display("Scenario 1");
       write_data(1);
       write_data(10);
       write_data(100);
       read_data();
       read_data();
       read_data();
   
       $display("Scenario 2");
       for (i=0;i<depth;i=i+1) begin 
         write_data(2**i);
         read_data();
       end
   
       $display("Scenario 3");
       for (i=0;i<depth;i=i+1) begin 
         write_data(2**i);
       end
       for (i=0;i<depth;i=i+1) begin 
         read_data();
       end
       
       $display("Scenario 4");
       //Read from memory empty 
       read_data();
       read_data();
       
       // over writing when filled already;
       for (i=0;i<=depth+1;i=i+1) begin 
         write_data(2**i);
       end
       for (i=0;i<=depth+1;i=i+1) begin 
         read_data();
       end

    $display("Scenario 5");
       //Read from empty 
       write_data(10);
       write_data(20);
       read_data();
       read_data();
       read_data();
       write_data(30);
       read_data();
       
       #10;
       $finish;
     end 
endmodule

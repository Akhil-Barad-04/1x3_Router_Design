module router_sync_tb();

    wire [2:0]write_enb;
    wire fifo_full,vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2;

    reg [1:0]data_in;

    reg clock,resetn,detect_add,write_enb_reg;
    reg full_0,full_1,full_2,empty_0,empty_1,empty_2,read_enb_0,read_enb_1,read_enb_2;

    reg [1:0]temp_data_in;
    reg [5:0]count_0,count_1,count_2;

    router_sync DUT(write_enb,fifo_full,vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2,clock,resetn,data_in,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2);

   always  begin
       clock=1'b0;
       forever # 5 clock=~clock;
   end 

   task resetnip;
    begin
      @(negedge clock)
      resetn=1'b0;
      @(negedge clock)
      resetn=1'b1;
    end
    endtask

    task initialize;
        begin
          {data_in,detect_add,full_0,full_1,full_2,read_enb_0,read_enb_1,read_enb_2,write_enb_reg}=10'd0;
          {empty_0,empty_1,empty_2}=3'b111;
        end
    endtask

    task data_i(input [1:0]i);
        begin
          @(negedge clock)
          data_in<=i;
        end
    endtask

    task full_in(input [2:0]j);
        begin
          {full_0,full_1,full_2}=j;
        end
    endtask

    task empty_in(input [2:0]k);
        begin
          {empty_0,empty_1,empty_2}=k;
        end
    endtask

    task read_enb_in(input [2:0]l);
        begin
          {read_enb_0,read_enb_1,read_enb_2}=l;
        end
    endtask

    task detect_add_in;
        begin
          @(negedge clock)
          detect_add=1'b1;
          @(negedge clock)
          detect_add=1'b0;
        end
    endtask

    initial begin
        resetnip;
        initialize;
        data_i(10);
        detect_add_in;
        #20;
        write_enb_reg=1'b1;
        full_in(3'b000);
        #10;
        full_in(3'b001);
        #10;
        full_in(3'b010);
        #10;
        full_in(3'b100);
        #10;
        empty_in(3'b111);
        #10;
        empty_in(3'b001);
        #10;
        empty_in(3'b100);
        #10;
        empty_in(3'b000);
        #300;

        data_i(10);
        detect_add_in;
        data_i(00);
        detect_add_in;
        full_in(3'b000);
        #10;
        full_in(3'b001);
        #10;
        full_in(3'b010);
        #10;
        full_in(3'b100);
        #10;

    end

    initial begin
        $monitor("write_enb=%b,fifo_full=%b,vld_out_0=%b,vld_out_1=%b,vld_out_2=%b,soft_reset_0=%b,soft_reset_1=%b,soft_reset_2=%b,clock=%b,resetn=%b,data_in=%b,detect_add=%b,full_0=%b,full_1=%b,full_2=%b,empty_0=%b,empty_1=%b,empty_2=%b,write_enb_reg=%b,read_enb_0=&b,read_enb_1=%b,read_enb_2=%b",write_enb,fifo_full,vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2,clock,resetn,data_in,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2);
    end

    initial begin
        #1500 $finish;
    end
endmodule
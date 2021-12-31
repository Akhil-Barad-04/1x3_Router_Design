module router_fifo_tb();

     parameter DATA_WIDTH = 8,
            DATA_DEPTH=16,
            DATA_ADDR=4;

    reg  clock,resetn,write_enb,read_enb,soft_reset,lfd_state;
    reg [7:0]data_in;

    wire [7:0]data_out;
    wire full,empty;

    reg [3:0]rd_pntr,wr_pntr;
    router_fifo DUT(data_out,full,empty,clock,resetn,soft_reset,data_in,write_enb,read_enb,lfd_state);


    reg[7:0]payload_data,parity,header;
    reg[5:0]payload_len;
    reg[1:0]addr;
    
    integer i,j,k;
    always 
        begin
            clock=1'b0;
            forever #5 clock=~clock;
        end

    task initialize;
        begin
          data_in<=8'h00;
          {read_enb,write_enb}=4'b00;
          {wr_pntr,rd_pntr}=8'h00;
          {soft_reset,lfd_state}=2'b00;
        end
    endtask

    task resetip;
        begin
          @(negedge clock)
          resetn=1'b0;
          @(negedge clock)
          resetn=1'b1;
        end
    endtask

    task soft_resetip;
        begin
          @(negedge clock)
          soft_reset=1'b1;
          @(negedge clock)
          soft_reset=1'b0;
        end
    endtask

    task write;
        begin
         
            
              @(negedge clock);
              fork
              payload_len=6'd12;
              addr=2'b01;
              lfd_state=1'b1;
              header[7:0]={payload_len,addr};
              join
              data_in[7:0]=header;
             
              write_enb=1;
              read_enb=0;

              for(k=0;k<payload_len;k=k+1)
              begin
                  @(negedge clock)
                    lfd_state=0;
                    payload_data=5*k;
                    data_in=payload_data;
                    #10;
              end
             
             @(negedge clock);
             parity={$random}%256;
             data_in=parity;
        end
    endtask

   

    task read_d;
        begin
          @(negedge clock)
          read_enb=1'b1;
          write_enb=1'b0;
          for (j =0 ;j<14;j=j+1 ) 
                begin
                rd_pntr=j;
                #10;
                end
        end
    endtask

    initial begin
        initialize;
        resetip;
        write;
        #30;
        read_d;
        #30;
        soft_resetip;
         write;
         #30;
         read_d;
	    
    end

    initial begin
        $monitor("resetn=%b,soft_reaet=%b,read_enb=%b,write_enb=%b,full=%b,empty=%b,wr_pntr=%d,rd_pntr=%d,f_e_Count=%d,counter=%b,data_in=%d,lft_state=%b,data_out=%d",resetn,soft_reset,read_enb,write_enb,full,empty,DUT.wr_pntr,DUT.rd_pntr,DUT.f_e_count,DUT.counter,data_in,lfd_state,data_out);
    end

    initial begin
        #500 $finish;
    end
endmodule
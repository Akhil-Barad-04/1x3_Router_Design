module router_fsm_tb();
    reg  clock,resetn,pkt_valid;
	reg [1:0] data_in;
	reg fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done, low_packet_valid;
	wire write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy;

    parameter  DECODE_ADDRESS	=	4'b0001,
			WAIT_TILL_EMPTY		=	4'b0010,
			LOAD_FIRST_DATA		=	4'b0011,
			LOAD_DATA			=	4'b0100,
			LOAD_PARITY			=	4'b0101,
			FIFO_FULL_STATE		=	4'b0110,
			LOAD_AFTER_FULL		=	4'b0111,
			CHECK_PARITY_ERROR	=	4'b1000;			  

    router_fsm DUT(clock,resetn,pkt_valid,data_in,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid,write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);

    always  begin
        clock=1'b0;
        forever #5 clock=~clock;
    end

    task resetnip;
        begin
          @(negedge clock);
          resetn=1'b0;
          @(negedge clock);
          resetn=1'b1;
        end
    endtask

   
    //DA-LFD-LD-LP-CPE-DA
    //1-3-4-5-8-1
    //Payload less than 14,full will never be high. Before full becomes high packet valid becomes zero/low,i.e end of the packet
    task task_1;
        begin
          @(negedge clock);
            pkt_valid=1'b1;
            data_in=2'b10;
            fifo_empty_2=1'b1;
            @(negedge clock);
            @(negedge clock);
            fifo_full=0;
            pkt_valid=0;
            @(negedge clock);
            @(negedge clock);
            fifo_full=1'b0;
        end
    endtask

    // DA-LDF-LD-FFS-LAF-LP-CPE-DA
    //1-3-4-6-7-5-8-1
    task task_2;
        begin
          @(negedge clock);
            pkt_valid=1'b1;
            data_in=2'b10;
            fifo_empty_2=1'b1;
            @(negedge clock);
            @(negedge clock);
            fifo_full=1'b1;
            @(negedge clock);
            fifo_full=1'b0;
            @(negedge clock);
            parity_done=1'b0;
            low_packet_valid=1'b1;
            @(negedge clock);
            @(negedge clock);
            fifo_full=1'b0;
        end
	endtask

    //DA-LFD-LD-FFS-LAF-LD-LP-CPE-DA
    //1-3-4-6-7-4-5-8-1
    //last data is not parity,,large packet
    task task_3;
        begin
            @(negedge clock)
            pkt_valid=1'b1;
            data_in=2'b10;
            fifo_empty_2=1'b1;
            @(negedge clock);
            @(negedge clock);
            fifo_full=1'b1;
            @(negedge clock);
            fifo_full=1'b0;
            @(negedge clock);
            low_packet_valid=1'b0;
            parity_done=1'b0;
            @(negedge clock);
            fifo_full=1'b0;
            pkt_valid=1'b0;
            @(negedge clock);
            @(negedge clock);
            fifo_full=1'b0;
        end
    endtask

    //DA-LFD-LD-LP-CPE-FFS-LAF-DA
    //1-3-4-5-8-6-7-1
    //This path is taken when payload is exactely 14 ,total no,of bytes=16
    task task_4;
        begin
            @(negedge clock);
            pkt_valid=1'b1;
            data_in=2'b10;
            fifo_empty_2=1'b1;
            @(negedge clock);
            @(negedge clock);
            fifo_full=1'b0;
            pkt_valid=1'b0;
            @(negedge clock);
            @(negedge clock);
            fifo_full=1'b1;
            @(negedge clock);
            fifo_full=1'b0;
            @(negedge clock);
            parity_done=1'b1;
        end
    endtask

    initial begin
        resetnip;
        #50;
        task_1;
        #20;
        resetnip;
        task_2;
        #20;
        resetnip;
        task_3;
        #20;
        resetnip;
         task_4;
    end

    initial
        begin
          $monitor("State=%d, write_enb_reg=%d,detect_add=%d,ld_state=%d,laf_state=%d,lfd_state=%d,full_state=%d,rst_int_reg=%d,busy=%d",DUT.present_state,write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);
        end

    initial begin
        #500 $finish;
    end
endmodule
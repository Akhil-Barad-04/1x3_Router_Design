module router_top(data_out_0,data_out_1,data_out_2,vld_out_0,vld_out_1,vld_out_2,error,busy,clock,resetn,read_enb_0,read_enb_1,read_enb_2,data_in,pkt_valid);

    output [7:0]data_out_0,data_out_1,data_out_2;
    output vld_out_0,vld_out_1,vld_out_2,error,busy;

    input clock,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid;
    input [7:0]data_in;


    wire [7:0]data_in_out;
    wire [2:0]write_enb;
		// Instantiating sub-modules
        // FIFO-0
        router_fifo FIFO_0(data_out_0,full_0,fifo_empty_0,clock,resetn,soft_reset_0,data_in_out,write_enb[0],read_enb_0,lfd_state);
        
        //FIFO-1
        router_fifo FIFO_1(data_out_1,full_1,fifo_empty_1,clock,resetn,soft_reset_1,data_in_out,write_enb[1],read_enb_1,lfd_state);
       
        //FIFO-2
        router_fifo FIFO_2(data_out_2,full_2,fifo_empty_2,clock,resetn,soft_reset_2,data_in_out,write_enb[2],read_enb_2,lfd_state);
        
        // Synchronizer
        router_sync SYNC(write_enb,fifo_full,vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2,clock,resetn,data_in,detect_add,full_0,full_1,full_2,fifo_empty_0,fifo_empty_1,fifo_empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2);
        
        //FSM controller
        router_fsm FSM(clock,resetn,pkt_valid,data_in,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done, low_packet_valid,write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);
        
        //Register
        router_reg REG(data_in_out,error,parity_done,low_packet_valid,clock,resetn,pkt_valid,data_in,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg);

    

endmodule
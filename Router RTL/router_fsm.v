module router_fsm(input clock,resetn,pkt_valid,
				  input [1:0] data_in,
				  input fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done, low_packet_valid, 
				  output write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);
				  
 parameter  DECODE_ADDRESS		=	4'b0001,
			WAIT_TILL_EMPTY		=	4'b0010,
			LOAD_FIRST_DATA		=	4'b0011,
			LOAD_DATA			=	4'b0100,
			LOAD_PARITY			=	4'b0101,
			FIFO_FULL_STATE		=	4'b0110,
			LOAD_AFTER_FULL		=	4'b0111,
			CHECK_PARITY_ERROR	=	4'b1000;
			
reg [3:0] present_state, next_state;
reg [1:0] temp;
wire temp_lfd_state;
//temp logic
always@(posedge clock)
	begin
		if(~resetn)
			temp<=2'b0;
		else if(detect_add != 2'b11)          // decides the address of out channel 
		 	temp<=data_in;
	end
// reset logic for states
always@(posedge clock)
	begin
		if(!resetn)
				present_state<=DECODE_ADDRESS;  // hard reset
		else if (((soft_reset_0) && (temp==2'b00)) || ((soft_reset_1) && (temp==2'b01)) || ((soft_reset_2) && (temp==2'b10)))		//if there is soft_reset and also using same channel so we do here and opertion
				 
				present_state<=DECODE_ADDRESS;

		else
				present_state<=next_state;
			
	end
//state machine logic 

always@(*)
	begin
		case(present_state)
		DECODE_ADDRESS:   // decode address state 
		    begin
			    if((pkt_valid && (data_in==2'b00) && fifo_empty_0)|| (pkt_valid && (data_in==2'b01) && fifo_empty_1)|| (pkt_valid && (data_in==2'b10) && fifo_empty_2))

					next_state<=LOAD_FIRST_DATA;   //lfd_state

			    else if((pkt_valid && (data_in==2'b00) && !fifo_empty_0)||(pkt_valid && (data_in==2'b01) && !fifo_empty_1)||(pkt_valid && (data_in==2'b10) && !fifo_empty_2))
					next_state<=WAIT_TILL_EMPTY;  //wait till empty state
				
			    else 
				    next_state<=DECODE_ADDRESS;	   // same state
		    end

		LOAD_FIRST_DATA: 			// load first data state
		    begin	
			    next_state<=LOAD_DATA;
		    end

		WAIT_TILL_EMPTY:          //wait till empty state
		    begin
			    if((fifo_empty_0 && (temp==2'b00))||(fifo_empty_1 && (temp==2'b01))||(fifo_empty_2 && (temp==2'b10))) //fifo is empty and were using same fifo
					next_state<=LOAD_FIRST_DATA;
	
				else
					next_state<=WAIT_TILL_EMPTY;
			end

		LOAD_DATA:                        //load data
		    begin
			    if(fifo_full==1'b1) 
					next_state<=FIFO_FULL_STATE;
			    else 
					begin
						if (!fifo_full && !pkt_valid)
							next_state<=LOAD_PARITY;
						else
							next_state<=LOAD_DATA;
					end
		    end

		FIFO_FULL_STATE:			//fifo full state
			begin
				if(fifo_full==0)
					next_state<=LOAD_AFTER_FULL;
				else 
					next_state<=FIFO_FULL_STATE;
			end

		LOAD_AFTER_FULL:         	// load after full state
			begin
				if(!parity_done && low_packet_valid)
					next_state<=LOAD_PARITY;
				else if(!parity_done && !low_packet_valid)
					next_state<=LOAD_DATA;
	
				else 
					begin 
						if(parity_done==1'b1)
							next_state<=DECODE_ADDRESS;
						else
							next_state<=LOAD_AFTER_FULL;
					end
				
			end

		LOAD_PARITY:                 // load parity state
			begin
				next_state<=CHECK_PARITY_ERROR;
			end

		CHECK_PARITY_ERROR:			// check parity error
			begin
				if(!fifo_full)
					next_state<=DECODE_ADDRESS;
				else
					next_state<=FIFO_FULL_STATE;
			end

		default:					//default state
			next_state<=DECODE_ADDRESS; 

		endcase									// state machine completed
	end

// output logic

assign detect_add=((present_state==DECODE_ADDRESS))?1:0;
assign busy=((present_state==LOAD_FIRST_DATA)||(present_state==LOAD_PARITY)||(present_state==FIFO_FULL_STATE)||(present_state==LOAD_AFTER_FULL)||(present_state==WAIT_TILL_EMPTY)||(present_state==CHECK_PARITY_ERROR))?1:0;

assign lfd_state=(temp_lfd_state)?1:0;
assign temp_lfd_state=((present_state==LOAD_FIRST_DATA))?1:0;  //1 clock cycle delay

assign ld_state=((present_state==LOAD_DATA))?1:0;
assign write_enb_reg=((present_state==LOAD_DATA)||(present_state==LOAD_AFTER_FULL)||(present_state==LOAD_PARITY))?1:0;
assign full_state=((present_state==FIFO_FULL_STATE))?1:0;
assign laf_state=((present_state==LOAD_AFTER_FULL))?1:0;
assign rst_int_reg=((present_state==CHECK_PARITY_ERROR))?1:0;

endmodule
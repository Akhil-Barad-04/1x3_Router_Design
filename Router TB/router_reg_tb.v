module router_reg_tb();

    reg clock,resetn,pkt_valid;
    reg [7:0]data_in;
    reg fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg;

    wire err,parity_done,low_packet_valid;
    wire [7:0]data_out;

    integer i;

    router_reg DUT(data_out,err,parity_done,low_packet_valid,clock,resetn,pkt_valid,data_in,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg);

    initial begin
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

   task data_in_14;
			reg [7:0]header_byte, payload_data, parity;
			reg [5:0]payloadlen;
			begin
				@(negedge clock);
				begin
					payloadlen=14;
					parity=0;
					detect_add=1'b1;
					pkt_valid=1'b1;
					header_byte={payloadlen,2'b10};
					data_in=header_byte;
					parity=parity^data_in;
				end
				@(negedge clock);
				begin
					detect_add=1'b0;
					lfd_state=1'b1;
				end
				for(i=0;i<payloadlen;i=i+1)	
					begin
					@(negedge clock);	
						begin
						lfd_state=0;
						ld_state=1;
						fifo_full=1'b0;
						payload_data=5*i;
						//payload_data={$random}%256;
						data_in=payload_data;
          				parity=parity^data_in;				
						end
					end
					@(negedge clock);
					begin	
						pkt_valid=1'b0;
						data_in=parity;
					end
					@(negedge clock);
					ld_state=0;
					parity=8'd0;
			end
		endtask

		

       task data_in_16;
			reg [7:0]header_byte, payload_data, parity;
			reg [5:0]payloadlen;
			begin
				@(negedge clock);
				payloadlen=16;
				parity=0;
				detect_add=1'b1;
				pkt_valid=1'b1;
				header_byte={payloadlen,2'b10};
				data_in=header_byte;
				parity=parity^data_in;

				@(negedge clock);
				detect_add=1'b0;
				lfd_state=1'b1;
		
				for(i=0;i<payloadlen-2;i=i+1)	
					begin
					@(negedge clock);	
					lfd_state=0;
					ld_state=1;
	
					payload_data={$random}%256;
					data_in=payload_data;
          
					parity=parity^data_in;				
					end
					@(negedge clock);
					fifo_full=1'b1;
					ld_state=1'b1;
					payload_data=8'd140;
					data_in=payload_data;
					laf_state=1'b1;
					pkt_valid=1'b0;
					@(negedge clock);
					payload_data=8'd150;
					data_in=payload_data;

					@(negedge clock);	
					pkt_valid=1'b0;
					data_in=8'd20;
				
					@(negedge clock);
					ld_state=0;
					end

      endtask

      initial begin
        resetnip;
        fifo_full=1'b0;
        laf_state=1'b0;

        #50;
        data_in_14;
		#50;
        resetnip;
        data_in_16;
      end

    initial begin
      #700 $finish;
    end
endmodule
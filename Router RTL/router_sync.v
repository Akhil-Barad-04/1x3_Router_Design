module router_sync(write_enb,fifo_full,vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2,clock,resetn,data_in,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2);

    output reg [2:0]write_enb;
    output vld_out_0,vld_out_1,vld_out_2;
    output reg fifo_full,soft_reset_0,soft_reset_1,soft_reset_2;

    input [1:0]data_in;

    input clock,resetn,detect_add,write_enb_reg;
    input full_0,full_1,full_2,empty_0,empty_1,empty_2,read_enb_0,read_enb_1,read_enb_2;

    reg [1:0]temp_data_in;
    reg [5:0]count_0,count_1,count_2;


    assign vld_out_0=~empty_0;
    assign vld_out_1=~empty_1;
    assign vld_out_2=~empty_2;
    
    //data_in
    always @(posedge clock) begin
        if(!resetn) begin
          temp_data_in<=2'b0;
        end
        else if (detect_add) begin
          temp_data_in<= data_in;
        end
    end

    //write enable
    always @(*) begin
        if (!resetn) begin
            write_enb<=3'b000;
        end
        else if(write_enb_reg) 
            begin
                case(temp_data_in)
                    2'b00: write_enb=3'b001;
                    2'b01: write_enb=3'b010;
                    2'b10: write_enb=3'b100;
                    2'b11: write_enb=3'b000;
                default write_enb=3'b000;
                endcase
            end
        else 
        write_enb=3'b000;
    end

    //fifo operation
    always @(*) begin
        if(!resetn) begin
          fifo_full=1'b0;
            end
        else 
            begin
                case(temp_data_in)
                2'b00: fifo_full=full_0;
                2'b01: fifo_full=full_1;
                2'b10: fifo_full=full_2;
                2'b11: fifo_full=1'b0;
                default fifo_full=1'b0; 
            endcase
            end

    end

    
    //soft reset counter 
    // counter 0
    always@(posedge clock)
	    begin
		if(!resetn)
			count_0<=5'b0;
		else if(vld_out_0)
			begin
				if(!read_enb_0)
					begin
						if(count_0==5'b11110)	
							begin
								soft_reset_0<=1'b1;
								count_0<=1'b0;
							end
						else
							begin
								count_0<=count_0+1'b1;
								soft_reset_0<=1'b0;
							end
					end
				else 
                count_0<=5'd0;
			end
		else 
        count_0<=5'd0;
	end

	//counter 1
    always@(posedge clock)
	    begin
		if(!resetn)
			count_1<=5'b0;
		else if(vld_out_1)
			begin
				if(!read_enb_1)
					begin
						if(count_1==5'b11110)	
							begin
								soft_reset_1<=1'b1;
								count_1<=1'b0;
							end
						else
							begin
								count_1<=count_1+1'b1;
								soft_reset_1<=1'b0;
							end
					end
				else 
                count_1<=5'd0;
			end
		else 
        count_1<=5'd0;
	end
	//counter 2
    always@(posedge clock)
	    begin
		if(!resetn)
			count_2<=5'b0;
		else if(vld_out_2)
			begin
				if(!read_enb_2)
					begin
						if(count_2==5'b11110)	
							begin
								soft_reset_2<=1'b1;
								count_2<=1'b0;
							end
						else
							begin
								count_2<=count_2+1'b1;
								soft_reset_2<=1'b0;
							end
					end
				else 
                count_2<=5'd0;
			end
		else 
        count_2<=5'd0;
	end
	
endmodule
module router_fifo(data_out,full,empty,clock,resetn,soft_reset,data_in,write_enb,read_enb,lfd_state);

    parameter DATA_WIDTH = 9,
            DATA_DEPTH=16,
            DATA_ADDR=4;

    input clock,resetn,write_enb,read_enb,soft_reset,lfd_state;
    input [7:0]data_in;

    output reg [7:0]data_out;
    output full,empty;
	reg temp;
	integer i;
    reg [3:0]rd_pntr,wr_pntr;
    //counters the no.of write and read signals
    reg [4:0]f_e_count;
    // counters the no.of payloads and parity
    reg [5:0]counter;

    
    reg [8:0] mem [0:15];

    assign full = (f_e_count==5'b10000);
    assign empty =(f_e_count ==5'b00000);
    


    always @(posedge clock ) begin
        if (!resetn) begin
            temp<=1'b0;
        end
        else if (soft_reset) begin
            temp<=1'b0;
        end
        else
            temp<=lfd_state;
    end
    //write pointer and read pointer logic

    always @(posedge clock)
        begin
            if(!resetn)
            wr_pntr<=4'b0000;
            else if (soft_reset)
            wr_pntr<=4'b0000;
            else if (write_enb==1 && full == 0)
            wr_pntr<=wr_pntr+1'b1;
            else 
            wr_pntr<=wr_pntr;
        end

    always @(posedge clock) 
        begin
            if(!resetn)
            rd_pntr<=4'b0000;
            else if (soft_reset)
            rd_pntr<=4'b0000;
            else if (read_enb==1 && empty == 0)
            rd_pntr<=rd_pntr+1'b1;
            else 
            rd_pntr<=rd_pntr;
            end
    // write operation
    always @(posedge clock ) begin
        if (!resetn) begin
            for (i =0 ;i<16 ;i=i+1 ) begin
               mem[i]<=0; 
            end
        end
        else if (soft_reset) begin
            for (i =0 ;i<16 ;i=i+1 ) begin
               mem[i]<=0; 
            end
        end
        else if(write_enb==1 && full==0)
                begin
                    mem[wr_pntr]<={temp,data_in[7:0]};
                end
        else
            mem[wr_pntr]<=mem[wr_pntr];   
        end

    // read operation
    always @(posedge clock) begin
        if (!resetn) begin
            data_out<=8'h00;
        end
        else if (soft_reset) 
            begin
                data_out<=8'hz;
            end
        else
            if(counter==6'b000000) begin
                data_out<=9'bz;
              end
            else if(read_enb==1 && empty==0) begin
                    data_out<=mem[rd_pntr];
                end
        end 

    // counterer operation for full and empty
    always @(posedge clock) begin
        if (!resetn) 
            begin
            f_e_count<=5'b00000;
            end
        else if (soft_reset) 
            begin
            f_e_count<=5'b00000;
            end 
        else 
            begin
            case({write_enb,read_enb})
            2'b10:if (f_e_count != DATA_DEPTH) 
                    begin
                        f_e_count<=f_e_count+1;              
                    end
            2'b01:if (f_e_count != 5'b00000) 
                    begin
                        f_e_count<=f_e_count-1;              
                    end
            2'b00:f_e_count<=f_e_count;
            2'b11:f_e_count<=f_e_count;

            default : f_e_count<=f_e_count;
          endcase
        end
    end

    always@(posedge clock)
    begin 
      //check the msb value of data  and if its 1 its a header and then take payload length+1  as count(1st bit for header; last 2 bits for address)
        if(mem[rd_pntr][8] && read_enb && ~empty)
            counter<=mem[rd_pntr][7:2]+1;
        
      //decrement value until count becomes zero or until count is a non zero value
        else if((counter!=0) && read_enb && ~empty)
        counter<=counter-1;
        else 
        counter<=counter;
    end

endmodule
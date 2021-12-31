module router_top_tb();

    reg clock,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid;
    reg [7:0]data_in;

    wire [7:0]data_out_0,data_out_1,data_out_2;
    wire vld_out_0,vld_out_1,vld_out_2,error,busy;

    integer i;

    router_top DUT(data_out_0,data_out_1,data_out_2,vld_out_0,vld_out_1,vld_out_2,error,busy,clock,resetn,read_enb_0,read_enb_1,read_enb_2,data_in,pkt_valid);

    always begin
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

    task packet_gen_14;
        reg [7:0]payload_data,parity,header;
        reg [5:0]payload_len;
        reg [1:0]addr;
            begin
                @(negedge clock);
                payload_len=6'd14;
                addr=2'b00;    // valid packet
                header={payload_len,addr};
                parity=0;
                data_in=header;
                pkt_valid=1;
                parity=parity^header;

                @(negedge clock);
                wait(~busy)
                    for (i =0;i<payload_len ;i=i+1 ) begin
                        @(negedge clock);
                        wait(~busy)
                            payload_data={$random}%256;
                            data_in=payload_data;
                            parity=parity^payload_data;
                    end

                @(negedge clock);
                wait(~busy)
                pkt_valid=0;
                data_in=parity;
            end
    endtask

    task packet_gen_16;
        reg [7:0]payload_data,parity,header;
        reg [5:0]payload_len;
        reg [1:0]addr;
            begin
                @(negedge clock);
                payload_len=6'd16;
                addr=2'b10;    // valid packet
                header={payload_len,addr};
                parity=0;
                data_in=header;
                pkt_valid=1;
                parity=parity^header;

                @(negedge clock);
                wait(~busy)
                    for (i =0;i<payload_len ;i=i+1 ) begin
                        @(negedge clock);
                        wait(~busy)
                            payload_data={$random}%256;
                            data_in=payload_data;
                            parity=parity^payload_data;
                    end

                @(negedge clock);
                wait(~busy)
                pkt_valid=0;
                data_in=parity;
            end
    endtask

    initial begin
        resetnip;
        read_enb_0=1'b0;
        read_enb_1=1'b0;
        read_enb_2=1'b0;
        #10;
        packet_gen_14;
        #10;
        read_enb_0=1'b1;
        #180;
        read_enb_0=1'b0;
        read_enb_1=1'b0;
        read_enb_2=1'b0;
        #10;
        packet_gen_16;
        #10;
        read_enb_2=1'b1;
        #200;

        resetnip;
    end

    initial begin
        #800 $finish;
    end

    initial begin
        $monitor("resetn = %d ,read_enb_0 = %d ,read_enb_1 = %d ,read_enb_2 = %d ,pkt_valid = %d ,data_in = %d ,data_out_0 = %d ,data_out_1 = %d ,data_out_2 = %d ,vld_out_0 = %d ,vld_out_1 = %d ,vld_out_2 = %d ,error = %d ,busy = %d",resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid,data_in,data_out_0,data_out_1,data_out_2,vld_out_0,vld_out_1,vld_out_2,error,busy);
    end
    
endmodule
module time_counter (
        input   logic           rst,
        input   logic           clk,
        input   reg             strob,
        output  reg[31:0]       period,
	output  reg             ready
);
    reg[31:0]  tm0;
    reg [31:0] tm1;
    reg [31:0] time_out;

   // reg check_time;


    always_ff@(posedge clk or posedge rst)
    begin
            if(rst)
            begin
                    tm0 <= '0;
                    time_out <= 32'hffffffff;
		    tm1 <= '0;
		    period <= 32'hffffffff;
		    ready <= '0;

            end
            else
            begin
	        if (tm1 == 32'd250000)
		begin
		  	  period <= time_out;
			  ready <= '1;
			  tm1 <= '0;
		end else
		begin
			ready <= '0;
			tm1 <= tm1 + 1'd1;
		end

		if (tm0 < 32'd25000000)
	              tm0 <= tm0 + 1'd1;
	        else
			time_out <= 32'hffffffff;

                if (strob) 
                begin
			if(time_out == 32'hffffffff)
				time_out <= tm0;
			else
                                time_out <=( (tm0+ time_out)>>1);
                        tm0 <= '0;
                end

           end 
    end

endmodule

module time_counter (
        input   logic           rst,
        input   logic           clk,
        input   reg             strob,
        output  reg[31:0]       period,

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
                    time_out <= '0;
		    tm1 <= '0;
		    period <= '0;

            end
            else
                 begin
		tm1 <= tm1 + 1'd1;

		if (tm0 < 32'd25000500)
	              tm0 <= tm0 + 1'd1;

                      if (strob) 
                      begin
                          time_out <=( (tm0+ time_out)>>1);
                          tm0 <= '0;
                      end

	              if (tm1 == 32'd250000)
			begin
		  	  period <= time_out;
			  tm1 <= '0;
			end

          	 end 
    end

endmodule

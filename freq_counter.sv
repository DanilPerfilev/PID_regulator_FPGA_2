module freq_counter (
        input   logic           rst,
        input   logic           clk,
        input   reg             strob,
        output  reg[31:0]        freq_out,
	output  reg              ready
       
);
    reg[31:0]  tm0;
    reg [31:0] cnt_sgn;

    always_ff@(posedge clk or posedge rst)
    begin
            if(rst)
            begin
		    tm0 <= '0;
		    freq_out <= '0;
                    ready <= '0;
            end
            else
        begin
	     if (strob)
                    cnt_sgn <= cnt_sgn + 1'd1;

            if (tm0 == '0)
		   ready <= '0;

	    tm0 <= tm0+1'd1;
	     

             if(tm0 == 32'd250000)
	     begin	     
	       freq_out <= (((cnt_sgn) + freq_out)>>1);
               ready <= '1;
               tm0 <= '0;
	       cnt_sgn <= '0;
	     end
        end     
    end
endmodule



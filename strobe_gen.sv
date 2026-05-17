module strobe_gen (
        input   logic           rst,
        input   logic           clk,
        input   logic           signal_input,
        output  reg          strob_front,
        output  reg           strob_back,
);
    reg  signal_prev;

    always_ff@(posedge clk or posedge rst)
    begin
            if(rst)
	    begin	    
                    signal_prev <= '0;
	            strob_front <= '0;
                    strob_back <= '0;
	    end
            else
	begin
                    signal_prev <= signal_input;
                    strob_front <= (signal_input && ~signal_prev);
                    strob_back <= (~signal_input && signal_prev);
        end
    end
endmodule


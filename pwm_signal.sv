module pwm (
        input   logic           rst,
        input   logic           clk,
	input   reg [7:0]       duty,
	output  reg             pwm_out
);

    localparam w_cnt1 = $clog2(25*1000*1000);
    reg [w_cnt1-1:0] clk_div;
    reg pwm_clk = clk_div [10];
    reg [7:0] cnt;
    


    always_ff @ (posedge clk or posedge rst)
        if (rst)
            clk_div <= '0;
        else
           clk_div <= clk_div+ 1'd1;

    always_ff @ (posedge pwm_clk or posedge rst)
    begin
	if (rst)
            cnt <= '0;
        else
	   begin	
                cnt<=cnt+8'd1;
		if (cnt < duty)
		   pwm_out <= '1;
                if (cnt > duty)
	           pwm_out <= '0;		
            end
    end

endmodule

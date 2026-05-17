module top (
        input   logic           clk25,
        input   logic [3:0]     key,
        inout   logic [15:0]     gpio,
        output  logic [3:0]     led,

);
        localparam izm = 8'd1; 
        wire rst;
        assign rst = key[3];
        reg[15:0]  pwm_out;
	reg [15:0] pwm_top;
        reg [31:0] remainder_f;
        reg [15:0] result;
        reg [31:0] result_f;
	reg [31:0] remainder;
	reg [15:0] cnt_pwm;
	reg signed [15:0] pid_isp;
	reg [25:0] clk_div;
	reg [15:0] pid_voz;
	reg valid_PID;
	reg [15:0] integral_isp;
	reg [15:0] error_isp;
	reg [7:0] pid_norm;
	reg pwm_out;
	
	

       logic [31:0] display_out = {pwm_top[7:0], pid_isp[15:0], result[7:0] };

        wire key0_strob_front;
        wire key0_strob_back;
        wire key1_strob_front;
        wire key1_strob_back;
        wire gpio_strob_back;
        wire gpio_strob_front;
	wire pid_strob_front;

        reg [3:0] cnt_strob1;
        reg [31:0] time_out;
	reg [31:0] time_del;
	reg [31:0] isp_pdd = 32'd1 ;
	reg ready_freq;
	reg ready_dev;
	reg valid_time;
        logic [1:0] cmd={key[1],key[0]};
        reg cmd_clk = clk_div [22];
	


    always_ff @ (posedge clk25 or posedge rst)
        if (rst)
            clk_div <= '0;
        else
           clk_div <= clk_div+ 1'd1;

/*	always_ff@(posedge clk25 or posedge rst)
            begin
                 if(rst)
                   begin
                       result_norm <= '0;
                       pwm_norm <= '0;

                   end
                 else
		 begin
	            result_norm <= result;	
	   	    if (ready_dev)
		        result <= result_f;
		    pwm_norm <= pwm_out>>8;

                 end          
	    end*/

    /*   always_ff @ (posedge cmd_clk or posedge rst)
        if (rst)
            pwm_top <='0;
        else begin
           case (cmd)
                2'b10: begin
                        if (pwm_top>=izm)
                             pwm_top<=pwm_top - izm;
                     else pwm_top<=8'd0;
                        end
                2'b01: begin
                        if (pwm_top<=(8'd255-izm))
                             pwm_top<=pwm_top + izm;
                     else pwm_top<=8'd255;
                        end
                2'b11: begin
                        pwm_top <= '0 ;
                        end
                default: begin
                        end

            endcase;
        end
*/

/*
  always_ff @ (posedge clk25 or posedge rst)
        if (rst)
            pid_norm <= '0;
        else begin
            if (pid_isp [15] == 1)
               pid_norm <= '0;
            else
		pid_norm <= (pid_isp << 4;*/
		   
function [7:0] saturate255 (input signed [15:0] raw);
if(raw > $signed('d255))
saturate255 = 'd255;
else if(raw < $signed('d0))
saturate255 = 'd0;
else
saturate255 = raw[7:0];
endfunction

assign pid_norm = saturate255(pid_isp);







	 always_ff@(posedge clk25 or posedge rst)
            begin
                 if(rst)
                   begin
		     valid_time <= '0;
		     result<='0;
                     time_del <= '0;
		    // valid_PID <= '0;
                   end
                 else
	          begin  
                    if ((time_out > 32'd0) && (~ready_dev) && (time_del == 32'd0))
		       begin
                       valid_time <= '1;
		       time_del<=time_out;
	       	       end	
		    if (ready_dev)
		    	begin
			    time_del <= 32'd0;
			    valid_time <= '0;
                            result <= result_f;
			  //  valid_PID <= '1;
                          //  remainder<=remainder_f;
		        end
		 /*  if (valid_PID)
		       valid_PID <= '0;*/
		  end

	    end		 


pid_controller2 pid_control(
	.clk(clk25),
        .rst_n(rst),
        .setpoint(pwm_top),
        .feedback(result),
        .Kp(16'd1),
        .Ki(16'd1),
        .Kd(16'd1),
        .valid(pid_strob_front),
        .control_signal(pid_isp),
        .prev_error(error_isp),
        .integral(integral_isp),
        .derivative()
	);


/* freq_counter freq_counter_1(
                .clk(clk25),
                .rst(rst),
                .strob(key0_strob_front),
                .freq_out(freq_out),
		.ready(ready_freq)
        );*/

        strobe_gen key_gen1(
                .clk(clk25),
                .rst(rst),
                .signal_input(gpio[0]),
                .strob_front(key0_strob_front),
                .strob_back(key0_strob_back)
        );

        strobe_gen pid_gen1(
                .clk(clk25),
                .rst(rst),
                .signal_input(ready_dev),
                .strob_front(pid_strob_front),
                .strob_back()
        );



      time_counter time_counter_1(
                .clk(clk25),
                .rst(rst),
                .strob(key0_strob_front),
                .period(time_out)
        );

     assign led[0] = pwm_out;
     assign led[1] = '0;
     assign led[2] = '0;
     assign led[3] = ready_dev;
     assign gpio [6] = key [0];
     assign gpio [7] = pwm_out;
     assign gpio [9]  = '0;
     assign gpio [12]  = '0;
     assign gpio [13]  = '0;
     assign gpio [10]  = '0;
     assign gpio [11]  = '0;
     assign gpio [14]  = '0;
     assign gpio [15]  = '0;

    /* assign led[0] = time_out [0];
     assign led[1] = time_out [1];
     assign led[2] = time_out [2];
    assign led[3] = time_out [3];
*/

    display i_display(
                .clk(clk25),
                .rst(rst),
                .data(display_out),
                .sio_clk(gpio[1]),
                .sio_stb(gpio[12]),
                .sio_data(gpio[11])
        );


    divfunc #(.XLEN(32),.STAGE_LIST(32'hFFFFFFFF)) divfunc_1(
	    .clk(clk25),
	    .rst(rst),
	    .a(32'd6375000),
	    .b(time_del),
            .vld(valid_time),
	    .quo (result_f),
	    .rem(remainder_f),
	    .ack(ready_dev)
	    );

  pwm pwm_1(
                .clk(clk25),
                .rst(rst),
                .duty(pid_norm),
		.pwm_out(pwm_out)
        );

endmodule


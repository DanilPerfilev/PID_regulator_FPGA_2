module top (
        input   logic           clk25,
        input   logic [3:0]     key,
        inout   logic [15:0]     gpio,
        output  logic [3:0]     led,
	output logic uart_debug_txd
);
        localparam izm = 8'd16; 
        wire rst;
        assign rst = key[3];
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
	reg pwm_out_fl;
	reg pwm_out_bl;
	
	

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
       
   always_ff @ (posedge cmd_clk or posedge rst)
        if (rst)
            pwm_top <=8'h80;
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


		  
function [7:0] bin2ascii (input [3:0] bin);
if(bin < 4'ha)
bin2ascii = {4'h3, bin };
else 	
bin2ascii = {4'h4, 4'(bin-9)};
endfunction

function [7:0] saturate255 (input signed [15:0] raw);
if(raw > $signed('d255))
saturate255 = 'd255;
else if(raw < $signed('d0))
saturate255 = 'd0;
else
saturate255 = raw[7:0];
endfunction

assign pid_norm = saturate255(pid_isp);


reg [7:0] message [41];


	 always_ff@(posedge clk25 or posedge rst)
            begin
                 if(rst)
                   begin
		     result<='0;

                   end
                 else
	          begin  
		    if (ready_dev)
		    	begin
                            result <= result_f;
		        end
		  end
	    end


     always_ff@(posedge clk25 or posedge rst)
     if(rst)
     begin
                    message[0] <= "T";
                    message[1] <= "E";
                    message[2] <= "S";
                    message[3] <= "T";
                    message[4] <= ":";
                    message[5] <= " ";
                    message[6] <= "X";
                    message[7] <= "X";
                    message[8] <= "X";
                    message[9] <= "X";
                    message[10] <= "X";
                    message[11] <= "X";
                    message[12] <= "X";
                    message[13] <= "X";
                    message[14] <= " ";
                    message[15] <= "X";
                    message[16] <= "X";
                    message[17] <= "X";
                    message[18] <= "X";
                    message[19] <= " ";
                    message[20] <= "X";
                    message[21] <= "X";
                    message[22] <= "X";
                    message[23] <= "X";
                    message[24] <= " ";
                    message[25] <= "X";
                    message[26] <= "X";
                    message[27] <= "X";
                    message[28] <= "X";
                    message[29] <= " ";
                    message[30] <= "X";
                    message[31] <= "X";
                    message[32] <= "X";
                    message[33] <= "X";
                    message[34] <= " ";
                    message[35] <= "X";
                    message[36] <= "X";
                    message[37] <= "X";
                    message[38] <= "X";
                    message[39] <= "\n";
                    message[40] <= "\r";
	    end
     else
     begin
	if(ready_dev)
	begin
                    message[6] <= bin2ascii(time_out[31:28]);
                    message[7] <= bin2ascii(time_out[27:24]);
                    message[8] <= bin2ascii(time_out[23:20]);
                    message[9] <= bin2ascii(time_out[19:16]);
                    message[10] <= bin2ascii(time_out[15:12]);
                    message[11] <= bin2ascii(time_out[11:8]);
                    message[12] <= bin2ascii(time_out[7:4]);
                    message[13] <= bin2ascii(time_out[3:0]);

                    message[14] <= " ";
                    message[15] <= bin2ascii(pwm_top[15:12]);
                    message[16] <= bin2ascii(pwm_top[11:8]);
                    message[17] <= bin2ascii(pwm_top[7:4]);
                    message[18] <= bin2ascii(pwm_top[3:0]);

                    message[19] <= " ";
                    message[20] <= bin2ascii(result[15:12]);
                    message[21] <= bin2ascii(result[11:8]);
                    message[22] <= bin2ascii(result[7:4]);
                    message[23] <= bin2ascii(result[3:0]);
                    message[24] <= " ";

                    message[25] <= bin2ascii(pid_isp[15:12]);
                    message[26] <= bin2ascii(pid_isp[11:8]);
                    message[27] <= bin2ascii(pid_isp[7:4]);
                    message[28] <= bin2ascii(pid_isp[3:0]);
		    message[29] <= " ";

                    message[30] <= bin2ascii(error_isp[15:12]);
                    message[31] <= bin2ascii(error_isp[11:8]);
                    message[32] <= bin2ascii(error_isp[7:4]);
                    message[33] <= bin2ascii(error_isp[3:0]);
                    message[34] <= " ";
		    
                    message[37] <= bin2ascii(pid_norm[7:4]);
                    message[38] <= bin2ascii(pid_norm[3:0]);
		    

	end
     end


pid_controller2 pid_control(
	.clk(clk25),
        .rst_n(rst),
        .setpoint(pwm_top),
        .feedback(result),
        .Kp(16'd1),
        .Ki(16'd1),
        .Kd(16'd2),
        .valid(ready_dev),
        .control_signal(pid_isp),
        .prev_error(error_isp),
        .integral(integral_isp),
        .derivative()
	);


        strobe_gen key_gen1(
                .clk(clk25),
                .rst(rst),
                .signal_input(gpio[0]),
                .strob_front(key0_strob_front),
                .strob_back(key0_strob_back)
        );

      time_counter time_counter_1(
                .clk(clk25),
                .rst(rst),
                .strob(key0_strob_front),
                .period(time_out),
		.ready(valid_time)
        );

     assign led[0] = pwm_out_fl;
     assign led[1] = '0;
     assign led[2] = '0;
     assign led[3] = ready_dev;
     assign gpio [6] = '1; // MOT_ALL_EN
     assign gpio [7] = pwm_out_fl; // MOT_FL_PWM1
     assign gpio [9]  = '0;     // MOT_FL_PWM2
     assign gpio [12]  = pwm_out_bl;    // MOT_BL_PWM1
     assign gpio [13]  = '0;    // MOT_BL_PWM2
     assign gpio [10]  = '0;    // MOT_FR_PWM1
     assign gpio [11]  = '0;    // MOT_FR_PWM2
     assign gpio [14]  = '0;    // MOT_BR_PWM1
     assign gpio [15]  = '0;    // MOT_BR_PWM2
    
     divfunc #(.XLEN(32),.STAGE_LIST(32'hFFFFFFFF)) divfunc_1(
	    .clk(clk25),
	    .rst(rst),
	    .a(32'd6375000),
	    .b(time_out),
            .vld(valid_time),
	    .quo (result_f),
	    .rem(remainder_f),
	    .ack(ready_dev)
	    );

  pwm pwm_fl(
                .clk(clk25),
                .rst(rst),
                .duty(pid_norm),
		.pwm_out(pwm_out_fl)
        );

  pwm pwm_bl(
                .clk(clk25),
                .rst(rst),
                .duty(pwm_top),
		.pwm_out(pwm_out_bl)
        );



    wire valid_ready;
    wire [7:0] data;
    reg  [7:0] ptr;

    uart_transmitter # (.clk_mhz(25), .baud_rate(115200), .data_length(8), .need_parity(0), .stop_bits(1))
    i_uart_tx (.clk(clk25), .rst(rst), .data(data), .valid(valid_ready), .ready(valid_ready), .tx(uart_debug_txd));

    assign data = message[ptr];

    always @ (posedge clk25 or posedge rst)
    begin
        if(rst)
                ptr <= 0;
        else
        if(valid_ready)
        begin
                ptr <= ptr + 'd1;
                if(ptr == 'd40)
                        ptr <= 'd0;
        end
    end


endmodule


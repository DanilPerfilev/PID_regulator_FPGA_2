`timescale 1ns / 1ps
/*
module pid_controller(
	input  clk,
	input  rst_n,
	input  signed [15:0] setpoint,
	input  signed [15:0] feedback,
	input  signed [15:0] Kp,
	input  signed [15:0] Ki,
	input  signed [15:0] Kd,
	input  [31:0] clk_prescaler,
	output reg signed [15:0] control_signal,
	output reg signed [15:0] prev_error, 
	output reg signed [15:0] integral,
	output reg signed [15:0] derivative
);
  
	// Internal signals
	
	//reg signed [15:0] prev_error;
	//reg signed [15:0] integral;
	//reg signed [15:0] derivative;
	
	// Clock divider for sampling rate
	reg [31:0] clk_divider;
	reg sampling_flag = '0;

	always @(posedge clk or negedge rst_n) begin
	//$display("Clock trigered");
		if (~rst_n) begin
			clk_divider <= 32'd0;
			sampling_flag <= '0;
		end else if (clk_divider == clk_prescaler) begin // clk_prescaler determines the sampling rate
			clk_divider <= 32'd0;
			
			sampling_flag <= '1;
		end else begin
			clk_divider <= clk_divider + 'd1;
			sampling_flag <= '0;
		end
	end

	always @(posedge clk or negedge rst_n) begin
	
		if (~rst_n) begin
			// Reset logic generally specific to application
			integral <= 16'd0;
			derivative <= 16'd0;
			prev_error <= 16'd0;
			control_signal <= 16'd0;	
		end 
		else if (sampling_flag) begin
					  
			// PID Calculation
			integral <= integral + (Ki * (setpoint - feedback));

			if (integral > $signed(16'h0fff))
				integral <= 16'h0fff;

			if (integral < -$signed(16'h0fff))
				integral <= -16'h0fff;

			derivative <= Kd * ((setpoint - feedback) - prev_error);

			if (derivative > $signed(16'h0fff))
				derivative <= 16'h0fff;

			if (derivative < -$signed(16'h0fff))
				derivative <= -16'h0fff;

			// Calculate control signal
			control_signal = (Kp * (setpoint - feedback)) + integral + derivative; 

			// Update previous error term to feed it for derrivative term.
			prev_error <= (setpoint - feedback);

			if (prev_error > $signed(16'h0fff))
				prev_error<= 16'h0fff;

			if (prev_error < -$signed(16'h0fff))
				prev_error <= -16'h0fff;

			$display("PID: integral = %d, derivative = %d, control_signal = %d, prev_error = %d",
				integral, derivative, control_signal, prev_error);
		end
	end

endmodule */

module pid_controller2(
	input  clk,
	input  rst_n,
	input  signed [15:0] setpoint,
	input  signed [15:0] feedback,
	input  signed [15:0] Kp,
	input  signed [15:0] Ki,
	input  signed [15:0] Kd,
	input  valid,
	output reg signed [15:0] control_signal,
	output reg signed [15:0] prev_error, 
	output reg signed [15:0] integral,
	output reg signed [15:0] derivative
);
  
	// Internal signals
	
	//reg signed [15:0] prev_error;
	//reg signed [15:0] integral;
	//reg signed [15:0] derivative;
	
	always @(posedge clk or posedge rst_n) begin
	
		if (rst_n) begin
			// Reset logic generally specific to application
			integral <= 16'd0;
			derivative <= 16'd0;
			prev_error <= 16'd0;
			control_signal <= 16'd0;	
		end 
		else if (valid) begin
					  
			// PID Calculation
			integral <= integral + (Ki * (setpoint - feedback));

			if (integral > $signed(16'h0fff))
				integral <= 16'h0fff;

			if (integral < -$signed(16'h0fff))
				integral <= -(16'h0fff);

			derivative <= Kd * ((setpoint - feedback) - prev_error);

			if (derivative > $signed(16'h0fff))
				derivative <= 16'h0fff;

			if (derivative < -$signed(16'h0fff))
				derivative <= -(16'h0fff);

			// Calculate control signal
			control_signal = (Kp * (setpoint - feedback)) + integral + derivative; 

			// Update previous error term to feed it for derrivative term.
			prev_error <= (setpoint - feedback);

			if (prev_error > $signed(16'h0fff))
				prev_error <= 16'h0fff;

			if (prev_error < -$signed(16'h0fff))
				prev_error <= -(16'h0fff);

			$display("PID: integral = %d, derivative = %d, control_signal = %d, prev_error = %d",
				integral, derivative, control_signal, prev_error);
		end
	end

endmodule

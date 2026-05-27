`timescale 1ns / 1ps

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

			if (integral > $signed(16'h01ff))
				integral <= 16'h01ff;

			if (integral < -$signed(16'h01ff))
				integral <= -(16'h01ff);

			derivative <= Kd * ((setpoint - feedback) - prev_error);

			if (derivative > $signed(16'h01ff))
				derivative <= 16'h01ff;

			if (derivative < -$signed(16'h01ff))
				derivative <= -(16'h01ff);

			// Calculate control signal
			control_signal = (Kp * (setpoint - feedback)) + integral + derivative; 

			// Update previous error term to feed it for derrivative term.
			prev_error <= (setpoint - feedback);

			if (prev_error > $signed(16'h01ff))
				prev_error <= 16'h01ff;

			if (prev_error < -$signed(16'h01ff))
				prev_error <= -(16'h01ff);

			$display("PID: integral = %d, derivative = %d, control_signal = %d, prev_error = %d",
				integral, derivative, control_signal, prev_error);
		end
	end

endmodule


module display(
	input wire clk,
	input wire rst,
	input wire [31:0] data,
	output wire sio_clk,
	output wire sio_stb,
	output wire sio_data
);
	localparam DELAY = 'd8192;
	reg [15:0] delay;
	reg [7:0] hgfedcba;
	reg [7:0] digit;
	reg [7:0] seg_tbl [0:15];

	initial begin
		$readmemb("seg_tbl.rom", seg_tbl);
	end

	always @(posedge clk or posedge rst)
	begin
		if(rst)
		begin
			delay <= '0;
			hgfedcba <= '0;
			digit <= 'd1;
		end else
	       	begin
			if(delay == DELAY)
			begin 
				delay <= '0;
				digit <= {digit[6:0], digit[7]};
				case (digit)
					8'b10000000: hgfedcba <= seg_tbl[data[3:0]];
					8'b00000001: hgfedcba <= seg_tbl[data[7:4]];
					8'b00000010: hgfedcba <= seg_tbl[data[11:8]];
					8'b00000100: hgfedcba <= seg_tbl[data[15:12]];
					8'b00001000: hgfedcba <= seg_tbl[data[19:16]];
					8'b00010000: hgfedcba <= seg_tbl[data[23:20]];
					8'b00100000: hgfedcba <= seg_tbl[data[27:24]];
					8'b01000000: hgfedcba <= seg_tbl[data[31:28]];
					default:
						hgfedcba <= 'b10000000;
				endcase
			end else 
				delay <= delay + '1;

		end	
	end

	tm1638_board_controller #( .clk_mhz(25), .w_digit(8), .w_seg(8))
	i_tm1638 (
		.clk(clk),
		.rst(rst),
		.hgfedcba(hgfedcba),
		.digit(digit),
		.sio_clk(sio_clk),
		.sio_stb(sio_stb),
		.sio_data(sio_data)
	);
endmodule






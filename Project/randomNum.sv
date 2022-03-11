module randomNum(clk, rst, num);

	parameter N = 3;
	input clk, rst;
	
	output [1:N] num;
	
	reg[1:N] tmp, next;
	
	wire taps;
	
	always_ff@(posedge clk or negedge rst) begin
		
		if(~rst) begin
			tmp <= 1;
		end else begin
			tmp <= next;
		end
	
	end
	
	
	always_comb begin
	
		next = {taps, tmp[1:N -1]};
	
	end
	
	assign num = tmp;
	
	assign taps = tmp[3] ^ tmp[2];
	
	
endmodule
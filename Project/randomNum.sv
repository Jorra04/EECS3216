/*
Learned about LFSR as a method for pseudo random num generation from this YouTube video: https://www.youtube.com/watch?v=Ks1pw1X22y4&ab_channel=Computerphile
*/
module randomNum(clk, rst, num);

	parameter N = 5;
	input clk, rst;

	output [1:N] num;
	reg[1:N] tmp = 1;
	reg[1:N] tmp2 = 2;
	reg[1:N] tmp3 = 3;
	bit newBit;
	

always_ff@(posedge clk or negedge rst) begin
	
	if(~rst) begin

		num = ((tmp ^ tmp2 ^ tmp3) === 0 ? (tmp | tmp2 | tmp3) : (tmp ^ tmp2 ^ tmp3));
		num = num === 0 ? num + 1 : num;
	end else begin
		newBit = num[1] ^ num[3] ^ num[5];
		num = {newBit, num[1:N-1]};
		tmp = {(num[1:N-1] >> 1) , newBit};
		tmp2 = {(num[1:N-1] >> 1) & tmp, ~newBit};
		tmp3 = {(num[1:N-1]) & ~(tmp & tmp2) , newBit};

	end

end
	
endmodule
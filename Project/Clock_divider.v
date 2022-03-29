module Clock_divider(clock_in,clock_out
    );
input clock_in; // input clock on FPGA
output reg clock_out; // output clock after dividing the input clock by divisor

reg[31:0] count;

always @(posedge clock_in) begin
	
		count <= count +1;
		if(count >= 24999999) begin
			count <= 0;
			clock_out <= ~clock_out;
		
		end
	
end


endmodule
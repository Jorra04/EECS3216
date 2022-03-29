module pipeClockDivider(clock_in,clock_out, divisor);
input clock_in; // input clock on FPGA
output reg clock_out; // output clock after dividing the input clock by divisor

reg[31:0] count;
input[3:0] divisor;
reg[31:0] count_threshold;

always @(posedge clock_in) begin

	
		count <= count +1;
//		if(count >= (449999 >> divisor)) begin 
		if(count >= (count_threshold)) begin
			count <= 0;
			clock_out <= ~clock_out;
		
		end
	
end



always_comb begin

	case(divisor)
		
//		4'b0000 : count_threshold =  32'd399999;
//		4'b0001 : count_threshold =  32'd199999;
//		4'b0010 : count_threshold =  32'd133333;
//		4'b0011 : count_threshold =  32'd99999;
//		default : count_threshold =  32'd49999;

		4'b0000 : count_threshold =  32'd199999;
		4'b0001 : count_threshold =  32'd133333;
		4'b0010 : count_threshold =  32'd99999;
		default : count_threshold =  32'd59999;
		
	endcase

end


endmodule
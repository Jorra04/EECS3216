module VGAClockDivider(clock_in,clock_out, rst
    );
input clock_in; // input clock on FPGA
input rst;
output reg clock_out; // output clock after dividing the input clock by divisor

reg[31:0] count;

always @(posedge clock_in) begin
	
		clock_out <= ~clock_out;
	
end


endmodule
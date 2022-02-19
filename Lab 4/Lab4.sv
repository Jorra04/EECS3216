module Lab4(sw0, sw1, sw2, clk, rst, seg0, seg1);

	input sw0, sw1, sw2, clk, rst;
	output[6:0] seg0, seg1;
	reg[32:0] counter;
	reg[3:0] value, value2;

	always_ff@(posedge clk, negedge rst) begin
	
		if(~rst) begin
			counter <= 0;
			value <= 0;
			value2 <= 0;
		end else begin
			
			counter <= counter + 1;
			if(counter == 49999999) begin
				counter <= 0;
				if(!(value == 9 && value2 == 9))
				begin
					if(value == 9) begin
						value <= 0;
						value2 <= value2 + 1;
					end else
						value <= value + 1;
				end
	
			end
			
			
		end
	end
		
	Lab2 hex01(value, seg0);
	Lab2 hex02(value2, seg1);
		
		
endmodule


module Lab2(inputBus, outputBus);

	input [3:0] inputBus;
	output [6:0] outputBus;

	//outputBus[0] corresponds to LEDA
 	assign outputBus[0] = (~inputBus[3] & ~inputBus[2] & ~inputBus[1] & inputBus[0])  | 
								 (~inputBus[3] & inputBus[2] & ~inputBus[1] & ~inputBus[0])  | 
								 (inputBus[3] & ~inputBus[2] & inputBus[1] & inputBus[0])    | 
								 (inputBus[3] & inputBus[2] & ~inputBus[1] & inputBus[0]);
	
	//outputBus[1] corresponds to LEDB
	assign outputBus[1] = (~inputBus[3] & inputBus[2] & ~inputBus[1] & inputBus[0])   |
								 (~inputBus[3] & inputBus[2] & inputBus[1] & ~inputBus[0])   |
								 (inputBus[3] & ~inputBus[2] & inputBus[1] & inputBus[0])    |
								 (inputBus[3] & inputBus[2] & ~inputBus[1] & ~inputBus[0])   |
								 (inputBus[3] & inputBus[2] & inputBus[1] & ~inputBus[0])  	 |
								 (inputBus[3] & inputBus[2] & inputBus[1] & inputBus[0]);     
								 
	
	//outputBus[2] corresponds to LEDC	
	assign outputBus[2] = (~inputBus[3] & ~inputBus[2] & inputBus[1] & ~inputBus[0])  |
								 (inputBus[3] & inputBus[2] & ~inputBus[1] & ~inputBus[0])   |
								 (inputBus[3] & inputBus[2] & inputBus[1] & ~inputBus[0])    |
								 (inputBus[3] & inputBus[2] & inputBus[1] & inputBus[0]);     
	
	//outputBus[3] corresponds to LEDD
	assign outputBus[3] = (~inputBus[3] & ~inputBus[2] & ~inputBus[1] & inputBus[0])  |
								 (~inputBus[3] & inputBus[2] & ~inputBus[1] & ~inputBus[0])  |
								 (~inputBus[3] & inputBus[2] & inputBus[1] & inputBus[0])    |
								 (inputBus[3] & ~inputBus[2] & inputBus[1] & ~inputBus[0])   |
								 (inputBus[3] & inputBus[2] & inputBus[1] & inputBus[0]);     
							
	//outputBus[4] corresponds to LEDE						
	assign outputBus[4] = (~inputBus[3] & ~inputBus[2] & ~inputBus[1] & inputBus[0])  |
								 (~inputBus[3] & ~inputBus[2] & inputBus[1] & inputBus[0])   |
								 (~inputBus[3] & inputBus[2] & ~inputBus[1] & ~inputBus[0])  |
								 (~inputBus[3] & inputBus[2] & ~inputBus[1] & inputBus[0])   |
								 (~inputBus[3] & inputBus[2] & inputBus[1] & inputBus[0])    |
								 (inputBus[3] & ~inputBus[2] & ~inputBus[1] & inputBus[0]);
									
	//outputBus[5] corresponds to LEDF								
	assign outputBus[5] = (~inputBus[3] & ~inputBus[2] & ~inputBus[1] & inputBus[0])  |
								 (~inputBus[3] & ~inputBus[2] & inputBus[1] & ~inputBus[0])  |
								 (~inputBus[3] & ~inputBus[2] & inputBus[1] & inputBus[0])   |
								 (~inputBus[3] & inputBus[2] & inputBus[1] & inputBus[0])    |
								 (inputBus[3] & inputBus[2] & ~inputBus[1] & inputBus[0]);
							
								
	assign outputBus[6] = (~inputBus[3] & ~inputBus[2] & ~inputBus[1]) |
								 (~inputBus[3] & inputBus[2] & inputBus[1] & inputBus[0]) |
								 (inputBus[3] & inputBus[2] & ~inputBus[1] & ~inputBus[0]);

endmodule
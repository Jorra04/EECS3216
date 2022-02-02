module Lab2(clk, sw, f, rst);

	input sw, clk, rst;
	output[7:0] f;
	
	reg[7:0] tmp;
	reg[31:0] counter;
	integer i;
	integer threshold;
	assign f = tmp;

	always @(posedge clk or negedge rst) begin
		
		if(~rst) begin
			counter <= 0;
			tmp <= 0;
			i<= 7;
			threshold <= 100000000; //2 seconds
			
		end else begin
			//If switch is on, complete sequence.
			if(sw) begin
				threshold <= 100000000;
				counter = counter + 1;
				if(counter >= 50000000) begin //Allows for switching mid sequence without hanging.
					counter = 0;
					if(i == -1) begin
						tmp = 0;
						i = 7;
					end else begin
						tmp[i] = 1;
						i = i - 1;
					end
				end
			
			
			end else begin
			
				//If switch is off, complete 2nd sequence.
				
				counter = counter + 1;
				if(counter == threshold) begin
					counter = 0;
					if(i == -1) begin
						tmp = 0;
						i = 7;
						threshold = 100000000;
					end else begin
					if(i != 7)
							threshold = threshold/2;
						tmp[i] = 1;
						i = i - 1;
						
					end
										
				end
			end
		
		end
		
	end

endmodule
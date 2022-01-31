module Lab3(lights, sw0, sw1, clk, rst);

	output[5:0] lights;
	input sw0, sw1, clk, rst;
	
	reg[31:0] counter = 0;
	reg[5:0] tmp;
	
	integer threshold = 25000000;
	integer rightLightsIndex = 2;
	integer leftLightsIndex = 3;
	assign lights = tmp;
	
	always@(posedge clk or negedge rst) begin
	
		if(~rst) begin
			
			counter <= 0;
			threshold = 25000000;
			rightLightsIndex = 2;
			leftLightsIndex = 3;
			
		end else begin
			
			if(sw0 && sw1) begin //Both Switches on.
				counter = 0;
				tmp[5] = 1;
				tmp[4] = 0;
				tmp[3] = 1;
				tmp[2] = 1;
				tmp[1] = 0;
				tmp[0] = 1;
			end else if(sw0 && !sw1) begin //sw0 on sw1 off.
				
				counter = counter + 1;
				if(counter == threshold) begin
					counter = 0;
					if(rightLightsIndex == -1) begin
						rightLightsIndex = 2;
						tmp = 0;
					end else begin
						tmp[rightLightsIndex] = 1;
						rightLightsIndex = rightLightsIndex - 1;
					end
				end
				
				
			end else if(!sw0 && sw1) begin //sw0 off sw1 on.
				counter = counter + 1;
				if(counter == threshold) begin
					counter = 0;
					if(leftLightsIndex == 6) begin
						leftLightsIndex = 3;
						tmp = 0;
					end else begin
						tmp[leftLightsIndex] = 1;
						leftLightsIndex = leftLightsIndex + 1;
					end
				end
			end else begin //Both Switches off.
				counter = 0;
				tmp = 6'b111111;
			end
		
		end
		
	end


endmodule
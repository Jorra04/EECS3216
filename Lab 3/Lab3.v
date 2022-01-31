module Lab3(leftLights, rightLights, error, sw0, sw1, clk, rst);

	output[2:0] leftLights, rightLights;
	output[6:0] error;
	input sw0, sw1, clk, rst;
	
	reg[31:0] counter = 0;
	reg[2:0] leftLights_tmp = 0;
	reg[2:0] rightLights_tmp = 0;
	reg[6:0] tmp_err;
	integer rightLightsIndex = 2;
	integer leftLightsIndex = 0;
	assign leftLights = leftLights_tmp;
	assign rightLights = rightLights_tmp;
	assign error = tmp_err;
	
	
	
	always@(posedge clk or negedge rst) begin
		
		if(~rst) begin
			counter = 0;
			rightLightsIndex = 2;
			leftLightsIndex = 0;
			tmp_err = 7'b1111111;
			leftLights_tmp = 3'b000;
			rightLights_tmp = 3'b000;
			
		end else begin		
			
			if((sw0 == 1) && (sw1 == 1)) begin //Both on, error
				tmp_err = 7'b0110000;
				leftLights_tmp = 3'b000;
				rightLights_tmp = 3'b000;
				rightLightsIndex = 2;
				leftLightsIndex = 0;
				counter = 0;
			end else if((sw0 == 1) && (sw1 == 0)) begin //Right Turn Signal
				counter = counter + 1;
				tmp_err = 7'b1111111;
				leftLightsIndex = 0;

				if(counter == 25000000) begin
					counter = 0;
					if(rightLightsIndex == -1) begin
						rightLights_tmp = 3'b000;
						rightLightsIndex = 2;
					end else begin
						rightLights_tmp[rightLightsIndex] = 1;
						rightLightsIndex = rightLightsIndex - 1;
					end
				end
			end else if((sw0 == 0) && (sw1 == 1)) begin //Left Turn Signal
				counter = counter + 1;
				tmp_err = 7'b1111111;
				rightLightsIndex = 2;
				
				if(counter == 25000000) begin
					counter = 0;
					if(leftLightsIndex == 3) begin
						leftLights_tmp = 3'b000;
						leftLightsIndex = 0;
					end else begin
						leftLights_tmp[leftLightsIndex] = 1;
						leftLightsIndex = leftLightsIndex + 1;
					end
				end
			end else if((sw0 == 0) && (sw1 == 0)) begin //Both off
				counter = 0;
				rightLightsIndex = 2;
				leftLightsIndex = 0;
				tmp_err = 7'b1111111;
				leftLights_tmp = 3'b000;
				rightLights_tmp = 3'b000;
			end
		
		end
		
	end


endmodule
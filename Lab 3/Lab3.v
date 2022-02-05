module Lab3(leftLights, rightLights, clk, rst, sw0, sw1, err);

	
	input clk, rst, sw0, sw1;
	output[2:0] leftLights, rightLights;
	output[6:0] err;
	
	reg[2:0] leftLights_tmp, rightLights_tmp;
	reg[6:0] err_tmp;
	reg[31:0] counter = 32'd0;
	
	integer index = 0;
	integer flashCount = 0;
	assign leftLights = leftLights_tmp;
	assign rightLights = rightLights_tmp;
	assign err = err_tmp;
	always@(posedge clk or negedge rst) begin
	
		if(~rst) begin
			leftLights_tmp = 3'b000;
			rightLights_tmp = 3'b000;
			index = 0;
			counter = 0;
			err_tmp = 7'b1111111;
		end else begin
			if(sw0 && sw1) begin
				leftLights_tmp = 3'b000;
				rightLights_tmp = 3'b000;
				index = 0;
				counter = 0;
				err_tmp = 7'b0000110;
			end else begin
				if(sw0) begin
					err_tmp = 7'b1111111;
					counter = counter + 1;
					if(counter == 25000000) begin
						counter = 0;
						if(index > 2) begin
							index = 0;
							leftLights_tmp = 3'b000;
							rightLights_tmp = 3'b000;
						end else begin
							rightLights_tmp[index] = 1;
							index = index + 1;
						end
					end
				end else if(sw1) begin
					err_tmp = 7'b1111111;
					counter = counter + 1;
					if(counter == 25000000) begin
						counter = 0;
						if(index > 2) begin
							index = 0;
							leftLights_tmp = 3'b000;
							rightLights_tmp = 3'b000;
						end else begin
							leftLights_tmp[index] = 1;
							index = index + 1;
						end
					end
				end else if(!sw0 && !sw1) begin
					err_tmp = 7'b1111111;
					leftLights_tmp = 3'b000;
					rightLights_tmp = 3'b000;
					index = 0;
					counter = 0;
				end
			end
		end
	
	end
endmodule
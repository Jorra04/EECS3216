module Lab4(sw0, sw1, sw2, clk, rst, seg0, seg1);

	input sw0, sw1, sw2, clk, rst;
	output[6:0] seg0, seg1;
	reg[32:0] counter;
	reg[3:0] value, value2, tmp, tmp2;
	reg[6:0] currNum_tmp1, currentNum_tmp2, currentNum_tmp3, currentNum_tmp4 = 0;
	
	reg[6:0] acc = 0;
	assign acc = currNum_tmp1 + currentNum_tmp2 + currentNum_tmp3 + currentNum_tmp4;

	always_ff@(negedge rst, posedge sw0) begin
		if(~rst) begin
			currentNum_tmp2 <= 0;
		end else begin
		
			if(sw0) begin
				currentNum_tmp2 <= currentNum_tmp2 + 6'b000101;
			end
			
		end
	end
	
	always_ff@(negedge rst, posedge sw1) begin
		if(~rst) begin
			currentNum_tmp3 <= 0;
		end else begin
		
			if(sw1) begin
				currentNum_tmp3 <= currentNum_tmp3 + 6'b001010;
			end
			
		end
	end
	
	always_ff@(negedge rst, posedge sw2) begin
		if(~rst) begin
			currentNum_tmp4 <= 0;
		end else begin
		
			if(sw2) begin
				currentNum_tmp4 <= currentNum_tmp4 + 6'b010100;
			end
			
		end
	end
	

	always_ff@(posedge clk, negedge rst) begin
	
		if(~rst) begin
			counter <= 0;
			currNum_tmp1 <= 0;
		end else begin
			if(acc > 0) begin
				counter <= counter + 1;
				if(counter == 49999999) begin
					counter <= 0;
					currNum_tmp1 <= currNum_tmp1 - 1;
				end
			end
			
			
		end
	end
	assign value = acc % 10;
	assign value2 = (acc /10) % 10;
		
	B2D hex01(value, seg0);
	B2D hex02(value2, seg1);		
		
endmodule


module B2D(inputBus, outputBus);

	input [4:0] inputBus;
	output [6:0] outputBus;
	
	
	always@(inputBus) begin
		case(inputBus)
        5'b00000: outputBus = 7'b1000000; //0
        5'b00001: outputBus = 7'b1111001; //1
        5'b00010: outputBus = 7'b0100100; //2
        5'b00011: outputBus = 7'b0110000; //3
        5'b00100: outputBus = 7'b0011001; //4
        5'b00101: outputBus = 7'b0010010; //5
        5'b00110: outputBus = 7'b0000010; //6
        5'b00111: outputBus = 7'b1111000; //7
        5'b01000: outputBus = 7'b0000000; //8
        5'b01001: outputBus = 7'b0010000; //9
		 endcase
		end
	

endmodule
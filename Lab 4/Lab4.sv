module Lab4(sw0, sw1, sw2, clk, rst, seg0, seg1);

	input sw0, sw1, sw2, clk, rst;
	output[6:0] seg0, seg1;
	reg[32:0] counter;
	reg[3:0] value, value2;
	reg[6:0] currNum_tmp1 = 0;
	
	reg[6:0] acc = 0;
	assign acc = currNum_tmp1;
	
	bit sw0_prev, sw1_prev, sw2_prev = 0;
	
	reg[6:0] flashing = 0;

	always_ff@(posedge clk, negedge rst) begin
	
		if(~rst) begin
			counter <= 0;
			currNum_tmp1 <= 0;
			flashing <= 0;
		end else begin
			
			//Only count down if we are greater tha
			if(acc >= 0) begin
				counter <= counter + 1;
				if(counter == 49999999) begin
					counter <= 0;
					if(acc > 0 && !(!sw0_prev && sw0) && !(!sw1_prev && sw1) && !(!sw2_prev && sw2)) currNum_tmp1 <= currNum_tmp1 - 1;
				
					if( !(sw0_prev) && (sw0)) begin

						currNum_tmp1 <= ((currNum_tmp1 + 5) > 99) ? 99 : (currNum_tmp1 + 5);
						sw0_prev = 1;
					end
				
					if(!(sw1_prev) && (sw1)) begin
						currNum_tmp1 <= ((currNum_tmp1 + 10) > 99) ? 99 : (currNum_tmp1 + 10);
						sw1_prev = 1;
					end
					
					if(!(sw2_prev) && (sw2)) begin
						currNum_tmp1 <= ((currNum_tmp1 + 20) > 99) ? 99 : (currNum_tmp1 + 20);
						sw2_prev = 1;
					end
					
					//Update prev states with the current states
					sw0_prev <= sw0;
					sw1_prev <= sw1;
					sw2_prev <= sw2;
				end
				
				if(counter == 12499999 && (acc <= 10 && acc > 0)) begin
					
					flashing <= ~flashing;
				
				end
				
				if(acc == 0) flashing <= 7'b0000000;
				
			end

			
			
		end
	end

	assign value = (acc % 10) ;
	assign value2 = ((acc /10) % 10) ;
		
	B2D hex01(value, seg0, flashing);
	B2D hex02(value2, seg1,flashing);		
		
endmodule


module B2D(inputBus, outputBus, flashing);

	input [4:0] inputBus;
	input[6:0] flashing;
	output [6:0] outputBus;
	
		always@(inputBus) begin
		case(inputBus)
        5'b00000: outputBus = 7'b1000000 | flashing; //0
        5'b00001: outputBus = 7'b1111001| flashing; //1
        5'b00010: outputBus = 7'b0100100| flashing; //2
        5'b00011: outputBus = 7'b0110000| flashing; //3
        5'b00100: outputBus = 7'b0011001| flashing; //4
        5'b00101: outputBus = 7'b0010010| flashing; //5
        5'b00110: outputBus = 7'b0000010| flashing; //6
        5'b00111: outputBus = 7'b1111000| flashing; //7
        5'b01000: outputBus = 7'b0000000| flashing; //8
        5'b01001: outputBus = 7'b0010000| flashing; //9
		 endcase
	
	end
endmodule


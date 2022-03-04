module Lab5(sw0, sw1, sw2, sw3, sw4, sw5, sw6, sw7, seg0, seg1, rst, do_op);

	input sw0, sw1, sw2, sw3, sw4, sw5, sw6, sw7, rst, do_op;
	output[6:0] seg0, seg1;

	reg[5:0] stack[15:0];
	
	reg[6:0] tmp;
	
	reg[4:0] tensValue, onesValue;

	integer index = -1;
	
	always_ff@(negedge do_op, negedge rst) begin
	
		if(~rst) begin
			//If reset, clear the stack
			integer i;
			for(i=0;i<15;i=i+1) stack[i] <= 6'b000000;
			index <= -1;
			tmp <= 0;
		
		end else begin
		
			if(~do_op) begin
			
				if(sw7 && !sw6) begin //push
					//Only push if stack is not already full.
					if(index < 15) begin
						index = index + 1;
						stack[index] = {sw5,sw4,sw3,sw2,sw1,sw0}; //Switches represent 6-bit number we're pushing
						tmp = stack[index];

					end

				end else if(!sw7 && sw6) begin //pop
					//Only pop if stack is not empty
					if(index > 0) begin
						stack[index] = 6'b000000;
						index = index - 1;
						tmp = stack[index];
					end else if(index == 0) begin
					
						stack[index] = 6'b000000;
						tmp = stack[index];
						index = -1;
						
					end
				end
			
			end
		
		end
	
	end
	
	assign onesValue = tmp % 10;
	assign tensValue = (tmp/10) % 10;
	

	B2D(onesValue, seg0);
	B2D(tensValue, seg1);


endmodule



module B2D(inputBus, outputBus);

	input [4:0] inputBus;
	output [6:0] outputBus;
	
		always_comb
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
		  default: outputBus = 7'b1111111;
		 endcase
endmodule
module B2D(inputBus, outputBus);

	input [4:0] inputBus;
	output [6:0] outputBus;
		always_comb
		case(inputBus)
        5'b00000: outputBus =  7'b1000000; //0
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
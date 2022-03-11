module B2D(inputBus, outputBus, flashing);

	input [4:0] inputBus;
	input[6:0] flashing;
	output [6:0] outputBus;
	
		always_comb
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
		  default: outputBus = 7'b1111111;
		 endcase
endmodule
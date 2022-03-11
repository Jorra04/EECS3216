module EECS3216Final(clkin,rst,btn_up,hsync,vsync,r,g,b, tmp, seg0, seg1);
	//inputs
	input clkin; 	//50MHZ input clock
	input rst;		//the main rst (goes through the whole circuit)
	input btn_up;
	
	//outputs for VGA
	output reg hsync, vsync;
	output reg [3:0] r, g, b;
	output[6:0] seg0, seg1;
	
	//timings variables
	wire clk25M, clk1M, gravityClock, pipeClock;
	reg de;
	reg [9:0] x, y;
	reg[9:0] tmp_playerY, tmp2_playerY = 0;
	reg[9:0] tmp_playerX = 0;
	reg [9:0] playerx, playery; 
	
	reg[9:0] pipeX, pipeY;
	
	reg[7:0] score;
	
	reg[3:0] onesPlace, tensPlace;
	bit gameStarted = 0;
	bit gameOver = 0;
	
	bit playerOutOfBounds = 0;
	bit playerHitPipe = 0;
	bit overflow = 0;
	assign gameOver = (playerOutOfBounds | playerHitPipe);
	
	assign playery = tmp_playerY + tmp2_playerY;
	assign playerx = tmp_playerX;
	
	output tmp;
//
pll	pll_inst (
		.areset ( areset_sig ),
		.inclk0 ( clkin ),
		.c0 ( clk25M ),
		.c1 ( clk1M ),
		.locked ( locked_sig )
	);


	gravityClockDivder gravityDivider (
  .clock_in(clkin), 
  .clock_out(gravityClock)
 );
 
 pipeClockDivider pipeDivider (
  .clock_in(clkin), 
  .clock_out(pipeClock)
 );



	//horizontal timings
	parameter HA_START = 0;
	parameter HA_END = 639;
	parameter HS_STA = HA_END + 16;
	parameter HS_END = HS_STA + 96;
	parameter LINE = 799;
	
	//vertical timings
	parameter VA_START = 0;
	parameter VA_END = 479;
	parameter VS_STA = VA_END + 10;
	parameter VS_END = VS_STA + 2;
	parameter SCREEN = 524;
	
	always_comb begin
		hsync = ~(x >= HS_STA && x < HS_END);  
      vsync = ~(y >= VS_STA && y < VS_END);
		de = (x <= HA_END && y <= VA_END);	
	end
	
	
	always_ff@(posedge clk25M or negedge rst) begin
		if(~rst)begin
			x <= 0;
			y <= 0;
			playerHitPipe <= 0;
			
		end else begin 
			if(~gameOver) begin
				if(de)begin
				if(((playerx + 32 > pipeX) && (playerx + 32 < pipeX + 64)) && (playery < pipeY + 192)) begin
						playerHitPipe <= 1;
				
				end else if(x >= playerx && x <= playerx+32 && y >= playery && y <= playery+32)begin
					//bird is kind of yellow
					r <= 4'b1111;
					g <= 4'b1111;
					b <= 4'b0000;
				end else if(x >= pipeX && x <= pipeX+64 && y >= pipeY && y <= pipeY+192) begin
				
					r <= 4'b0011;
					g <= 4'b1010;
					b <= 4'b0010;

				
				end else begin
					//background is sky blue
					r <= 4'b1000;
					g <= 4'b1100;
					b <= 4'b1110;
				end
				
			end else begin		
				r <= 4'b0000;
				g <= 4'b0000;
				b <= 4'b0000;
			end
			
			//screen timing logic
			if (x == LINE) begin  
				x <= 0;
				y <= (y == SCREEN) ? 0 : y + 1;  
			end else begin
				x <= x + 1;
			end
			
			end else begin
				r <= 4'b0000;
				g <= 4'b0000;
				b <= 4'b0000;
			
			end
				
		end
		
		
	end
	
	always_ff@(negedge btn_up or negedge rst) begin
	
		if(~rst) begin
			tmp_playerX <= 303;
			tmp_playerY <= 223;
			gameStarted <= 0;
			tmp <= 0;
			
		end else begin
		
			if(~btn_up) begin
			
				if(playery + 32 < VA_END && (playery ) > 45) begin
				
					tmp_playerY <= tmp_playerY - 40;
				
					gameStarted <= 1;
				
				end
				
				
				
			
				
			end
		
		end
	
	end
	
	always_ff @(posedge gravityClock or negedge rst) begin
	
		if(~rst) begin
		
			tmp2_playerY <= 0;
			playerOutOfBounds <= 0;
		
		end else begin
			if(btn_up&gameStarted) begin

				if(playery + 32 < VA_END && playery > 0) begin
				
					tmp2_playerY <= tmp2_playerY + 5;
				
				end else if (playery + 32 >= VA_END) begin
					playerOutOfBounds <= 1;
				end
			end
		
		end
	
	end
	
	
	
	always_ff @(posedge pipeClock or negedge rst) begin
	
		if(~rst) begin
		
			pipeX <= VA_END;
			pipeY <= 0;
			score <= 0;
		end else begin
			if(gameStarted) begin
				if((pipeX - 64) <= 0) begin
					pipeX <= 500;
				end else begin
					pipeX <= pipeX - 10;
				end
				
				if(playerx == (pipeX + 64)) begin
					score <= score + 1;
				end
				
				
			end
		
		end
	
	end
	
	
	assign onesPlace = (score % 10);
	assign tensPlace = ((score / 10) % 10);
	
	B2D(onesPlace, seg0);
	B2D(tensPlace, seg1);
	
	
endmodule
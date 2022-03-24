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
	wire clk25M, clk1M, gravityClock, pipeClock,scoreClk, gameOverAnimationClk;
	reg de;
	reg [9:0] x, y;
	reg[9:0] tmp_playerY, tmp2_playerY = 0;
	reg[9:0] tmp_playerX = 0;
	reg [9:0] playerx, playery; 
	
	reg[9:0] pipeX, pipeY;
	
	reg[7:0] score, lastScore;
	reg[6:0] flashing = 0;
	reg[3:0] flashText = 0;
	reg[3:0] onesPlace, tensPlace;
	bit gameStarted = 0;
	bit gameOver = 0;
	
	wire[2:0] rng_out;
	
	reg[8:0] pipe_opening_top_arr[6:0] = 		'{9'd250, 9'd150,9'd50,9'd20,9'd70,9'd300,9'd380};
	
	
	reg[8:0] pipe_openning_top;
	
	assign pipe_openning_top = pipe_opening_top_arr[rng_out];
	
	bit addScore = 0;
	bit score5Achieved, score15Achieved,score30Achieved = 0;
	bit tryThis = 0;
	
	bit playerOutOfBounds = 0;
	bit playerHitPipe = 0;
	bit overflow = 0;
	
	assign gameOver = (playerOutOfBounds | playerHitPipe);
	
	assign playery = tmp_playerY + tmp2_playerY;
	assign playerx = tmp_playerX;
	reg[3:0] pipe_clock_divisor = 1;
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
 
 gameOverAnimationClockDivider gameOverclkdiv (
  .clock_in(clkin), 
  .clock_out(gameOverAnimationClk)
 );
 
 pipeClockDivider pipeDivider (
  .clock_in(clkin), 
  .clock_out(pipeClock),
  .divisor(pipe_clock_divisor)
 );
 
 Clock_divider(
	.clock_in(clkin), 
  .clock_out(scoreClk)
  );
  
  
  randomNum rng(
	.clk(tryThis),
	.rst(rst),
	.num(rng_out)
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
	parameter PLAYER_DIMENSIONS = 32;
	parameter SAFE_AREA = 150;
	parameter PIPE_WIDTH = 64;
	
	
	
	parameter BLOCK_SIZE = 16;
	parameter LETTER_SPACING = 70;
	
	parameter TOP_BLOCK_1_START = 160;
	parameter TOP_BLOCK_1_END = TOP_BLOCK_1_START +LETTER_SPACING;
	
	parameter TOP_BLOCK_2_START = TOP_BLOCK_1_END + LETTER_SPACING;
	parameter TOP_BLOCK_2_END = TOP_BLOCK_2_START +LETTER_SPACING;
	
	parameter TOP_BLOCK_3_START = TOP_BLOCK_2_END + LETTER_SPACING;
	parameter TOP_BLOCK_3_END = TOP_BLOCK_3_START +LETTER_SPACING;
	
	
	//Bottom Letters
	parameter BOTTOM_BLOCK_1_START = 84;
	parameter BOTTOM_BLOCK_1_END = BOTTOM_BLOCK_1_START +LETTER_SPACING;
	
	parameter BOTTOM_BLOCK_2_START = BOTTOM_BLOCK_1_END + LETTER_SPACING;
	parameter BOTTOM_BLOCK_2_END = BOTTOM_BLOCK_2_START +LETTER_SPACING;
	
	parameter BOTTOM_BLOCK_3_START = BOTTOM_BLOCK_2_END + LETTER_SPACING;
	parameter BOTTOM_BLOCK_3_END = BOTTOM_BLOCK_3_START +LETTER_SPACING;
	
	parameter BOTTOM_BLOCK_4_START = BOTTOM_BLOCK_3_END + LETTER_SPACING;
	parameter BOTTOM_BLOCK_4_END = BOTTOM_BLOCK_4_START +LETTER_SPACING;
	
	parameter TOP_LETTERS_START = 45;
	parameter TOP_LETTERS_END = TOP_LETTERS_START + 75;

	parameter BOTTOM_LETTERS_START = 295;
	parameter BOTTOM_LETTERS_END = BOTTOM_LETTERS_START + 75;
	
	
	reg[9:0] gameOverAnimationRoll = 0;
	bit gameOverScreenBlack = 0;
	
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
			pipe_opening_top_arr <= 		'{9'd250, 9'd150,9'd50,9'd20,9'd70,9'd300,9'd380};
			tmp <= 0;
		end else begin 
				if(de)begin
					
					if(~gameOver) begin
						if((((playerx + PLAYER_DIMENSIONS > pipeX) && (playerx + PLAYER_DIMENSIONS < pipeX + PIPE_WIDTH)) || (((playerx > pipeX) && (playerx < pipeX + PIPE_WIDTH)) )) && 
						(playery <= pipe_openning_top || (playery + PLAYER_DIMENSIONS) >= pipe_openning_top + SAFE_AREA)) begin
						playerHitPipe <= 1;
					end if(x >= playerx && x <= playerx+PLAYER_DIMENSIONS && y >= playery && y <= playery+PLAYER_DIMENSIONS)begin
						r <= 4'b1111;
						g <= 4'b1111;
						b <= 4'b0000;
					
						
					end else if(x >= pipeX && x <= pipeX+PIPE_WIDTH) begin
					
						if((y >= pipe_openning_top && y <= pipe_openning_top + SAFE_AREA)) begin
						
					
							//blue background
							r <= 4'b1000;
							g <= 4'b1100;
							b <= 4'b1110;
							
						end 
						else begin
						
							//Green pipes
							r <= 4'b0011;
							g <= 4'b1010;
							b <= 4'b0010;
					
						end

				
					end else begin
						//background is sky blue
						
						r <= 4'b1000;
						g <= 4'b1100;
						b <= 4'b1110;
					end
					
					end else begin
						//Gameover
						
						if(~gameOverScreenBlack) begin
						
							if(((y <= gameOverAnimationRoll) && ((x > 0 && x < 120) || (x > 260 && x < 380) || (x > 520 && x < 640))) || 
							((y >= VA_END-gameOverAnimationRoll) && ((x >= 120 && x <= 260) || (x >= 380 && x <= 520)))) begin
								r <= 4'b0000;
								g <= 4'b0000;
								b <= 4'b0000;
							end else begin
							
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
								
							end
						
						end else begin
						
							if(0 <= y && y < 250) begin
								//Y
								if((TOP_BLOCK_1_START <= x && x <= TOP_BLOCK_1_END) && (TOP_LETTERS_START <= y && y <= TOP_LETTERS_END)) begin
									if((TOP_BLOCK_1_START <= x && x <= TOP_BLOCK_1_START + BLOCK_SIZE) && (TOP_LETTERS_START <= y && y <= ((TOP_LETTERS_START  + TOP_LETTERS_END)/2 ))) begin
										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end else if((TOP_BLOCK_1_END - BLOCK_SIZE <= x && x <= TOP_BLOCK_1_END ) && (TOP_LETTERS_START <= y && y <= ((TOP_LETTERS_START  + TOP_LETTERS_END)/2 ))) begin
										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end else if((TOP_BLOCK_1_START <= x && x <= TOP_BLOCK_1_END) && (((TOP_LETTERS_START +TOP_LETTERS_END) /2) - (BLOCK_SIZE/2) <= y && 
									y <= ((TOP_LETTERS_START +TOP_LETTERS_END) /2) + (BLOCK_SIZE /2 ))) begin
										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									
									end else if( (((TOP_BLOCK_1_START +TOP_BLOCK_1_END) /2) - (BLOCK_SIZE/2) <= x && x <= ((TOP_BLOCK_1_START +TOP_BLOCK_1_END) /2) + (BLOCK_SIZE /2 )) && 
									(((TOP_LETTERS_START  + TOP_LETTERS_END)/2 ) <= y && y <= TOP_LETTERS_END ) ) begin
										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end else begin
										r <= ~flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end
									
								//O
								end else if((TOP_BLOCK_2_START <= x && x <= TOP_BLOCK_2_END) && (TOP_LETTERS_START <= y && y <= TOP_LETTERS_END)) begin
									if((TOP_BLOCK_2_START <= x && x <= TOP_BLOCK_2_END) && (TOP_LETTERS_START <= y && y <= TOP_LETTERS_START + BLOCK_SIZE)) begin
										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end else if((TOP_BLOCK_2_START <= x && x <= TOP_BLOCK_2_END) && (TOP_LETTERS_END - BLOCK_SIZE <= y && y <= TOP_LETTERS_END)) begin
										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end else if((TOP_BLOCK_2_START <= x && x <= TOP_BLOCK_2_START + BLOCK_SIZE) && (TOP_LETTERS_START <= y && y <= TOP_LETTERS_END))begin

										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end else if((TOP_BLOCK_2_END - BLOCK_SIZE <= x && x <= TOP_BLOCK_2_END) && (TOP_LETTERS_START <= y && y <= TOP_LETTERS_END))begin

										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end else  begin
										r <= ~flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end
									
									
								
								end else if((TOP_BLOCK_3_START <= x && x <= TOP_BLOCK_3_END) && (TOP_LETTERS_START <= y && y <= TOP_LETTERS_END)) begin
									
									if((TOP_BLOCK_3_START <= x && x <= TOP_BLOCK_3_END) && (TOP_LETTERS_END - BLOCK_SIZE <= y && y <= TOP_LETTERS_END)) begin
										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end else if((TOP_BLOCK_3_START <= x && x <= TOP_BLOCK_3_START + BLOCK_SIZE) && (TOP_LETTERS_START <= y && y <= TOP_LETTERS_END))begin

										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end else if((TOP_BLOCK_3_END - BLOCK_SIZE <= x && x <= TOP_BLOCK_3_END) && (TOP_LETTERS_START <= y && y <= TOP_LETTERS_END))begin

										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end else  begin
										r <= ~flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end
								
								end else begin
									r <= ~flashText;
									g <= 4'b0000;
									b <= 4'b0000;
									
								end
								
								
								
								
							end else begin
							
								if((BOTTOM_BLOCK_1_START <= x && x <= BOTTOM_BLOCK_1_END) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_END)) begin
									if((BOTTOM_BLOCK_1_START <= x && x <= BOTTOM_BLOCK_1_END) && (BOTTOM_LETTERS_END - BLOCK_SIZE <= y && y <= BOTTOM_LETTERS_END)) begin
										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end else if((BOTTOM_BLOCK_1_START <= x && x <= BOTTOM_BLOCK_1_START + BLOCK_SIZE) && (BOTTOM_LETTERS_START <= y && y <= BOTTOM_LETTERS_END))begin

										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end else begin
										r <= ~flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end
								
								end else if((BOTTOM_BLOCK_2_START <= x && x <= BOTTOM_BLOCK_2_END) && (BOTTOM_LETTERS_START <= y && y <= BOTTOM_LETTERS_END)) begin
									
									if((BOTTOM_BLOCK_2_START <= x && x <= BOTTOM_BLOCK_2_END) && (BOTTOM_LETTERS_START <= y && y <= BOTTOM_LETTERS_START + BLOCK_SIZE)) begin
										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end else if((BOTTOM_BLOCK_2_START <= x && x <= BOTTOM_BLOCK_2_END) && (BOTTOM_LETTERS_END - BLOCK_SIZE <= y && y <= BOTTOM_LETTERS_END)) begin
										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end else if((BOTTOM_BLOCK_2_START <= x && x <= BOTTOM_BLOCK_2_START + BLOCK_SIZE) && (BOTTOM_LETTERS_START <= y && y <= BOTTOM_LETTERS_END))begin

										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end else if((BOTTOM_BLOCK_2_END - BLOCK_SIZE <= x && x <= BOTTOM_BLOCK_2_END) && (BOTTOM_LETTERS_START <= y && y <= BOTTOM_LETTERS_END))begin

										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end else  begin
										r <= ~flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									
									end
								
								end else if((BOTTOM_BLOCK_3_START <= x && x <= BOTTOM_BLOCK_3_END) && (BOTTOM_LETTERS_START <= y && y <= BOTTOM_LETTERS_END)) begin
									
									if((BOTTOM_BLOCK_3_START <= x && x <= BOTTOM_BLOCK_3_END) && (BOTTOM_LETTERS_START <= y && y <= BOTTOM_LETTERS_START + BLOCK_SIZE)) begin
										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									end else if((BOTTOM_BLOCK_3_START <= x && x <= BOTTOM_BLOCK_3_START + BLOCK_SIZE) && (BOTTOM_LETTERS_START <= y && y <= ((BOTTOM_LETTERS_START + BOTTOM_LETTERS_END)/2))) begin
										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									end else if((BOTTOM_BLOCK_3_END -  BLOCK_SIZE <= x && x <= BOTTOM_BLOCK_3_END ) && (((BOTTOM_LETTERS_START + BOTTOM_LETTERS_END)/2) <= y && y <= BOTTOM_LETTERS_END)) begin
										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									end else if((BOTTOM_BLOCK_3_START <= x && x <= BOTTOM_BLOCK_3_END) && (BOTTOM_LETTERS_END - BLOCK_SIZE <= y && y <= BOTTOM_LETTERS_END)) begin
										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									end else if((BOTTOM_BLOCK_3_START <= x && x <= BOTTOM_BLOCK_3_END) && (((BOTTOM_LETTERS_START +BOTTOM_LETTERS_END) /2) - (BLOCK_SIZE/2) <= y && 
										y <= ((BOTTOM_LETTERS_START +BOTTOM_LETTERS_END) /2) + (BLOCK_SIZE /2 ))) begin
										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									end else begin
										r <= ~flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									end
								
								end else if((BOTTOM_BLOCK_4_START <= x && x <= BOTTOM_BLOCK_4_END) && (BOTTOM_LETTERS_START <= y && y <= BOTTOM_LETTERS_END)) begin
									
									if((BOTTOM_BLOCK_4_START <= x && x <= BOTTOM_BLOCK_4_END) && (BOTTOM_LETTERS_START <= y && y <= BOTTOM_LETTERS_START + BLOCK_SIZE)) begin
										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									end else if((BOTTOM_BLOCK_4_START <= x && x <= BOTTOM_BLOCK_4_START + BLOCK_SIZE) && (BOTTOM_LETTERS_START <= y && y <= BOTTOM_LETTERS_END)) begin
										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									end else if((BOTTOM_BLOCK_4_START <= x && x <= BOTTOM_BLOCK_4_END) && (BOTTOM_LETTERS_END - BLOCK_SIZE <= y && y <= BOTTOM_LETTERS_END)) begin
										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									end else if((BOTTOM_BLOCK_4_START <= x && x <= BOTTOM_BLOCK_4_END) && (((BOTTOM_LETTERS_START +BOTTOM_LETTERS_END) /2) - (BLOCK_SIZE/2) <= y && 
										y <= ((BOTTOM_LETTERS_START +BOTTOM_LETTERS_END) /2) + (BLOCK_SIZE /2 ))) begin
										r <= flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									end else begin
										r <= ~flashText;
										g <= 4'b0000;
										b <= 4'b0000;
									end
								
								end else begin
								
									r <= ~flashText;
									g <= 4'b0000;
									b <= 4'b0000;
								end
								
							end

						end
					
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
				
		end
		
		
	end
	
	always_ff@(negedge btn_up or negedge rst) begin
	
		if(~rst) begin
			tmp_playerX <= 303;
			tmp_playerY <= 223;
			gameStarted <= 0;
			
		end else begin
		
			if(~btn_up) begin
			
				if(playery + PLAYER_DIMENSIONS < VA_END && (playery ) > 45) begin
				
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
			if((btn_up&gameStarted) && ~gameOver) begin
				if(playery + PLAYER_DIMENSIONS < VA_END && playery > 0) begin
				
					tmp2_playerY <= tmp2_playerY + 5;
				
				end else if (playery + PLAYER_DIMENSIONS >= VA_END) begin
					playerOutOfBounds <= 1;
				end
			end

	
		end
	
	end
	
	
	
	always_ff @(posedge pipeClock or negedge rst) begin
	
		if(~rst) begin
			tryThis <= 1;
			pipeX <= HA_END;
			pipeY <= 0;
			score <= 0;
			pipe_clock_divisor <= 1;
			score5Achieved <= 0;
			score15Achieved <= 0;
			score30Achieved <= 0;
		end else begin
			if(gameStarted && ~gameOver) begin
				if((pipeX) <= 10) begin
					tryThis <= 1;
					pipeX <= HA_END;
				end else begin
					pipeX <= pipeX - 10;
					tryThis <= 0;
				end
					
				addScore <= (playerx > pipeX + PIPE_WIDTH) ? 1 : 0;

				
				if(!addScore && (playerx > pipeX + PIPE_WIDTH)) begin
				
					score <= score + 1;
				
				end
				
				if(score >= 5 && !score5Achieved) begin
					pipe_clock_divisor <= pipe_clock_divisor + 1;
					score5Achieved <= 1;
				end
				
				if(score >= 15 && !score15Achieved) begin
					pipe_clock_divisor <= pipe_clock_divisor + 1;
					score15Achieved <= 1;
				end
				
				if(score >= 30 && !score30Achieved) begin
					pipe_clock_divisor <= pipe_clock_divisor + 1;
					score30Achieved <= 1;
				end

			end
		
		end
	
	end
	
	always_ff@(posedge scoreClk or negedge rst) begin
	
		if(~rst) begin
			flashing <= 0;
			flashText <= 0;
		end else begin
		
			if(gameOver) begin
				flashing <= ~flashing;
				flashText <= ~flashText;

			end
		
		end
	
	end
	
	
	always_ff@(posedge gameOverAnimationClk or negedge rst) begin
		
		if(~rst) begin
			gameOverAnimationRoll <= 0;
			gameOverScreenBlack <= 0;
		end else begin
		
			if(gameOver) begin
			
				if(gameOverAnimationRoll + 5 < VA_END) begin
					gameOverAnimationRoll <= gameOverAnimationRoll + 5;
				end else begin
					gameOverAnimationRoll <= VA_END;
					gameOverScreenBlack <= 1;
				end
			
			end
		
		end
	
	end
	
	
	assign onesPlace = (score % 10);
	assign tensPlace = ((score / 10) % 10);
	
	B2D(onesPlace, seg0,flashing);
	B2D(tensPlace, seg1,flashing);

	
endmodule
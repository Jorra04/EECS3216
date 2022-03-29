module EECS3216Final(clkin,rst,btn_up,hsync,vsync,r,g,b, seg0, seg1, seg5, leds);
	//inputs
	input clkin; 	//50MHZ input clock
	input rst;		//the main rst (goes through the whole circuit)
	input btn_up;
	
	output[9:0] leds;
	reg[3:0] led_counter = 0;
	//outputs for VGA
	output reg hsync, vsync;
	output reg [3:0] r, g, b;
	output[6:0] seg0, seg1, seg5;
	
	//timings variables
	wire clk25M, clk1M, gravityClock, pipeClock,scoreClk, gameOverAnimationClk, powerUpClock, powerupAnimationClock;
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
	
	wire[4:0] rng_out;
	
	reg[8:0] pipe_opening_top_arr[31:0] = 		'{9'd360, 9'd80, 9'd60, 9'd300, 9'd150, 9'd180, 9'd290, 9'd280, 9'd320, 9'd50, 
															9'd190, 9'd230, 9'd210, 9'd140, 9'd260, 9'd120, 9'd170, 9'd200, 9'd160, 9'd220, 9'd70, 
															9'd330, 9'd350, 9'd90, 9'd310, 9'd240, 9'd110, 9'd270, 9'd250, 9'd340, 9'd130, 9'd100};
	
	
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
//
pll	pll_inst (
		.areset ( areset_sig ),
		.inclk0 ( clkin ),
		.c0 ( clk25M ),
		.c1 ( clk1M ),
		.locked ( locked_sig )
	);

	//Clock divider for the gravity component of the game.
	gravityClockDivder gravityDivider (
  .clock_in(clkin), 
  .clock_out(gravityClock)
 );
 
 //Clock divider to drive logic for gameover screen.
 gameOverAnimationClockDivider gameOverclkdiv (
  .clock_in(clkin), 
  .clock_out(gameOverAnimationClk)
 );
 
 //Clock divider to change colour of player object.
  gameOverAnimationClockDivider powerUpAnimationClkDiv (
  .clock_in(clkin), 
  .clock_out(powerupAnimationClock)
 );
 
 //Clock divider to drive the logic for the pipe movement.
 pipeClockDivider pipeDivider (
  .clock_in(clkin), 
  .clock_out(pipeClock),
  .divisor(pipe_clock_divisor)
 );
 
 
 //Clock divider for the score.
 Clock_divider scoreClockDivider(
	.clock_in(clkin), 
  .clock_out(scoreClk)

  );
  
  //powerUpClock
  Clock_divider powerupClock(
	.clock_in(clkin), 
  .clock_out(powerUpClock)
  );
  
  reg[2:0] powerUpTimer = 5;
  bit[6:0] showTimer = 7'b0000000;
  bit invincibility = 0;
  reg[3:0] invincibilityColourMask = 0;
  
  
  //Clock divider for the rng
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
	parameter POWERUP_THRESHOLD = 10;
	
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
			pipe_opening_top_arr <= 		'{9'd360, 9'd80, 9'd60, 9'd300, 9'd150, 9'd180, 9'd290, 9'd280, 9'd320, 9'd50, 
															9'd190, 9'd230, 9'd210, 9'd140, 9'd260, 9'd120, 9'd170, 9'd200, 9'd160, 9'd220, 9'd70, 
															9'd330, 9'd350, 9'd90, 9'd310, 9'd240, 9'd110, 9'd270, 9'd250, 9'd340, 9'd130, 9'd100};
		
		end else begin 
				if(de)begin
					
					if(~gameOver) begin
						if((((playerx + PLAYER_DIMENSIONS > pipeX) && (playerx + PLAYER_DIMENSIONS < pipeX + PIPE_WIDTH)) || (((playerx > pipeX) && (playerx < pipeX + PIPE_WIDTH)) )) && 
						(playery <= pipe_openning_top || (playery + PLAYER_DIMENSIONS) >= pipe_openning_top + SAFE_AREA)) begin
						playerHitPipe <= 1 & ~invincibility;
					end if(x >= playerx && x <= playerx+PLAYER_DIMENSIONS && y >= playery && y <= playery+PLAYER_DIMENSIONS)begin
						//Player object colouring.
						
						/*
						Here we want to take the colour of the bird (yellow) iff the player does not have invincibility. If they do, we want to cycle through
						the colours similar to how the invincibility effect in Super Mario is done.
						*/
						r<= (invincibility) ? invincibilityColourMask | 4'b1000 : 4'b1111;
						g <= (invincibility) ? ~invincibilityColourMask : 4'b1111;
						b<= (invincibility) ? invincibilityColourMask : 4'b0000;
					
						
					end else if(x >= pipeX && x <= pipeX+PIPE_WIDTH) begin
						
						if((y >= pipe_openning_top && y <= pipe_openning_top + SAFE_AREA)) begin //This is the area the bird should fly through.
						
					
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
						
						/*
						Logic for controlling VGA display when the game is over. Here, we display a gameover animation and then animate the
						words "You Lose", with the text and background oscillating out of phase with one another.  
						*/
						if(~gameOverScreenBlack) begin
						
							if(((y <= gameOverAnimationRoll) && ((x >= 0 && x < 120) || (x > 260 && x < 380) || (x > 520 && x < 640))) || 
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
							//Logic for drawing the "You Lose" animation
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
	
	/*
	This always block controls the bird's flight. If we detect a button press and the game has started
	we raise the bird object by a set value. If the bird reaches the top of the screen, we do not allow it to go
	over, we simply limit its upper range to  the top of the screen.
	*/
	
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
	
	/*
	This always block is responsible for controlling the gravity within the game. The bird works against the gravity, and gravity should
	always be acting unless the bird is flapping its wings (to simulate actual flight). If gravity takes the bird down to the ground, the
	player has lost and the game is over.
	*/
	
	always_ff @(posedge gravityClock or negedge rst) begin
	
		if(~rst) begin
		
			tmp2_playerY <= 0;
			playerOutOfBounds <= 0;
			
			
		end else begin
			if((btn_up&gameStarted) && ~gameOver) begin
				if(playery + PLAYER_DIMENSIONS < VA_END && playery > 0) begin
				
					tmp2_playerY <= tmp2_playerY + 1; //was + 5 before
				
				end else if (playery + PLAYER_DIMENSIONS >= VA_END) begin
					playerOutOfBounds <= 1;
				end
			end

	
		end
	
	end
	
	/*
	this always block is responsible for controlling the logic of the pipes. The pipes work in a dynamic fashion.
	As the game progresses, the clock that controls the output of the pipes decreases its threshold and the game becomes
	more challenging as a result. This always block is also responsible for the score keeping and the updating of the powerUp LEDs.
	*/
	
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
			led_counter <= 0;
			leds <= 10'b0000000000;
			
			
		end else begin
			if(gameStarted && ~gameOver) begin
				if((pipeX) <= 10) begin
					tryThis <= 1;
					pipeX <= HA_END;
				end else begin
					pipeX <= pipeX - 1; //changed from 10
					tryThis <= 0;
				end
					
				addScore <= (playerx > pipeX + PIPE_WIDTH) ? 1 : 0;

				
				if(!addScore && (playerx > pipeX + PIPE_WIDTH)) begin
				
					score <= score + 1;
					leds[led_counter] = 1;
					if(led_counter >= POWERUP_THRESHOLD) begin
						led_counter = 0;
						leds = 10'b0000000000;
						
					end else begin
						led_counter = led_counter + 1;
					end
					
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
	
	
	/*
	This always block is responsible for showing the score flashing at the end of the game. The flashing
	score (on/off) indicates that the game is over. We also manipulate a flashText variable, which is used to
	flash the words "You Lose" in phase with the flashing score.
	*/
	
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
	
	/*
	This always block is responsible for the animation that plays immediately after the game is over (rolling lines)
	After the animation has finished, we set a bit "gameOverScreenBlack" to 1 to let the game logic know that we can
	now display the "You Lose" text on screen.
	*/
	
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
	
	
	/*
	This always block is responsible for maintaining and displaying the powerUp clock. Within this
	always block, we detail when to show the powerUp timer, and the logic for decrementing the timer itself.
	We also set the bit responsible for giving the player object invinsibility within this block.
	*/
	
	always_ff@(posedge powerUpClock or negedge rst) begin
	
		if(~rst) begin
			powerUpTimer <= 5;
			showTimer <= 7'b1111111;
			invincibility <= 0;
		end else begin
			
			if(~gameOver) begin
			
				if(showTimer == 7'b0000000) begin
					if(powerUpTimer == 0) begin
				
						powerUpTimer = 5;
						showTimer = 7'b1111111;
						invincibility = 0;
					
					end else begin
				
						powerUpTimer = powerUpTimer - 1;
					
					end
				end else begin

					if(led_counter >= POWERUP_THRESHOLD) begin
						showTimer = 7'b0000000;
						invincibility = 1;
					end
				
				end
			
			end else begin
				showTimer <= 7'b1111111;
			end
		
		end
	
	end
	
	
	/*
	This always block is responsible for the rainblow flashing colours we get with the player object
	when it is in "invincibility" mode. It decrements a 4-bit bus and the game logic that deals with painting the
	player object adds additional logic to ensure we get interesting colours at every tick of powerupAnimationClock
	*/
	
	always_ff@(posedge powerupAnimationClock or negedge rst) begin
	
		if(~rst) begin
			invincibilityColourMask <= 4'b1111;
		end else begin
			if(invincibility) begin
				if(invincibilityColourMask == 4'b0000) begin
					invincibilityColourMask <= 4'b1111;
				end else begin
				
					invincibilityColourMask <= invincibilityColourMask - 1;
				end
			end
		end
	
	end
	
	
	
	
	assign onesPlace = (score % 10); //ones place of score
	assign tensPlace = ((score / 10) % 10); //tens place of score
	
	
	//Logic to drive the 7 segment displays (convert the binary to decimal and display)
	B2D(powerUpTimer, seg5, showTimer);
	B2D(onesPlace, seg0,flashing);
	B2D(tensPlace, seg1,flashing);

	
endmodule
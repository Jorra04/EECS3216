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
	wire clk25M, clk1M, gravityClock, pipeClock,scoreClk;
	reg de;
	reg [9:0] x, y;
	reg[9:0] tmp_playerY, tmp2_playerY = 0;
	reg[9:0] tmp_playerX = 0;
	reg [9:0] playerx, playery; 
	
	reg[9:0] pipeX, pipeY;
	
	reg[7:0] score, lastScore;
	reg[6:0] flashing = 0;
	reg[3:0] onesPlace, tensPlace;
	bit gameStarted = 0;
	bit gameOver = 0;
	
	wire[2:0] rng_out;
	
	reg[8:0] pipe_opening_top_arr[6:0] = 		'{9'd250, 3'd150,3'd50,3'd20,3'd70,3'd300,3'd400};
	reg[8:0] pipe_opening_bottom_arr [6:0] = 	'{9'd450, 9'd350,9'd250,3'd220,3'd270,3'd500,3'd600};
	
	reg[8:0] pipe_openning_top, pipe_opening_bottom;
	
	assign pipe_openning_top = pipe_opening_top_arr[rng_out];
	assign pipe_opening_bottom = pipe_opening_bottom_arr[rng_out];
	
	bit addScore = 0;
	bit score5Achieved, score15Achieved,score30Achieved = 0;
	bit tryThis = 0;
	
	bit playerOutOfBounds = 0;
	bit playerHitPipe = 0;
	bit overflow = 0;
	bit powerUp = 0;
	bit powerUpFlashing = 0;
	assign gameOver = (playerOutOfBounds | playerHitPipe);
	
	assign playery = tmp_playerY + tmp2_playerY;
	assign playerx = tmp_playerX;
	reg[3:0] pipe_clock_divisor = 0;
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
			pipe_opening_top_arr <= 		'{9'd50, 9'd100,9'd150,9'd200,9'd250,9'd300,9'd350};
			pipe_opening_bottom_arr <= 	'{9'd450, 9'd350,9'd250,3'd220,3'd270,3'd500,3'd600};
			tmp <= 0;
		end else begin 
			if(~gameOver) begin
				if(de)begin
				if(((playerx + PLAYER_DIMENSIONS > pipeX) && (playerx + PLAYER_DIMENSIONS < pipeX + PIPE_WIDTH)) && 
				(playery <= pipe_openning_top || (playery + PLAYER_DIMENSIONS) >= pipe_openning_top + SAFE_AREA)) begin
						playerHitPipe <= 1 & !powerUp;
				end if(x >= playerx && x <= playerx+PLAYER_DIMENSIONS && y >= playery && y <= playery+PLAYER_DIMENSIONS)begin
					//bird is kind of yellow
					r <= 4'b1111;
					g <= 4'b1111;
					b <= 4'b0000;
				end else if(x >= pipeX && x <= pipeX+PIPE_WIDTH) begin
					
					if(y >= pipe_openning_top && y <= pipe_openning_top + SAFE_AREA) begin
						
					
					//blue background
						r <= 4'b1000;
						g <= 4'b1100;
						b <= 4'b1110;
						
					end else begin
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
			pipe_clock_divisor <= 0;
			score5Achieved <= 0;
			score15Achieved <= 0;
			score30Achieved <= 0;
			powerUp <= 0;
			powerUpFlashing <= 0;
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
		end else begin
		
			if(gameOver) begin
				flashing <= ~flashing;
					
			end
		
		end
	
	end
	
	
	assign onesPlace = (score % 10);
	assign tensPlace = ((score / 10) % 10);
	
	B2D(onesPlace, seg0,flashing);
	B2D(tensPlace, seg1,flashing);

	
endmodule
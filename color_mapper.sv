//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input              is_ball,            // Whether current pixel belongs to ball 
                                                              //   or background (computed in ball.sv)
                       input					is_rect,
							  input					is_top,
							  input					is_bottom,
							  input					Clk,
							  input					alternator,
							  input					burn,
							  input        [9:0] DrawX, DrawY, startx, starty, endx, endy,   // Current pixel coords
							  output logic crash,
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
    logic [7:0] Red, Green, Blue, RR, GG, BB;
	 logic [3:0] code, code1, code2, code3;
	 
    // Output colors to VGA
	 always_comb
	 begin
		if (is_ball)
			begin
				VGA_R = RR;
				VGA_G = GG;
				VGA_B = BB;
			end
		else
			begin
				VGA_R = Red;
				VGA_G = Green;
				VGA_B = Blue;
			end
	 end
	 
	 always_comb
	 begin
		if (burn)
			code = code3;
		else if (alternator)
			code = code1;
		else
			code = code2;
	 end
	 
	 spaRAM sprite1 (.Clk(Clk), .read_address( (DrawY - starty)*126 + (DrawX - startx) ), .data_Out(code1));
	 spbRAM sprite2 (.Clk(Clk), .read_address( (DrawY - starty)*126 + (DrawX - startx) ), .data_Out(code2));
	 spcRAM sprite3 (.Clk(Clk), .read_address( (DrawY - starty)*126 + (DrawX - startx) ), .data_Out(code3));
	 
	 color_palette cp (.in(code), .VGA_R(RR), .VGA_G(GG), .VGA_B(BB));
	 
    // Assign color based on is_ball signal
    always_comb
    begin
			crash = 1'b0;
        if (is_ball == 1'b1 && is_rect == 1'b1)
			begin
			// if colliding, trip game signal, but for now change ball color to yellow
				crash = 1'b1;
				Red = 8'hFF;
            Green = 8'hFF;
            Blue = 8'hFF;
			end
		  else if (is_ball == 1'b1 && is_top == 1'b1)
			begin
			// if colliding, trip game signal, but for now change ball color to yellow
				crash = 1'b1;
				Red = 8'hFF;
            Green = 8'hFF;
            Blue = 8'hFF;
			end
			else if (is_ball == 1'b1 && is_bottom == 1'b1)
			begin
			// if colliding, trip game signal, but for now change ball color to yellow
				crash = 1'b1;
				Red = 8'hFF;
            Green = 8'hFF;
            Blue = 8'hFF;
			end
			else if (is_ball == 1'b1)
        begin
            // White ball
				crash = 1'b0;
            Red = 8'hFF;
            Green = 8'hFF;
            Blue = 8'hFF;
        end
		  else if (is_rect == 1'b1)
		   begin
            // green rect obstacles
            crash = 1'b0;
				Red = 8'h0;
            Green = 8'hFF;
            Blue = 8'h0;
        end
		  else if (is_top == 1'b1)
		   begin
            // green top border
            crash = 1'b0;
				Red = 8'h0;
            Green = 8'hFF;
            Blue = 8'h0;
        end
		  else if (is_bottom == 1'b1)
		   begin
            // green bottom border
            crash = 1'b0;
				Red = 8'h0;
            Green = 8'hFF;
            Blue = 8'h0;
        end
        else 
        begin
				/*
            // Background with nice color gradient
            Red = 8'h3f; 
            Green = 8'h00;
            Blue = 8'h7f - {1'b0, DrawX[9:3]};
				*/
				crash = 1'b0;
				Red = 8'h0;
            Green = 8'h0;
            Blue = 8'h0;
        end
    end 
    
endmodule

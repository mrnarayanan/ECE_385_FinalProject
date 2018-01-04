//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball2 ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
									  Run,
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
					input [7:0]		keycode,
					output logic [9:0] startx, starty, endx, endy,
               output logic  is_ball             // Whether current pixel belongs to ball or background
              );
    
    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis
    parameter [9:0] Ball_X_Size=63;     // Ball X Size
	 parameter [9:0] Ball_Y_Size=30;		// Ball Y Size
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
    
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
	
	assign startx = Ball_X_Pos - Ball_X_Size;
	assign endx = Ball_X_Pos + Ball_X_Size;
	assign starty = Ball_Y_Pos - Ball_Y_Size;
	assign endy = Ball_Y_Pos + Ball_Y_Size;
    
    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed;
    logic frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
    end
    assign frame_clk_rising_edge = (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    // Update ball position and motion
    always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
            Ball_X_Pos <= Ball_X_Center - 150;
            Ball_Y_Pos <= Ball_Y_Center - 100;
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= 10'd0;
        end
		  else if (~Run)
		  begin
				Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= 10'd0;
		  end
        else if (frame_clk_rising_edge)        // Update only at rising edge of frame clock
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in;
            Ball_Y_Motion <= Ball_Y_Motion_in;
        end
        // By defualt, keep the register values.
    end
    
    // You need to modify always_comb block.
    always_comb
    begin
        // Update the ball's position with its motion
        Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
        Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
    
        // By default, keep ball falling down
        Ball_X_Motion_in = Ball_X_Motion;
		//  if (Ball_Y_Motion >= 9)
			//	Ball_Y_Motion_in = 9;
		//	else
			Ball_Y_Motion_in = Ball_Y_Motion + 1; // downward acceleration
			
        // Be careful when using comparators with "logic" datatype because compiler treats 
        //   both sides of the operator UNSIGNED numbers. (unless with further type casting)
        // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
        // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
        if( Ball_Y_Pos + Ball_Y_Size >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
         begin
				Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);  // 2's complement.
				Ball_X_Motion_in = 0;
			end
        else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Y_Size )  // Ball is at the top edge, BOUNCE!
		  begin
            Ball_Y_Motion_in = Ball_Y_Step;
				Ball_X_Motion_in = 0;
			end
			else if( Ball_X_Pos + Ball_X_Size >= Ball_X_Max )  // Ball is at the right edge, BOUNCE!
			begin
            Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);  // 2's complement. 
				Ball_Y_Motion_in	= 0;
			end	
        else if ( Ball_X_Pos <= Ball_X_Min + Ball_X_Size )  // Ball is at the left edge, BOUNCE!
         begin
				Ball_X_Motion_in = Ball_X_Step;
				Ball_Y_Motion_in = 0;
			end
        
        // TODO: Add other boundary conditions and handle keypress here.
//        else if (keycode == 8'd04) // A - move left - bounce right edge
//		  begin
//				Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
//				Ball_Y_Motion_in = 0;
//			end
//		  else if (keycode == 8'd07) // D - move right - bounce left edge
//		  begin
//				Ball_X_Motion_in = Ball_X_Step;
//				Ball_Y_Motion_in = 0;
//			end
			else if (keycode == 8'd26) // W - move up - bounce bottom edge
		  begin
				Ball_X_Motion_in = 0;
				Ball_Y_Motion_in = ~(Ball_Y_Step*3 + 1'b1); //move up faster
			end
//			else if (keycode == 8'd22) // S - move down - bounce top edge
//		  begin
//				Ball_X_Motion_in = 0;
//				Ball_Y_Motion_in = Ball_Y_Step;
//			end
			
			if(   ( Ball_Y_Pos > (Ball_Y_Max-Ball_Y_Size))
					||((Ball_Y_Pos + Ball_Y_Motion+Ball_Y_Size) > Ball_Y_Max))
					Ball_Y_Pos_in = (Ball_Y_Max-Ball_Y_Size);
		  
		  
    /**************************************************************************************
        ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
        Hidden Question #2/2:
          Notice that Ball_Y_Pos is updated using Ball_Y_Motion. 
          Will the new value of Ball_Y_Motion be used when Ball_Y_Pos is updated, or the old? 
          What is the difference between writing
            "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;" and 
            "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;"?
          How will this impact behavior of the ball during a bounce, and how might that interact with a response to a keypress?
          Give an answer in your Post-Lab.
    **************************************************************************************/
        
        // Compute whether the pixel corresponds to ball or background
 
			if ( (DrawX <= Ball_X_Pos + Ball_X_Size) && (DrawX >= Ball_X_Pos - Ball_X_Size)
					&& (DrawY <= Ball_Y_Pos + Ball_Y_Size) && (DrawY >= Ball_Y_Pos - Ball_Y_Size) )
            is_ball = 1'b1;
        else
            is_ball = 1'b0;
        
        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
        
    end
    
endmodule

module u_edge ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
               output logic  is_top             // Whether current pixel belongs to ball or background
              );
    
    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis
    parameter [9:0] Ball_X_Size=320;     // Ball X Size
	 parameter [9:0] Ball_Y_Size=20;		// Ball Y Size
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
    
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    int DistX, DistY;// Size;
    assign DistX = DrawX - Ball_X_Pos;
    assign DistY = DrawY - Ball_Y_Pos;
//  assign X_Size = Ball_X_Size;
//	 assign Y_Size = Ball_Y_Size;
    
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
            Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Max - 20;
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= 10'd0;
        end
        else if (frame_clk_rising_edge)        // Update only at rising edge of frame clock
        begin
            Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Max - 20;
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= 10'd0;
        end
        // By defualt, keep the register values.
    end
    
    // You need to modify always_comb block.
    always_comb
    begin
	 /*
        // Update the ball's position with its motion
        Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
        Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
    
        // By default, keep ball moving left
        Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
        Ball_Y_Motion_in = Ball_Y_Motion;
        
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
			//	Ball_X_Motion_in = Ball_X_Step;
			//	Ball_Y_Motion_in = 0;
			Ball_X_Pos_in = Ball_X_Max;
			Ball_Y_Pos_in = Ball_Y_Center;
			end
        */

        // Compute whether the pixel corresponds to ball or background
      //  if ( ( DistX*DistX + DistY*DistY) <= (Size * Size) ) 
			if ( (DrawX <= Ball_X_Pos + Ball_X_Size) && (DrawX >= Ball_X_Pos - Ball_X_Size)
					&& (DrawY <= Ball_Y_Pos + Ball_Y_Size) && (DrawY >= Ball_Y_Pos - Ball_Y_Size) )
				is_top = 1'b1;
        else
            is_top = 1'b0;
        
        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
        
    end
    
endmodule

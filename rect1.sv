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


module  rect1 ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
									  Run,
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
               output logic  is_rect             // Whether current pixel belongs to ball or background
              );
    
    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis
    parameter [9:0] Ball_X_Size=10;     // Ball X Size
	 parameter [9:0] Ball_Y_Size=40;		// Ball Y Size
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
	 
	 logic [9:0] Ball_Y_In, position;
	 assign Ball_Y_In = position;

    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
//    int DistX, DistY, Size;
//    assign DistX = DrawX - Ball_X_Pos;
//    assign DistY = DrawY - Ball_Y_Pos;
//  	assign X_Size = Ball_X_Size;
//	 	assign Y_Size = Ball_Y_Size;

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
            Ball_X_Pos <= Ball_X_Max;
            Ball_Y_Pos <= Ball_Y_In;
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
    
        // By default, keep ball moving left
        Ball_X_Motion_in = ~(Ball_X_Step*3 + 1'b1);
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
        else if ( Ball_X_Pos <= Ball_X_Min + Ball_X_Size )  // Ball is at the left edge, go back 
         begin
			//	Ball_X_Motion_in = Ball_X_Step;
			//	Ball_Y_Motion_in = 0;
			Ball_X_Pos_in = Ball_X_Max;
			Ball_Y_Pos_in = Ball_Y_In;
			end
              
        // Compute whether the pixel corresponds to ball or background
 
			if ( (DrawX <= Ball_X_Pos + Ball_X_Size) && (DrawX >= Ball_X_Pos - Ball_X_Size)
					&& (DrawY <= Ball_Y_Pos + Ball_Y_Size) && (DrawY >= Ball_Y_Pos - Ball_Y_Size) )
				is_rect = 1'b1;
        else
            is_rect = 1'b0;
        
        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */   
    end
	 
	 logic [2:0] data;
	 logic [17:0] addr;
//	 assign data = 3'b111;
	 
	 always_ff @ (posedge frame_clk)
	 begin
		if (Reset || addr == 18'd202499)
			addr <= 18'd0;
		else
			addr <= addr + 1'b1;
	 end
	 
	 frameRAM random (.Clk(Clk), .read_address(addr), .data_Out(data));
	 
	always_comb
	begin
		unique case (data)
			3'b000: 
				position = 240;
			3'b001: 
				position = 40;
			3'b010: 
				position = 120;
			3'b011: 
				position = 180;
			3'b100: 
				position = 340;
			3'b101: 
				position = 300;
			3'b110: 
				position = 380;
			3'b111: 
				position = 420;
			default: // should never happen
				position = 240;
		endcase
	end
    
endmodule

module state_machine (	input logic Clk, Reset, crash,
								input logic [7:0] keycode,
								output logic Run, burn
							);

// outputs: Run, 

enum logic [1:0] {Start, Play, Halt} State, Next_state;

always_ff @ (posedge Clk)
begin
	  if (Reset) 
			State <= Start;
	  else 
			State <= Next_state;
end

always_comb
begin 
	// Default next state is staying at current state
	Next_state = State;
  
	unique case (State)
		Start:
			if (keycode == 8'd26) // W
				Next_state = Play;
		Play:
			if (crash == 1'b1)
				Next_state = Halt;
		Halt:
			if (Reset == 1'b1)
				Next_state = Start;
		default:
			;
	endcase
	
	burn = 1'b0;
	Run = 1'b0;
	
	case (State)
		Start:
			Run = 1'b0;
		Play:
			Run = 1'b1;
		Halt:
			begin
			Run = 1'b0;
			burn = 1'b1;
			end
		default:
			;
	endcase
	
end

endmodule

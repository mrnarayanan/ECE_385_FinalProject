module color_palette(input logic [3:0] in, // inputs to decode into RGB
							output logic [7:0] VGA_R, VGA_G, VGA_B); // VGA RGB output
	
	always_comb
	begin
		unique case (in)
			4'b0000: // black
				begin
				VGA_R = 8'h0;
				VGA_G = 8'h0;
				VGA_B = 8'h0;
				end
			4'b0001: // dark blue at top of blade
				begin
				VGA_R = 8'h0c;
				VGA_G = 8'h26;
				VGA_B = 8'h58;
				end
			4'b0010: // light blue at top of blade
				begin
				VGA_R = 8'h19;
				VGA_G = 8'h4c;
				VGA_B = 8'h7f;
				end
			4'b0011: // landing ski
				begin
				VGA_R = 8'h99;
				VGA_G = 8'h99;
				VGA_B = 8'h66;
				end
			4'b0100: // copter upper body
				begin
				VGA_R = 8'he3;
				VGA_G = 8'he3;
				VGA_B = 8'hf1;
				end
			4'b0101: // copter lower body
				begin
				VGA_R = 8'hb6;
				VGA_G = 8'hb6;
				VGA_B = 8'hda;
				end
			4'b0110: // blade body shadow
				begin
				VGA_R = 8'h8a;
				VGA_G = 8'hbc;
				VGA_B = 8'hf7;
				end
			4'b0111: // window
				begin
				VGA_R = 8'h32;
				VGA_G = 8'h78;
				VGA_B = 8'hde;
				end
			4'b1000: // flame body
				begin
				VGA_R = 8'hfa;
				VGA_G = 8'hbc;
				VGA_B = 8'h36;
				end
			4'b1001: // rear wing
				begin
				VGA_R = 8'hcc;
				VGA_G = 8'hcc;
				VGA_B = 8'hff;
				end
			4'b1010: // rear blade
				begin
				VGA_R = 8'h23;
				VGA_G = 8'h6a;
				VGA_B = 8'hb2;
				end
			4'b1011: // flame center
				begin
				VGA_R = 8'hf1;
				VGA_G = 8'hef;
				VGA_B = 8'h07;
				end
			4'b1100: // flame middle
				begin
				VGA_R = 8'hf5;
				VGA_G = 8'h92;
				VGA_B = 8'h00;
				end
			4'b1101: // flame top
				begin
				VGA_R = 8'hcc;
				VGA_G = 8'h7a;
				VGA_B = 8'h00;
				end
			4'b1110: // smoke cloud
				begin
				VGA_R = 8'hf6;
				VGA_G = 8'he7;
				VGA_B = 8'hd1;
				end
			4'b1111: // light white
				begin
				VGA_R = 8'hf7;
				VGA_G = 8'hf9;
				VGA_B = 8'hfd;
				end
			default: // pure white, should never happen
				begin
				VGA_R = 8'hff;
				VGA_G = 8'hff;
				VGA_B = 8'hff;
				end
		endcase
	end //always_comb

endmodule

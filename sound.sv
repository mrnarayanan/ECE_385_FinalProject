module sound (input Clk, Run, Reset,
					input AUD_ADCDAT, AUD_BCLK, AUD_DACLRCK, AUD_ADCLRCK,
					output logic AUD_DACDAT, AUD_XCK, I2C_SCLK, I2C_SDAT,
					output logic SRAM_UB_N, SRAM_LB_N, SRAM_CE_N, SRAM_OE_N, SRAM_WE_N,
					output logic [19:0] SRAM_ADDR,
					input logic [15:0] SRAM_DQ
					);
					
logic [31:0] del, del_cnt, addr;
logic [15:0] data;

always_comb
begin
	SRAM_OE_N = 1'b0;
	SRAM_CE_N = 1'b0;
	SRAM_UB_N = 1'b0;
	SRAM_LB_N = 1'b0;
	SRAM_WE_N = 1'b1;
	SRAM_ADDR = addr;
	data = {SRAM_DQ[15:8], SRAM_DQ[7:0]};
end

always_ff @ (posedge Clk)
begin
	if (Reset == 1'b1 || addr == 32'h948b9)
	begin
		del_cnt <= 32'b0;
		addr <= 32'b0;
	end
	
	else if (Run == 1'b1)
	begin
		if (del_cnt == 32'd1134) // 50MHz / 44.1KHz = 1133.78... = 1134
		begin
			del_cnt <= 32'b0;
			addr <= addr + 1'b1;
		end
		else
			del_cnt <= del_cnt + 1'b1;
	end
	
end


audio_interface system(.clk(Clk), .Reset(Reset), .INIT(), .INIT_FINISH(), .adc_full(),
								.data_over(), .LDATA(data), .RDATA(data), .ADCDATA(),
								.AUD_ADCDAT(AUD_ADCDAT), .AUD_BCLK(AUD_BCLK), .AUD_ADCLRCK(AUD_ADCLRCK),
								.AUD_DACLRCK(AUD_DACLRCK), .AUD_DACDAT(AUD_DACDAT), .AUD_MCLK(AUD_XCK),
								.I2C_SCLK(I2C_SCLK), .I2C_SDAT(I2C_SDAT));
					
					
endmodule

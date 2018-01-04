
module Final( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output logic [6:0]  HEX0, HEX1, HEX2, HEX3, //HEX4, HEX5, HEX6, HEX7,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA vertical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
				 // Audio
				 input					AUD_ADCDAT,
											AUD_BCLK,
											AUD_ADCLRCK,
											AUD_DACLRCK,
					output logic 		AUD_DACDAT,
											AUD_XCK,
											I2C_SCLK,
											I2C_SDAT,
					// SRAM Interface
					output logic [19:0] 	SRAM_ADDR, 
					inout wire [15:0] 	SRAM_DQ,
					output logic 			SRAM_UB_N,
												SRAM_LB_N,
												SRAM_CE_N,
												SRAM_OE_N,
												SRAM_WE_N,
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK      //SDRAM Clock
                    );
    
    logic Reset_h, Clk, Reset_soft;
    logic [15:0] keycode;
    
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
		  Reset_soft <= ~(KEY[1]);     // for soft resetting VGA
    end
    
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs;
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in), // output
                            .from_sw_data_out(hpi_data_out), // input
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),    
                            .OTG_RST_N(OTG_RST_N)
    );
     
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     nios_system nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_out_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in), // input
                             .otg_hpi_data_out_port(hpi_data_out), // output
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w)
    );
  
    // Use PLL to generate the 25MHZ VGA_CLK. Do not modify it.
   /*
	 vga_clk vga_clk_instance(
         .clk_clk(Clk),
         .reset_reset_n(1'b1),
         .altpll_0_c0_clk(VGA_CLK),
         .altpll_0_areset_conduit_export(),    
         .altpll_0_locked_conduit_export(),
         .altpll_0_phasedone_conduit_export()
     );
	  */
    always_ff @ (posedge Clk) begin
        if(Reset_h)
            VGA_CLK <= 1'b0;
        else
            VGA_CLK <= ~VGA_CLK;
    end
    
	 
    VGA_controller vga_controller_instance(.Clk(Clk), .Reset(Reset_soft),
							.VGA_CLK(VGA_CLK), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), 
							.VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_SYNC_N), 
							.DrawX(drx), .DrawY(dry));
							
	 logic isb, isrect, istop, isbottom;
    logic [9:0] drx, dry, startx, starty, endx, endy;
	 logic Run, crash, burn;
	 
	 // Which signal should be frame_clk?
    ball2 ball_instance(.Clk(Clk), .Reset(Reset_soft), .frame_clk(VGA_VS), .DrawX(drx),
	 							.DrawY(dry), .is_ball(isb), .keycode(keycode[7:0]), .Run(Run),
								.startx(startx), .starty(starty), .endx(endx), .endy(endy));
	
	rect1 rectinst(.Clk(Clk), .Reset(Reset_soft), .frame_clk(VGA_VS), .DrawX(drx),
								.DrawY(dry), .is_rect(isrect), .Run(Run));
								
		u_edge upper(.Clk(Clk), .Reset(Reset_soft), .frame_clk(VGA_VS), .DrawX(drx),
								.DrawY(dry), .is_top(istop));
								
		b_edge lower(.Clk(Clk), .Reset(Reset_soft), .frame_clk(VGA_VS), .DrawX(drx),
								.DrawY(dry), .is_bottom(isbottom));
    
    color_mapper color_instance(.is_ball(isb), .is_rect(isrect), .is_top(istop),
											.is_bottom(isbottom), .DrawX(drx), .DrawY(dry), .crash(crash),
											.VGA_B(VGA_B), .VGA_R(VGA_R), .VGA_G(VGA_G),
											.startx(startx), .starty(starty), .endx(endx), .endy(endy), .Clk(Clk),
											.alternator(counter[25]), .burn(burn));
											
	state_machine sm(.Clk(Clk), .Reset(Reset_soft), .crash(crash), .keycode(keycode[7:0]), .Run(Run), 
							.burn(burn));
											

// Scoring
	logic [25:0] counter;
	logic [15:0] score;
	
	always_ff @ (posedge Clk)
	begin
		if (Reset_soft)
			counter <= 26'b0;
		else
			counter <= counter + 1'b1;
	end
	
	always_ff @ (posedge counter[25] or posedge Reset_soft)
	begin
		if (Reset_soft)
			score <= 8'b0;
		else if (~Run)
			score <= score;
		else
			score <= score + 1'b1;
	end
	
	logic [31:0] addr;
	
	sound noise(.*, .Clk(Clk), .Reset(Reset_soft), .Run(Run));

    
    // Display score on hex display
    HexDriver hex_inst_0 (score[3:0], HEX0);
    HexDriver hex_inst_1 (score[7:4], HEX1);
	 HexDriver hex_inst_2 (score[11:8], HEX2);
    HexDriver hex_inst_3 (score[15:12], HEX3);
	 
//	 HexDriver hex_inst_0 (SRAM_DQ[3:0], HEX0);
//	 HexDriver hex_inst_1 (SRAM_DQ[7:4], HEX1);
//	 HexDriver hex_inst_2 (SRAM_DQ[11:8], HEX2);
//	 HexDriver hex_inst_3 (SRAM_DQ[15:12], HEX3);
//	 HexDriver hex_inst_4 (SRAM_ADDR[3:0], HEX4);
//	 HexDriver hex_inst_5 (SRAM_ADDR[7:4], HEX5);
//	 HexDriver hex_inst_6 (SRAM_ADDR[11:8], HEX6);
//	 HexDriver hex_inst_7 (SRAM_ADDR[15:12], HEX7);
    

endmodule

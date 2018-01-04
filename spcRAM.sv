module  spcRAM
(
		//input [4:0] data_In,
		input [12:0] /*write_address,*/ read_address,
		input /*we,*/ Clk,

		output logic [3:0] data_Out
);

// mem has width of 4 bits and a total of 7560 addresses
logic [3:0] mem [0:7559]; // 126*60 = 7560

initial
begin
	 $readmemh("chopper3.txt", mem);
end


always_ff @ (posedge Clk) begin
//	if (we)
	//	mem[write_address] <= data_In;
	data_Out<= mem[read_address];
end

endmodule

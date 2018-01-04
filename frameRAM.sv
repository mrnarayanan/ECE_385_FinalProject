module  frameRAM
(
		//input [4:0] data_In,
		input [17:0] /*write_address,*/ read_address,
		input /*we,*/ Clk,

		output logic [2:0] data_Out
);

// mem has width of 3 bits and a total of 202500 addresses
logic [2:0] mem [0:202499]; // 450*450 = 202500

initial
begin
	 $readmemh("randcol.txt", mem);
end


always_ff @ (posedge Clk) begin
//	if (we)
	//	mem[write_address] <= data_In;
	data_Out<= mem[read_address];
end

endmodule

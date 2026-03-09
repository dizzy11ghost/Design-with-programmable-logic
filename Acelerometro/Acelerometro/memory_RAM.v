module memory_RAM #(parameter NBits = 24, NAddr = 3)(
	input clk, rst_a,
	input wr_en,
	input [NBits - 1 : 0] Data_in,
	input [NAddr - 1 : 0] Data_address,
	output [NBits - 1 : 0] Data_out
);

	reg [NBits - 1 : 0] RAM [0 : (2**NAddr) - 1];

	always @(posedge clk or negedge rst_a)
	begin
		if(!rst_a)
		begin
			integer i;
			for(i = 0; i < 2**NAddr; i = i+1)
				RAM[i] <= 'd0;
		end
		else if(wr_en)
		begin
			RAM[Data_address] <= Data_in;
		end
	end 

	assign Data_out = RAM[Data_address]; 
 
endmodule

module counter (
	input clk,
	input rst,
	input enable,
	output reg [8:0] addr
	);
	
	always @(posedge clk or posedge rst) begin
		if(rst)
			addr <= 0;
		else if (enable)
			addr <= addr +1;
	end
		
endmodule
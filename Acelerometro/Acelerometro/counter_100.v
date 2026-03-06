module counter_100 #(parameter CMAX=30_000_000) (
	input clk,
	input rst,
	output reg [30:0] count);
	
	always @(posedge clk or posedge rst)
		if(rst)
			count <= 0;
		else
		begin
			if(count >= CMAX)
				count <= 0;
			else
			count <= count + 1;
		end
endmodule
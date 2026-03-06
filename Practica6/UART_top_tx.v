module UART_top_tx(
	input CLOCK_50,	
	input [1:0] KEY,
	output [9:0] GPIO,
	output [0:0] LEDR,
	input [6:0] SW,
	output wire [0:6] HEX0, HEX1, HEX2
);

UART_tx WRAP(.clk(CLOCK_50), 
	.rst(~KEY[0]), 
	.tx_out(GPIO[0]), 
	.data_in(SW[6:0]),
	.start(~KEY[1]),
	.busy(LEDR[0]),
	.D_un(HEX0),
	.D_de(HEX1),
	.D_ce(HEX2)
);


endmodule

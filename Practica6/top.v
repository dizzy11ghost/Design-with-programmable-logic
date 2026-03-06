module top(
	input MAX10_CLK1_50,
	input [0:0] KEY,
	input [9:0] ARDUINO_IO,
	output [4:0] LEDR,
	output wire [0:6] HEX0, HEX1, HEX2
	);
	
	UART_Rx WRAP(.clk(MAX10_CLK1_50), .rst(~KEY[0]), .rx_in(ARDUINO_IO[0]), .D_un(HEX0), .D_de(HEX1), .D_ce(HEX2), .data_ready(LEDR[0]), .idle(LEDR[1]), .startbit(LEDR[2]), .databits(LEDR[3]), .stopbits(LEDR[4]));
	
endmodule

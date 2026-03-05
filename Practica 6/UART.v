module UART(
	input wire clk,
	input rst,
	input wire [7:0] data_in,
	input wire start,
	output wire busy,
	output wire [7:0] data_out,
	output wire data_ready
);
	
	wire UART_wire; 
	
	UART_Tx #(.BAUD_RATE(9600), .CLOCK_FREQ(50000000), .BITS(8)) UART_TX (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .start(start),
    .tx_out(UART_wire),
    .busy(busy)
	);

	UART_Rx #(.BAUD_RATE(9600), .CLOCK_FREQ(50000000), .BITS(8)) UART_RX (
    .clk(clk),
    .rst(rst),
    .rx_in(UART_wire),
    .data_out(data_out),
    .data_ready(data_ready)
	);
	
endmodule
	
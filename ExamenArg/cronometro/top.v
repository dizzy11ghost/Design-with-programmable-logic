module top(
    input MAX10_CLK1_50,
    input [1:0] KEY,
	  input [0:0] SW,
    output [0:6] HEX0,
    output [0:6] HEX1,
    output [0:6] HEX2
);
wire clk_1hz;
wire [9:0] counter;

//instanciamos!!
//clock divider
clk_divider #(1) clk1hz(
    .clk(MAX10_CLK1_50),
    .rst(~KEY[0]),
    .clk_div(clk_1hz)
);

//cronómetro
cronometro crn(
	.clk (clk_1hz),
	.clk_fast(MAX10_CLK1_50),
	.rst(~KEY[0]),
	.start_stop(~KEY[1]),
   .enable(SW[0]),
   .counter(counter)
	);
	
//bcd
BCD_display display(
    .bcd_in(counter),
    .D_un(HEX0),
    .D_de(HEX1),
    .D_ce(HEX2)
);

endmodule

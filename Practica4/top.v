module top(
	input MAX10_CLK1_50,
	input [0:0] SW,
	input [1:0] KEY,
	output [6:0] HEX0, HEX1, HEX2, HEX3
	
);

wire clk_d;
assign clk_d = MAX10_CLK1_50;
wire reset = ~KEY[0];
wire enter = ~KEY[1];

clk_divider #(.freq(1)) u_clk(
	.clk(MAX10_CLK1_50),
	.rst (reset),
	.clk_div(clk_d)
);

wire good, bad;
wire [2:0] state;

password u_fsm (
    .clk   (clk_d),
    .X     (SW[0]),
    .rst (reset),
    .enter (enter),
    .seg3  (HEX3),
    .seg2  (HEX2),
    .seg1  (HEX1),
    .seg0  (HEX0)
);

endmodule
	
module top_summation(
    input MAX10_CLK1_50,
    input [1:0] KEY, 
    input [9:0] SW,
    output [0:6] HEX0, HEX1, HEX2
);
    //variables de wire 
    wire rst = ~KEY[0];
    wire start_top = ~KEY[1];
    wire [3:0] data_in_top = SW[3:0];
    wire clk_div_top;
    wire [7:0] sum_top;

    //clk_div
	 clk_divider #(.freq(5)) clockdiv(
	.clk(MAX10_CLK1_50),
	.rst(rst),
	.clk_div(clk_div_top)
	);
	
    //adder
    summation summation_top(
        .clk (clk_div_top),
        .reset(rst), 
        .data_in(data_in_top),
        .start (start_top), //si start esta activo, data_in toma el valor del contador 
        .sum (sum_top) //suma final
    );

    //BCD display
	BCD_display #(.N_in(8), .N_out(7))display ( //instanciamos el display para mostrar el conteo en BCD
    .bcd_in(sum_top),
    .D_un(HEX0),
    .D_de(HEX1),
    .D_ce(HEX2)
    );

endmodule

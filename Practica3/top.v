//Sophia Leñero Gómez A01639462
//Diseño con lógica programable (Gpo 101)
//Practica 3 - Esta práctica implementa un contador de 0 a 100 decendente o ascendente,
//y muestra en el display de 7 segmentos la cuenta.
module top(
	input MAX10_CLK1_50, 
	input [9:1] SW, //los switches de la tarjeta
	input [1:0] KEY, //vamos a usar la key para el reset
	output [0:6] HEX0, HEX1, HEX2 //los hexadecimales a imprimir!!
);
	
	//variables de wire para instanciar más adelante
	wire rst = ~KEY[0];
	wire load_top = ~KEY[1];
	wire up_down_top = SW[9];
	wire clk_div_top ;
	wire [0:6] count_top; //le asignamos 7 bits para que quepa
	
	//Instanciamos!!
	//clk_div
	 clk_divider #(.freq(5)) clockdiv(
	.clk(MAX10_CLK1_50),
	.rst(rst),
	.clk_div(clk_div_top)
	);
	
	//count100
	count100 #(.CMAX(100)) counter(
	.clk(clk_div_top),
   .rst(rst),
   .count(count_top),
   .data_in(data_in_top),
   .load(load_top),
   .up_down(up_down_top)
	);
	
	//BCD display
	BCD_display #(.N_in(10), .N_out(7))display ( //instanciamos el display para mostrar el conteo en BCD
    .bcd_in(count_top),
    .D_un(HEX0),
    .D_de(HEX1),
    .D_ce(HEX2)
    );
	
endmodule

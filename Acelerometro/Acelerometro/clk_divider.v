// Miguel Alonso De La Rosa Zamora A01646106
// En este módulo lo que se pretende es utilizar el reloj interno del FPGA (de 50MHz), y mediante un valor de entrada de frecuencia deseada 
// se busca que a la salida se genere un reloj con esa frecuencia. 
// La frecuencia de salida se obtiene usando un contador cuyo valor se calcula como 
// "constantNumber = CLK_FREQ / (2 * FREQ), el cual conmuta la salida cada constantNumber ciclos de reloj de entrada. 
module clk_divider #(parameter FREQ = 2)(
	input clk, rst, 
	output reg clk_div
	);
	
	reg [31:0] count;
	parameter CLK_FREQ = 50000000;
	parameter constantNumber = (CLK_FREQ/(2*FREQ));
	
	always @(posedge clk or posedge rst)
	begin 
		if (rst == 1)
			count <= 32'b0;
		else if (count == constantNumber - 1)
			count <= 32'b0;
		else
			count <= count + 1;
	end
	
	always @(posedge clk or posedge rst)
	begin
		if(rst == 1)
			clk_div <= 0;
		else if (count == constantNumber - 1)
			clk_div <= ~clk_div;
		else
			clk_div <= clk_div;
	end
endmodule
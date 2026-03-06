// Miguel Alonso De La Rosa Zamora A01646106
// En este módulo lo que se pretende es recibir un dato de entrada (bcd_in), el cuál representa un número binario de 4 variables. 
// De salida (bcd_out) se representa el número decimal tomando en cuenta la distribución de los bits del display. 
// La salida se logra usando un bloque case/conductal asignando cada caso de número binario, como sería en display.
// Se niega la salida debido a la lógica que usan los displays del FPGA D10-lite. 
module BCD_module(
	input [3:0] bcd_in, 
	output reg [0:6] bcd_out
	);

	always@(*) // Bloque conductal
	begin
		case(bcd_in)
			0: bcd_out = ~7'b1111_110; //Número 0 binario a decimal en display. 
			1: bcd_out = ~7'b0110_000; //Número 1 binario a decimal en display.
			2: bcd_out = ~7'b1101_101; //Número 2 binario a decimal en display.
			3: bcd_out = ~7'b1111_001; //Número 3 binario a decimal en display.
			4: bcd_out = ~7'b0110_011; //Número 4 binario a decimal en display.
			5: bcd_out = ~7'b1011_011; //Número 5 binario a decimal en display.
			6: bcd_out = ~7'b1011_111; //Número 6 binario a decimal en display.
			7: bcd_out = ~7'b1110_000; //Número 7 binario a decimal en display.
			8: bcd_out = ~7'b1111_111; //Número 8 binario a decimal en display.
			9: bcd_out = ~7'b1111_011; //Número 9 binario a decimal en display.
			default: bcd_out = ~7'b0000_000; //Otros posibles casos que no se tendran en cuenta donde no se encendera el display.
		endcase
	end
	
endmodule
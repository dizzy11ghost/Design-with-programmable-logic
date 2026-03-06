module clk_divider #(parameter freq = 5)(
    input clk, rst,
    output reg clk_div);

    reg [31:0] count; // Contador para dividir el reloj

    parameter clk_freq = 50_000_000; // Frecuencia del reloj de entrada en Hz (ajustar según tu caso)
    parameter constant_num = clk_freq / (2 * freq); //Es inversamnente proporcional a la frecuencia, si queremos una frecuencia más baja, el contador tiene que contar más ciclos del reloj de entrada para generar un ciclo completo del reloj de salida
    
	always @(posedge clk or posedge rst)
	begin 
		if (rst == 1)
			count <= 32'b0;
		else if (count == constant_num - 1)
			count <= 32'b0;
		else
			count <= count + 1;
	end
	
	always @(posedge clk or posedge rst)
	begin
		if(rst == 1)
			clk_div <= 0;
		else if (count == constant_num - 1)
			clk_div <= ~clk_div;
		else
			clk_div <= clk_div;
	end

endmodule 

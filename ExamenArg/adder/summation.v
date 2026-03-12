//Diseñar un sistema en Verilog que:
//1. Reciba un número de entrada mediante los switches.
//2. Al activar una señal de start, calcule la sumatoria desde 0 hasta el número ingresado.
//3. Muestre el resultado de la sumatoria en una salida, como LEDs o displays de 7
//segmentos.
//4. NO SE PUEDE UTILIZAR LA FORMULA DE GAUSS.
//tiene que ser hasta 15, ósea 16 bits, ósea 2 a la 4
//aproach - vamos a utilizar un contador para saber qué sumarle a la suma hasta que el contador llegue a data in

module summation(
    input clk,
    input reset, 
    input wire [3:0] data_in, //dato del usuario, vamos a tomarlo como nuestro CMAX, nuestro limite vaya
    input start, //si start esta activo, data_in toma el valor del contador 
    output reg [7:0] sum //suma 
);
	reg [4:0] count;
	reg busy;
	
	always @(posedge clk or posedge reset) begin 
		 if (reset) begin
			  sum <= 0; //inicializamos todo en 0 si hay un reset
			  count <= 0;
			  busy <= 0;
		 end else if (start == 1 && !busy) begin
			 busy  <= 1;
            sum   <= 0;
            count <= 0;
        end else if (busy) begin
            if (count <= data_in) begin
                sum   <= sum + count;
                count <= count + 1;
					 
            end else begin
                busy <= 0; //el resultado esta en sum
					 count <= count;
            end
        end
    end

endmodule

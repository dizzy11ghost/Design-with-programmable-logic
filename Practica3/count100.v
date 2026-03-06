module count100 #(parameter CMAX = 100)(
	input clk,
	input rst,
	input  [6:0] data_in, //los números a contar
	input load, //load es para parar de contar y mostrar un número en especifico de data_in
	input up_down, //up_down es para decidir si el conteo es ascendente o descendente
	output reg [6:0] count //aqui se guarda el conteo, es el que se va a incrementar y es reg porque almacena info
	);
	
		always @(posedge clk or posedge rst)
		begin
			if (rst) //en caso de reset, la cuenta es 0
				count <= 0; //no bloqueante para esperar el reset
			
			else if (load) 
				begin
					count <= data_in; // esto es prioridad sobre el conteo
				end
				
			else if (up_down)
				begin
					if (count == CMAX)  //si count llega a 100, se regresa a 0
						count <= 0;
					else
						count <= count + 1; //si no, sigue incrementando hasta que llegue a 99
				end
			
			else //conteo descendente
			begin
				if (count == 0) //si count es 0, se regresa a 100 para contar de ahi
					count <= CMAX;
				else
					count <= count -1; //si no, va decrementando hasta 0
			end
		end
	

endmodule

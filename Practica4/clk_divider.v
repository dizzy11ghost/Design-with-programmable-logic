module clk_divider #(parameter freq = 5)(
    input clk, rst,
    output reg clk_div);

    reg [31:0] count; // Contador para dividir el reloj

    parameter clk_freq = 50; // Frecuencia del reloj de entrada en Hz (ajustar según tu caso)
    parameter constant_num = clk_freq / (2 * freq); //Es inversamnente proporcional a la frecuencia, si queremos una frecuencia más baja, el contador tiene que contar más ciclos del reloj de entrada para generar un ciclo completo del reloj de salida
    
    always @(posedge clk or posedge rst) 
        begin
            if (rst == 1)
                count <= 0; // Reiniciar el contador
            else if (count == constant_num - 1)
                count <= 0; // Reiniciar el contador
            else
                count <= count + 1; // Incrementar el contador
        end

    always @(posedge clk or posedge rst)
        begin
            if (rst) //la señal de clock div la mandamos a 0 con una no bloqueante para que se reinicie inmediatamente al activar el reset
                clk_div <= 0; // Reiniciar la señal de salida
            else if (count == constant_num - 1) //cada vez que llega a 3, la vamos a estar negando, para de esa forma "alargar" el periodo del reloj de salida
                clk_div <= ~clk_div; // Cambiar el estado de la señal de salida
            else 
                clk_div <= clk_div; //si no ha llegado a la cuenta se mantiene igual
        end

endmodule 
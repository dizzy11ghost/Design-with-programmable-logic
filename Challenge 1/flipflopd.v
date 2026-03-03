module flipflopd(d, clk, q); //// no se usa rst porque el flipflop d depende sólo de la entrada d y del reloj 
    input d;
    input clk;
    output reg q; //usamos reg porque almacena el estado del flip flop hasta la siguiente transición de reloj.
    //no usamos wire porque depende de las entradas y el estado, no sólo de una señal combinacional.

    always@(posedge clk) 
    begin
        q <= d;  //el estado del flip flop se actualiza con el valor de d en cada flanco positivo del reloj
    end
endmodule

//este flip flop sólo acepta el botón cuando lleva suficiente tiempo estable


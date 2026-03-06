module hvsync_generator (
    input clk, 
    input pixel_tick, //sirve para sincronizar el contador con el reloj de pixeles
    output vga_h_sync, //señal de sincronización horizontal, se activa cada vez que el contador de pixeles llega a su máximo
    output vga_v_sync, //señal de sincronización vertical, se activa cada vez que el contador de líneas llega a su máximo
    output red inDisplayArea, //señal que indica si estamos dentro del área de visualización, se activa cuando el contador de pixeles y el contador de líneas están dentro de los límites de la pantalla
    output reg [9:0] CounterX = 0, //contador de pixeles horizontal
    output reg [9:0] CounterY = 0 //contador de pixeles vertical
);

reg vga_HS = 0;
reg vga_VS = 0;

wire CounterXmaxed = (CounterX == 799);
wire CounterYmaxed = (CounterY == 524);

always @(posedge clk) begin
    if (pixel_tick) begin
        if (CounterXmaxed)
            CounterX <= 0;
        else
            CounterX <= CounterX + 1;
    end
end 

always @(posedge clk) begin
        if (pixel_tick && CounterXmaxed) begin
            if (CounterYmaxed)
                CounterY <= 0;
            else
                CounterY <= CounterY + 1;
        end
end

always @(posedge clk) begin
    if (pixel_tick)
        vga_HS  <= (CounterX >= 656) && (CounterX <= 751); //se activa la señal de sincronización horizontal cuando el contador de pixeles está entre 656 y 751, que es el periodo de sincronización horizontal 
end

always @(posedge clk) begin
    if (pixel_tick)
        inDisplayArea  <= (CounterX < 640) && (CounterY < 480); //se activa la señal de área de visualización cuando el contador de pixeles está entre 0 y 639 y el contador de líneas está entre 0 y 479, que es el área de visualización de la pantalla
end 

assign vga_h_sync = ~vga_HS;
assign vga_v_sync = ~vga_VS;

endmodule
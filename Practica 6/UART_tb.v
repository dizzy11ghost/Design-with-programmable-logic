module UART_tb();

//Señales para el transmisor
reg clk;
reg rst;
reg [7:0] data_in;
reg start;
//wire tx_out;
wire busy;

//Señales para el receptor
//reg rx_in;
wire [7:0] data_out;
wire data_ready;


UART uart (.clk(clk), .rst(rst), .data_in(data_in), .start(start), .busy(busy), .data_out(data_out), .data_ready(data_ready)); 


initial begin
    clk = 0;
    rst = 0;
    data_in = 8'h00;
    start = 0;
end

always
    #10 clk = ~clk; // Genera un reloj de 50 MHz

initial
begin
    $display("Simulación iniciada");
    #30;
    rst = 1; // Activa el reset
    #10;        
    rst = 0; // Desactiva el reset
    #20000; // Espera suficiente tiempo para que el sistema se estabilice
    repeat(10) begin
        data_in = $random % 256; // Carga un dato de prueba
        start = 1; // Inicia la transmisión
        #2000;
        start = 0; // Detiene la señal de inicio
        wait(data_ready); // Espera a que termine la transmisión
        $display("Dato transmitido: %b, Dato recibido: %b", data_in, data_out);
        #50000000;
    end
    $stop;
    $finish;
end


initial begin
   $dumpfile("UART_tb.vcd");
   $dumpvars(0, UART_tb);
end

endmodule
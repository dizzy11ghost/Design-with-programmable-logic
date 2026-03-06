module pwm #(parameter MIN = 4, MAX = 14)(
    input  wire clk,
    input  wire rst_p,
    input  wire [7:0] pwm_in,
    output reg  pwm_out
);
    // Todos los cálculos en elaboración (compile time)
    localparam integer PERIOD = 500_000;
    localparam integer MINIMO = PERIOD * MIN / 100;
    localparam integer MAXIMO = PERIOD * MAX / 100;
    localparam integer RANGO  = MAXIMO - MINIMO;

    reg [24:0] conteo;
    wire [24:0] umbral;

    // Contador interno — sin módulo externo, sin mismatch
    always @(posedge clk or posedge rst_p)
    begin
        if (rst_p)
            conteo <= 0;
        else if (conteo >= PERIOD - 1)
            conteo <= 0;
        else
            conteo <= conteo + 1;
    end

    // Umbral: RANGO y MINIMO son constantes, Quartus solo sintetiza
    // un multiplicador por pwm_in — sin divisor en runtime
    assign umbral = MINIMO + (RANGO * pwm_in) / 180;

    // Comparador
    always @(posedge clk or posedge rst_p)
    begin
        if (rst_p)
            pwm_out <= 0;
        else
            pwm_out <= (conteo < umbral);
    end

endmodule
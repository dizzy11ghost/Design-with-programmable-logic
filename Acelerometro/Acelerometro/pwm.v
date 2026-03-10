module pwm #(parameter MIN = 4, MAX = 14)(
    input  wire clk,
    input  wire rst_p,
    input  wire [7:0] pwm_in,
    output reg  pwm_out
);
    localparam integer PERIOD = 500_000;
    localparam integer MINIMO = PERIOD * MIN / 100;
    localparam integer MAXIMO = PERIOD * MAX / 100;
    localparam integer RANGO  = MAXIMO - MINIMO;

    reg [24:0] conteo;
    reg [7:0]  pwm_in_latch;  // ← captura pwm_in una vez por periodo
    wire [24:0] umbral;

    always @(posedge clk or posedge rst_p) begin
        if (rst_p)
            conteo <= 0;
        else if (conteo >= PERIOD - 1)
            conteo <= 0;
        else
            conteo <= conteo + 1;
    end

    always @(posedge clk or posedge rst_p) begin
        if (rst_p)
            pwm_in_latch <= 0;
        else if (conteo == PERIOD - 1)  
            pwm_in_latch <= pwm_in;
    end

    assign umbral = MINIMO + (RANGO * pwm_in_latch) / 180;

    always @(posedge clk or posedge rst_p) begin
        if (rst_p)
            pwm_out <= 0;
        else
            pwm_out <= (conteo < umbral);
    end

endmodule
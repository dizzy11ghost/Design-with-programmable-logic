module top(
    input MAX10_CLK1_50,
    input [2:0] KEY,
    output [0:0] LEDR
    );

    wire clk_div_t;
    wire ff1_t;
    wire ff2_t;
	 wire pulse;
	 wire rst;

    clk_divider #(.freq(5000))clockdiv( //instaciamos el clock divider para trabajar con el tiempo "ralentizado"
    .clk(MAX10_CLK1_50),
    .rst(~KEY[1]),
    .clk_div(clk_div_t)
    );

    flipflopd ff1(
        .d(~KEY[0]),
        .clk(clk_div_t),
        .q(ff1_t) //la salida del primer flip flop!!
        // ff1_t sirve para detectar cuando el botón se ha estabilizado en 1 después de ser presionado.
    );

    flipflopd ff2(
        .d(ff1_t),
        .clk(clk_div_t),
        .q(ff2_t)
    );

    pulse_generator  pg( //oneshot
        .ff1(ff1_t),
        .ff2(ff2_t),
        .pulse(pulse)
    );
	 
	 assign LEDR[0] = pulse;


endmodule

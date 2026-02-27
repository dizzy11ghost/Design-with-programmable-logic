module BCD_display #(parameter N_in = 10, N_out = 7)(
    
    input[N_in-1:0] bcd_in,
    output[N_out-1:0] D_un, D_de, D_ce
    );

    wire [3:0] unidades, decenas, centenas;
    assign unidades = bcd_in % 10; //el %10 es para obtener el residuo de la división entre 10, es decir, el dígito de las unidades
    assign decenas = (bcd_in/10)%10; //dividimos entre 10 para obtener el dígito de las decenas y luego obtenemos el residuo de la división entre 10 para obtener el dígito de las decenas
    assign centenas = (bcd_in/100)%10;

    BCD_module uni(
        .bcd_in(unidades),
        .bcd_out(D_un)
    );

    BCD_module dec(
        .bcd_in(decenas),
        .bcd_out(D_de)
    );

    BCD_module cen(
        .bcd_in(centenas),
        .bcd_out(D_ce)
    );


endmodule
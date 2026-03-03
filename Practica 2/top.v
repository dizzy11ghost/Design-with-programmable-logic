//Sophia Leñero Gómez A01639462
//Diseño con lógica programable (Gpo 101)
//Practica 2 - BCD 4 displays. El siguiente código sirve para usar switches de una FPGA y usar el 
//display de 7 segmentos para mostrar el número ingresado, separado en unidades, decenas, centenas y millares 
module top(
    input [9:0] SW,
    output [0:6] HEX0, HEX1, HEX2, HEX3
);

    BCD_4displays WRAP(.bcd_in(SW), .D_un(HEX0), .D_de(HEX1), .C_ce(HEX2), .D_mi(HEX3));

endmodule
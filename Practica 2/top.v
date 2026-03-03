module top(
    input [9:0] SW,
    output [0:6] HEX0, HEX1, HEX2, HEX3
);

    BCD_4displays WRAP(.bcd_in(SW), .D_un(HEX0), .D_de(HEX1), .C_ce(HEX2), .D_mi(HEX3));

endmodule
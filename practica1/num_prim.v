//A01639462

module num_prim #(parameter N = 10)(
    input a, b, c, d,
    output out
    );

    assign out = (~a & c) |
           (c & d) |
           (b & ~c & d) |
           (a & ~b & c);

endmodule

module top(
    input [3:0] SW,
    output [0:0] LEDR
);

    num_prim #(.N(4)) numprim1(
        .a(SW[0]),
        .b(SW[1]),
        .c(SW[2]),
        .d(SW[3]),
        .out(LEDR[0])
    );
endmodule   
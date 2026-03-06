//A01639462
//Sophia Leñero Gómez
module top(
    input [3:0] SW,
    output [0:0] LEDR
);

    num_prim numprim1 (
        .a(SW[3]),   
        .b(SW[2]),
        .c(SW[1]),
        .d(SW[0]),   
        .out(LEDR[0])
    );

endmodule 

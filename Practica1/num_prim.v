//A01639462
//Sophia Leñero Gómez
module num_prim(
    input a, b, c, d,
    output out
);

assign out =
       (~a & ~b &  c & ~d) |  // 2
       (~a & ~b &  c &  d) |  // 3
       (~a &  b & ~c &  d) |  // 5
       (~a &  b &  c &  d) |  // 7
       ( a & ~b &  c &  d) |  // 11
       ( a &  b & ~c &  d);   // 13

endmodule


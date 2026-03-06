`timescale 1ns/1ps

module tb_top;

reg  [3:0] SW;
wire [0:0] LEDR;

top uut (
    .SW(SW),
    .LEDR(LEDR)
);

initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb_top);

    SW = 4'b0000; #10;
    SW = 4'b0010; #10; // 2
    SW = 4'b0011; #10; // 3
    SW = 4'b0101; #10; // 5
    SW = 4'b0111; #10; // 7
    SW = 4'b1011; #10; // 11
    SW = 4'b1101; #10; // 13
    SW = 4'b1111; #10;

    $finish;
end

endmodule

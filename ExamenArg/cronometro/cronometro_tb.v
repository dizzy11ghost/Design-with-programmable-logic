`timescale 1ns/1ps

module cronometro_tb;
reg clk;
reg clk_fast;
reg rst;
reg start_stop;
reg enable;

wire [9:0] counter;

cronometro DUT(
    .clk(clk),
    .clk_fast(clk_fast),
    .rst(rst),
    .start_stop(start_stop),
    .enable(enable),
    .counter(counter)
);

initial begin
    clk_fast = 0;
    forever #5 clk_fast = ~clk_fast;
end

initial begin
    clk = 0;
    forever #50 clk = ~clk; 
end

initial begin
    $dumpfile("cronometro_tb.vcd");
    $dumpvars(0, cronometro_tb);

    rst = 1;
    start_stop = 0;
    enable = 0;
    #100
    rst = 0;
    enable = 1;
    #100
    start_stop = 1;
    #70
    start_stop = 0;
    #1000
    start_stop = 1;
    #70
    start_stop = 0;
    #500
    start_stop = 1;
    #70
    start_stop = 0;
    #1000
    rst = 1;
    #50
    rst = 0;
    #500
    $stop;

end

endmodule

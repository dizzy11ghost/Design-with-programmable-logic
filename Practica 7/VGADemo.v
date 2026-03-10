module VGADemo(
    input MAX10_CLK1_50, // Clock input
    output reg [2:0 ] pixel, 
    output hysnc_out,
    output vsync_out
);
wire inDisplayArea;
wire [9:0] CounterX;
wire [9:0] CounterY;

//clk enable
reg pixel_tick = 0;

always @(posedge MAX10_CLK1_50) begin
    pixel_tick <= ~pixel_tick; // Toggle pixel_tick every clock cycle to create a slower enable signal
end

hysync_generator hvsync_gen (
    .clk(MAX10_CLK1_50),
    .pixel_tick(pixel_tick),
    .vga_h_sync(hysnc_out),
    .vga_v_sync(vsync_out),
    .inDisplayArea(inDisplayArea),
    .CounterX(CounterX),
    .CounterY(CounterY)
);

always @(posedge MAX10_CLK1_50) begin
    if (inDisplayArea)
        //chess board patter
        pixel <= ((CounterX[5] ^ CounterY[5]) ? 3'b111 : 3'b000); 
    else
        pixel <= 3'b000; // Black outside the display area 
end


endmodule
//Este modulo sirve para tener los leds de cada número funcionando, 
//lo vamos a instanciar más tarde para que le sirva a display.
module BCD_module(
    input[3:0] bcd_in,
    output reg [0:6] bcd_out  // [0:6] es segmento a-g
);
    always @(*)
    begin
        case(bcd_in)
			0: bcd_out = ~7'b1111_110; 
			1: bcd_out = ~7'b0110_000; 
			2: bcd_out = ~7'b1101_101; 
			3: bcd_out = ~7'b1111_001; 
			4: bcd_out = ~7'b0110_011; 
			5: bcd_out = ~7'b1011_011; 
			6: bcd_out = ~7'b1011_111; 
			7: bcd_out = ~7'b1110_000; 
			8: bcd_out = ~7'b1111_111; 
			9: bcd_out = ~7'b1111_011; 
			default: bcd_out = ~7'b0000_000; 
		endcase
    end
endmodule
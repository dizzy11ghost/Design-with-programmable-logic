module BCD_module(
    input[3:0] bcd_in, //hay 4 bits 
    output reg [0:6] bcd_out //son 6 segmentos para el display de 7 segmentos

    );
    always @(*)
    begin
        case(bcd_in)
            4'b0000: bcd_out = ~7'b1111110; //0
            4'b0001: bcd_out = ~7'b0110000; //1
            4'b0010: bcd_out = ~7'b1101101; //2
            4'b0011: bcd_out = ~7'b1111001; //3
            4'b0100: bcd_out = ~7'b0110011; //4
            4'b0101: bcd_out = ~7'b1011011; //5   
            4'b0110: bcd_out = ~7'b1011111; //6
            4'b0111: bcd_out = ~7'b1110000; //7
            4'b1000: bcd_out = ~7'b1111111; //8
            4'b1001: bcd_out = ~7'b1111011; //9
            4'b1010: bcd_out = ~7'b1110111; //A
            4'b1011: bcd_out = ~7'b0011111; //B
            4'b1100: bcd_out = ~7'b1001110; //C
            4'b1101: bcd_out = ~7'b0111101; //D
            4'b1110: bcd_out = ~7'b1001111; //E
            4'b1111: bcd_out = ~7'b1000111; //F

        endcase
    end   
endmodule
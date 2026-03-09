`timescale 1ns/1ps
module password_tb;
	reg MAX10_CLK1_50;
    reg [0:0] SW;
    reg [1:0] KEY;
    wire [6:0] HEX0, HEX1, HEX2, HEX3;

	top DUT( //ponemos lo mismo que esta declarado al principio del top
		.MAX10_CLK1_50(MAX10_CLK1_50),
		.SW(SW),
		.KEY(KEY),
		.HEX0(HEX0),
		.HEX1(HEX1),
		.HEX2(HEX2),
		.HEX3(HEX3)	
	);
	
	always #10 MAX10_CLK1_50 = ~MAX10_CLK1_50; //reloj de 50 MHz
	
	initial begin
		$dumpfile("password_tb.vcd");
		$dumpvars(0, password_tb);
	end
	
	initial begin
		//inicializamos variables en 0!
		MAX10_CLK1_50 = 0;
        SW  = 0; 
		KEY = 2'b11;
		
		//reset
		#100
		KEY[0] = 0;
		#200
		KEY[0] = 1;
		
		//Ingreso de contraseña
		#200
		SW =1; //D1 = 1
		#200
		KEY [1] = 0; //ENTER
		#200
		KEY[1] = 1;
		
		#100
		SW =0; //D2 = 0
		#200
		KEY [1] = 0; //ENTER
		#200
		KEY[1] = 1;
		
		#100
		SW =1; //D3 = 1
		#200
		KEY [1] = 0; //ENTER
		#200
		KEY[1] = 1;
		
		#100
		SW =0; //D4 = 0
		#200
		KEY [1] = 0; //ENTER
		#200
		KEY[1] = 1;
		
		#100
		SW =0; //D1 = 0
		#200
		KEY [1] = 0; //ENTER
		#200
		KEY[1] = 1;
		#700
		
		$finish;
	end
endmodule	
	
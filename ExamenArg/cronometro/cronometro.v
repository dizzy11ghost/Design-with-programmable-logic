module cronometro(
	input clk,
	input clk_fast, //para poder detectar el botón
	input rst,
   input start_stop, //para e,pezar o parar de contar
   input enable,
	output reg [5:0] counter
);

	reg running;
  //este primer always es para start y stop!! asi cambiamos el estado de running
	always @(posedge clk or posedge rst) begin
		if (rst)
			running <= 0;
		else if(start_stop)
			running <= ~running;
	end
	
	//contador
	always @(posedge clk or posedge rst)
    begin
        if(rst)
            counter <= 0;
        else if(running  && enable)
        begin
            if(counter == 999)
                counter <= 0;
            else
                counter <= counter + 1;
        end
    end
		
endmodule

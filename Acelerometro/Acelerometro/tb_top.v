`timescale 1ns/1ps

module tb_top;
//señales
reg clk;
reg [1:0] KEY;
//salidas pensadas para evitar warnings, por ahora el objetivo es probar la lógica de estados y memoria
wire        GSENSOR_CS_N;
wire [2:1]  GSENSOR_INT;
wire        GSENSOR_SCLK;
wire        GSENSOR_SDI, GSENSOR_SDO;
wire [9:0]  ARDUINO_IO;

//then again, no voy a probar accel ni pll, por ahora sólo FSM, counter y RAM
//señales internas a probar
wire ram_we;
wire counter_en;
wire [2:0] ram_addr;
wire [1:0] fsm_state;
wire load = ~KEY[1];

//simulación de los datos fijos del acelerometro
wire [47:0] ram_data_in = hAABBCC112233;
wire [47:0] ram_data_out;

fsm statesDUT(
    .MAX10_CLK1_50 (clk),
    .KEY (KEY),
    .load(load),
    .write_enable (ram_we),
    .counter_enable(counter_en),
    .current_state(fsm_state)
);

counter contramDUT(
    .clk(clk),
	.rst(~KEY[0]),
	.enable(counter_enable),
	.addr ram_addr
);

memory_RAM ramDUT(.NBITS(48), .NAddr(3))(
    .clk(clk), 
    .rst_a(~KEY[0]),
	.wr_en(write_enable),
	.Data_in(ram_data_in),
	.Data_address(ram_addr),
	.Data_out(ram_data_out);
);

//archivo para la simulación en gtkwave
initial begin
	$dumpfile("tb_top.vcd");
	$dumpvars(0, tb_top);
end

initial clk = 0;
always #10 clk = ~clk; //reloj de 50MHz 
    
//monitor
initial
begin
	$monitor("[%0t ns] state=%0d | we=%b | ce=%b | addr=%0d | ram=0x%h",
              $time, fsm_state, ram_we, counter_en, ram_addr, ram_data_out);

end

intinial begin
    KEY = 2'b11;
    #20;

    //prueba 1 - reset S0
    KEY [0] = 0;
    #100;
    KEY[0] = 1;
    #100; //para ver si regresa al estado S0 con el reset

   //display de resultados
    if (fsm_state == 0)
        $display("pass - from S0 to", fsm_State);
    else
         $display("pass - from S0 to", fsm_State);

    //prueba 2 - estado manual
    KEY[1] = 1; //posición nula, indica estado manual activo
    #100; //esperamos

    //display de resultados
        if (fsm_state == 1)
            $display("pass - from S1 to", fsm_State);
        else
            $display("pass - from S1 to", fsm_State);

    //prueba 3 - load 
    KEY[1] = 0; //hay carga de coords para automático
    #100;

    //display de resultados
    if (fsm_state == 2'd2)
        $display("pass - from S1 to", fsm_State);
    else
         $display("pass - from S1 to", fsm_State);

    //vemos si si se escribió en la ram
    //display de resultados
    if (ram_we == 1'b1 && counter_en == 0)
        $display("pass - write_enable = 1, counter_enable = 0 sin load");
    else
         $display(FAIL);
    
    //prueba 3.4 carga de datos por load
    KEY[1] = 0;
    #40
    KEY[1] = 1;
    #40;

    $display("addr=%0d | ram=0x%h", ram_addr, ram_data_out);
    KEY[1] = 0;
    #40
    KEY[1] = 1;
    #40;
    $display("addr=%0d | ram=0x%h", ram_addr, ram_data_out);
    
    KEY[1] = 0;
    #40
    KEY[1] = 1;
    #40;
    $display("addr=%0d | ram=0x%h", ram_addr, ram_data_out);
    
    KEY[1] = 0;
    #40
    KEY[1] = 1;
    #40;
    $display("addr=%0d | ram=0x%h", ram_addr, ram_data_out);
    
    KEY[1] = 0;
    #40
    KEY[1] = 1;
    #40;
    $display("addr=%0d | ram=0x%h", ram_addr, ram_data_out);

    #50;
    //display de resultados
    if (fsm_state == 2'd3)
        $display("pass - from S2 to ", fsm_State);
    else
         $display("pass - from S2 to", fsm_State);

    // prueba 4 — counter_enable=1, contador de la ram para modo automático 

    if (counter_en === 1'b1 && ram_we === 1'b0) //=== es para igualdad de caso
        $display("pass — counter_enable=1, write_enable=0");
    else
        $display("fail — ce=%b we=%b (esperado 1 0)", counter_en, ram_we);

    #200;
    $display("address tras avance automatico=%0d", ram_addr);

    //prueba 5 de estado automático a IDLE
    KEY[0] = 0;
    #100;
    KEY[0] = 1;
    #50;

    if (fsm_state === 2'd0)
        $display("pass — S0 IDLE tras reset desde S3");
    else
        $display("fail — esperado S0, obtenido state=%0d", fsm_state);

    $display("\n=== fin de la simulación :P ===");
    $finish;
end

endmo


endmodule
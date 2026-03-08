module top(
   input MAX10_CLK1_50,
   input  [1:0]   KEY,
   //SPI acelerómetro
   output GSENSOR_CS_N,
   input [2:1] GSENSOR_INT,
   output GSENSOR_SCLK,
   inout GSENSOR_SDI,
   inout GSENSOR_SDO,
   //salidas PWM
   output [9:0] ARDUINO_IO
);
    //datos crudos del acelerómetro
    wire [15:0] raw_x, raw_y, raw_z //nota agregar y2!

    //para el manejo de la RAM
    wire ram_we; //write enable para la RAM
    wire counter_en; //enable counter
    wire [2:0] ram_addr;//salida del contador, dirección de la RAM
    wire [1:0] fsm_state; //estado actual de la fsm

    //bus de datos para la RAM (3 ejes de 16 bits, 48 bits)
    wire [47:0] ram_data_in;
    wire [47:0] ram_data_out;
    assign ram_data_in = {angle_x, angle_y, angle_z};

    wire [15:0] ram_x = ram_data_out[47:32]; //para el modo automático! primer bloque de datos que contiene x
    wire [15:0] ram_y = ram_data_out[31:16]; //segundo bloque de datos que contiene y
    wire [15:0] ram_z = ram_data_out[15:0]; //tercer bloque de datos que contiene z
    wire [7:0] auto_angle_X, auto_angle_y, auto_angle_z //ángulos convertidos a 0-180 para el modo automático
    wire [7:0] mapped_auto_y2 = 8'd180 - auto_angle_y; //CHECAR ESTO!!!! SOLUCIÓN DE MIENTRAS PERO HAY QUE CHECAR DO NOT FORGET!!!
    
    wire pwm_man_x, pwm_man_y, pwm_man_y2, pwm_man_z; //señales pwm para modo manual
    wire pwm_auto_x, pwm_auto_y, pwm_auto_y2, pwm_auto_z; //señales pwm para modo automático

    wire load = ~KEY[1];

    //instanciamos los módulos!!
	accel WRAP(
        .clk(MAX10_CLK1_50), 
        .rst(KEY[0]), 
        .sensor(GSENSOR_CS_N), 
        .sensor_int(GSENSOR_INT), 
        .sensor_sclk(GSENSOR_SCLK), 
        .sensor_sdi(GSENSOR_SDI), 
        .sensor_sdo(GSENSOR_SDO), 

        //datos crudos para RAM
        .raw_x(raw_x),
        .raw_y(raw_y),
        .raw_z(raw_z),

		.pwm_out_x(pwm_man_x), .pwm_out_y_1(pwm_man_y1), .pwm_out_y_2(pwm_man_y2), .pwm_out_z(pwm_man_z)); 

    fsm states(
        .MAX10_CLK1_50 (MAX10_CLK1_50),
        .KEY(KEY),              // KEY[0]=reset, KEY[1]=mode_select
        .load(load),             // botón para guardar posición
        .write_enable(ram_we),
        .counter_enable(counter_en),
        .current_state (fsm_state) //para ver el estado actual 
    );

    counter cntram (
        .clk(MAX10_CLK_50),
	    .rst(~KEY[0]),
	    .enable(counter_en),
        .addr(ram_addr)
    );

    memory_RAM #(.NBits(48), .NAddr(3)) ram (
        .clk(MAX10_CLK_50),
        .rst_a(KEY [0]),
        .wr_en(ram_we),
        .Data_in(ram_data_in),
        .Data_address(ram_addr),
        .Data_out(ram_data_out)
    );

    //conversores RAM - ángulo para modo automático
    converter conv_x (.coord(ram_x), .angle(auto_angle_x));
    converter conv_y (.coord(ram_y), .angle(auto_angle_y));
    converter conv_z (.coord(ram_z), .angle(auto_angle_z));

    //PWM en modo automático
    pwm #(.MIN(2), .MAX(13)) pwm_ax  (.clk(clk_0), .rst_p(~KEY[0]), .pwm_in(auto_angle_x),   .pwm_out(pwm_auto_x));
    pwm #(.MIN(2), .MAX(11)) pwm_ay1 (.clk(clk_0), .rst_p(~KEY[0]), .pwm_in(auto_angle_y),   .pwm_out(pwm_auto_y1));
    pwm #(.MIN(2), .MAX(11)) pwm_ay2 (.clk(clk_0), .rst_p(~KEY[0]), .pwm_in(mapped_auto_y2), .pwm_out(pwm_auto_y2));
    pwm #(.MIN(2), .MAX(13)) pwm_az  (.clk(clk_0), .rst_p(~KEY[0]), .pwm_in(auto_angle_z),   .pwm_out(pwm_auto_z));

    //MUX S3 automático, cualquier otro estado es manual
    localparam S3 = 2'd3;

    assign ARDUINO_IO[0] = (fsm_state == S3) ? pwm_auto_x   : pwm_man_x;
    assign ARDUINO_IO[1] = (fsm_state == S3) ? pwm_auto_y1  : pwm_man_y1;
    assign ARDUINO_IO[2] = (fsm_state == S3) ? pwm_auto_y2  : pwm_man_y2;
    assign ARDUINO_IO[3] = (fsm_state == S3) ? pwm_auto_z   : pwm_man_z;

    assign ARDUINO_IO[9:4] = 6'b0;   // pines sin usar, en bajo

endmodule


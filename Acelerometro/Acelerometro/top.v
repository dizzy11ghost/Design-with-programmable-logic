module top(
    input MAX10_CLK1_50,
    input [1:0] KEY,
    input [9:0] SW,
    output GSENSOR_CS_N,
    input [2:1] GSENSOR_INT,
    output GSENSOR_SCLK,
    inout GSENSOR_SDI,
    inout GSENSOR_SDO,
    output [9:0] ARDUINO_IO,
    output [0:0] LEDR,
	 output [3:0] VGA_R,
	 output [3:0] VGA_G,
	 output [3:0] VGA_B,
	 output VGA_HS,
	 output VGA_VS
);
    // Reloj
    wire clk_0;
    clk_divider #(.FREQ(25_000_000)) clk_div_pwm (
        .clk    (MAX10_CLK1_50),
        .rst    (~KEY[0]),
        .clk_div(clk_0)
    );
    wire clk_50hz, clk_60hz;
    clk_divider #(.FREQ(50)) clk_div_50 (
        .clk    (MAX10_CLK1_50),
        .rst    (~KEY[0]),
        .clk_div(clk_50hz)
    );
    clk_divider #(.FREQ(60)) clk_div_60 (
        .clk    (MAX10_CLK1_50),
        .rst    (~KEY[0]),
        .clk_div(clk_60hz)
    );

    wire [15:0] raw_x, raw_y, raw_z;

    wire ram_we, counter_en;
    wire [2:0] ram_addr;
    wire [1:0] fsm_state;
    wire loop_mode = (fsm_state == 2'd3);

    // Salidas mapeadas de accel 
    wire [7:0] mapped_out_x, mapped_out_y1, mapped_out_y2, mapped_out_z;

    //garra en modo manual 
    wire garra;
    assign garra = SW[9];
    wire [7:0] pwm_garra_out;
    reg  [7:0] pwm_garra;


    // RAM de 40 bits
    wire [31:0] ram_data_in  = {mapped_out_x, mapped_out_y1, mapped_out_y2, mapped_out_z};
    wire [31:0] ram_data_out;
    wire [7:0] ram_angle_x  = ram_data_out[39:32];
    wire [7:0] ram_angle_y1 = ram_data_out[31:24];
    wire [7:0] ram_angle_y2 = ram_data_out[23:16];
    wire [7:0] ram_angle_z  = ram_data_out[15:8];
    wire [7:0] ram_garra = ram_data_out [7:0];

    // Smooth 
    reg [7:0] smooth_auto_x, smooth_auto_y1, smooth_auto_y2, smooth_auto_z, smooth_auto_garra;

    wire pwm_man_x, pwm_man_y1, pwm_man_y2, pwm_man_z;
    wire pwm_auto_x, pwm_auto_y1, pwm_auto_y2, pwm_auto_z;

    // Instancias
    accel WRAP(
        .clk          (MAX10_CLK1_50),
        .rst          (KEY[0]),
        .sensor       (GSENSOR_CS_N),
        .sensor_int   (GSENSOR_INT),
        .sensor_sclk  (GSENSOR_SCLK),
        .sensor_sdi   (GSENSOR_SDI),
        .sensor_sdo   (GSENSOR_SDO),
        .raw_x        (raw_x),
        .raw_y        (raw_y),
        .raw_z        (raw_z),
        .mapped_out_x (mapped_out_x),
        .mapped_out_y1(mapped_out_y1),
        .mapped_out_y2(mapped_out_y2), 
        .mapped_out_z (mapped_out_z),
        .pwm_out_x    (pwm_man_x),
        .pwm_out_y_1  (pwm_man_y1),
        .pwm_out_y_2  (pwm_man_y2),
        .pwm_out_z    (pwm_man_z)
    );

    fsm states(
        .MAX10_CLK1_50 (MAX10_CLK1_50),
        .KEY           (KEY),
        .sw_auto       (SW[1]),
        .done          (LEDR[0]),
        .write_enable  (ram_we),
        .counter_enable(counter_en),
        .current_state (fsm_state)
    );

    counter cntram(
        .clk      (MAX10_CLK1_50),
        .rst      (~KEY[0]),
        .enable   (counter_en),
        .loop_mode(loop_mode),
        .addr     (ram_addr)
    );

    // RAM de 32 bits con 4 ejes
    memory_RAM #(.NBits(40), .NAddr(4)) ram(
        .clk         (MAX10_CLK1_50),
        .rst_a       (KEY[0]),
        .wr_en       (ram_we),
        .Data_in     (ram_data_in),
        .Data_address(ram_addr),
        .Data_out    (ram_data_out)
    );
	 
	// Rampa
    always @(posedge clk_60hz) begin
        if (smooth_auto_x < ram_angle_x)
            smooth_auto_x <= smooth_auto_x + 1;
        else if (smooth_auto_x > ram_angle_x)
            smooth_auto_x <= smooth_auto_x - 1;
    end

    always @(posedge clk_60hz) begin
        if (smooth_auto_y1 < ram_angle_y1)
            smooth_auto_y1 <= smooth_auto_y1 + 1;
        else if (smooth_auto_y1 > ram_angle_y1)
            smooth_auto_y1 <= smooth_auto_y1 - 1;
    end

    always @(posedge clk_60hz) begin
        if (smooth_auto_y2 < ram_angle_y2)
            smooth_auto_y2 <= smooth_auto_y2 + 1;
        else if (smooth_auto_y2 > ram_angle_y2)
            smooth_auto_y2 <= smooth_auto_y2 - 1;
    end

    always @(posedge clk_60hz) begin
        if (smooth_auto_z < ram_angle_z)
            smooth_auto_z <= smooth_auto_z + ((ram_angle_z - smooth_auto_z) >> 3);
        else if (smooth_auto_z > ram_angle_z)
            smooth_auto_z <= smooth_auto_z - ((smooth_auto_z - ram_angle_z) >> 3);
    end
	 
    always @(posedge clk_60hz) begin
        if (smooth_auto_garra < ram_garra) 
        smooth_auto_garra <= smooth_auto_garra + 1;
    else if (smooth_auto_garra > ram_garra)
        smooth_auto_garra <= smooth_auto_garra - 1;
    end
	 always @(posedge clk_60hz) begin
		if (garra)
			pwm_garra <= 90;
		else 
			pwm_garra <= 0;
	end

    localparam S3 = 2'd3;
    //si esta en modo manual, toma la entrada del sw 9, en modo automático toma smooth_auto_garra
    always @(posedge clk_60hz) begin
        if (fsm_state == S3)
            pwm_garra <= smooth_auto_garra;
        else if (garra)
            pwm_garra <= 90;
        else
            pwm_garra <= 0;
    end


	// PWM automático
    pwm #(.MIN(2), .MAX(13)) pwm_ax(
        .clk    (clk_0),
        .rst_p  (~KEY[0]),
        .pwm_in (smooth_auto_x), 
        .pwm_out(pwm_auto_x));

    pwm #(.MIN(2), .MAX(11)) pwm_ay1(
        .clk    (clk_0),
        .rst_p  (~KEY[0]),
        .pwm_in (smooth_auto_y1), 
        .pwm_out(pwm_auto_y1));

    pwm #(.MIN(2), .MAX(11)) pwm_ay2(
        .clk    (clk_0),
        .rst_p  (~KEY[0]),
        .pwm_in (smooth_auto_y2),  
        .pwm_out(pwm_auto_y2));

    pwm #(.MIN(2), .MAX(13)) pwm_az(
        .clk    (clk_0),
        .rst_p  (~KEY[0]),
        .pwm_in (smooth_auto_z),  
        .pwm_out(pwm_auto_z));
	 pwm #(.MIN(2), .MAX(10)) pwm_garra_h(
        .clk    (clk_0),
        .rst_p  (~KEY[0]),
        .pwm_in (pwm_garra),  
        .pwm_out(pwm_garra_out));
		  

	// Multiplexor 
	 wire [7:0] VGA_angle_x, VGA_angle_y, VGA_angle_y2, VGA_angle_z;
	 wire mode;
	 assign mode = (fsm_state == S3) ? 1 : 0; 
	 assign VGA_angle_x = (fsm_state == S3) ? smooth_auto_x : mapped_out_x;
    assign VGA_angle_y = (fsm_state == S3) ? smooth_auto_y1 : mapped_out_y1;
    assign VGA_angle_y2 = (fsm_state == S3) ? smooth_auto_y2 :mapped_out_y2;
    assign VGA_angle_z = (fsm_state == S3) ? smooth_auto_z : mapped_out_z;
    assign ARDUINO_IO[0] = (fsm_state == S3) ? pwm_auto_x   : pwm_man_x;
    assign ARDUINO_IO[1] = (fsm_state == S3) ? pwm_auto_y1  : pwm_man_y1;
    assign ARDUINO_IO[2] = (fsm_state == S3) ? pwm_auto_y2  : pwm_man_y2;
    assign ARDUINO_IO[3] = (fsm_state == S3) ? pwm_auto_z   : pwm_man_z;
	 assign ARDUINO_IO[4] = pwm_garra_out;
	 
	 //VGA
	 wire [2:0] pixel;
	 
    VGACounterDemo VGA(
        .MAX10_CLK1_50(MAX10_CLK1_50),
        .pixel(pixel),
		  .angle_x(VGA_angle_x),
		  .angle_y(VGA_angle_y),
		  .angle_y2(VGA_angle_y2),
		  .angle_z(VGA_angle_z),
        .hsync_out(VGA_HS),
        .vsync_out(VGA_VS),
		  .mode (mode)
    );
	
	assign VGA_R = {4{pixel[2]}};
	assign VGA_G = {4{pixel[1]}};
	assign VGA_B = {4{pixel[0]}};
	 
endmodule
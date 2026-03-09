module top(
    input MAX10_CLK1_50,
    input [1:0] KEY,
    input [1:0] SW,
    output GSENSOR_CS_N,
    input [2:1] GSENSOR_INT,
    output GSENSOR_SCLK,
    inout GSENSOR_SDI,
    inout GSENSOR_SDO,
    output [9:0] ARDUINO_IO,
    output [0:0] LEDR
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

    // RAM de 32 bits
    wire [31:0] ram_data_in  = {mapped_out_x, mapped_out_y1, mapped_out_y2, mapped_out_z};
    wire [31:0] ram_data_out;
    wire [7:0] ram_angle_x  = ram_data_out[31:24];
    wire [7:0] ram_angle_y1 = ram_data_out[23:16];
    wire [7:0] ram_angle_y2 = ram_data_out[15:8];
    wire [7:0] ram_angle_z  = ram_data_out[7:0];

    // Smooth 
    reg [7:0] smooth_auto_x, smooth_auto_y1, smooth_auto_y2, smooth_auto_z;

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
    memory_RAM #(.NBits(32), .NAddr(3)) ram(
        .clk         (MAX10_CLK1_50),
        .rst_a       (KEY[0]),
        .wr_en       (ram_we),
        .Data_in     (ram_data_in),
        .Data_address(ram_addr),
        .Data_out    (ram_data_out)
    );
	// Rampa
    always @(posedge clk_50hz) begin
        if      (smooth_auto_x < ram_angle_x)
            smooth_auto_x <= smooth_auto_x + ((ram_angle_x - smooth_auto_x) >> 3);
        else if (smooth_auto_x > ram_angle_x)
            smooth_auto_x <= smooth_auto_x - ((smooth_auto_x - ram_angle_x) >> 3);
    end

    always @(posedge clk_60hz) begin
        if      (smooth_auto_y1 < ram_angle_y1)
            smooth_auto_y1 <= smooth_auto_y1 + ((ram_angle_y1 - smooth_auto_y1) >> 3);
        else if (smooth_auto_y1 > ram_angle_y1)
            smooth_auto_y1 <= smooth_auto_y1 - ((smooth_auto_y1 - ram_angle_y1) >> 3);
    end

    always @(posedge clk_60hz) begin
        if      (smooth_auto_y2 < ram_angle_y2)
            smooth_auto_y2 <= smooth_auto_y2 + ((ram_angle_y2 - smooth_auto_y2) >> 3);
        else if (smooth_auto_y2 > ram_angle_y2)
            smooth_auto_y2 <= smooth_auto_y2 - ((smooth_auto_y2 - ram_angle_y2) >> 3);
    end

    always @(posedge clk_50hz) begin
        if      (smooth_auto_z < ram_angle_z)
            smooth_auto_z <= smooth_auto_z + ((ram_angle_z - smooth_auto_z) >> 3);
        else if (smooth_auto_z > ram_angle_z)
            smooth_auto_z <= smooth_auto_z - ((smooth_auto_z - ram_angle_z) >> 3);
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

	// Multiplexor 
    localparam S3 = 2'd3;
    assign ARDUINO_IO[0] = (fsm_state == S3) ? pwm_auto_x   : pwm_man_x;
    assign ARDUINO_IO[1] = (fsm_state == S3) ? pwm_auto_y1  : pwm_man_y1;
    assign ARDUINO_IO[2] = (fsm_state == S3) ? pwm_auto_y2  : pwm_man_y2;
    assign ARDUINO_IO[3] = (fsm_state == S3) ? pwm_auto_z   : pwm_man_z;
    assign ARDUINO_IO[9:4] = 6'b0;

endmodule

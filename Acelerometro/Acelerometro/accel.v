module accel (
	input clk_10,
	input clk,
	input clk_2,
	input	rst,
	output sensor,
	input [2:1] sensor_int,
	output sensor_sclk,
	inout sensor_sdi,
	inout sensor_sdo,
	output pwm_out_x, pwm_out_y_1, pwm_out_y_2, pwm_out_z,
   output wire [15:0] raw_x,
   output wire [15:0] raw_y,
   output wire [15:0] raw_z
);

// Parámetros
   localparam SPI_CLK_FREQ = 200;
   localparam UPDATE_FREQ  = 1;
   localparam IN_MIN  = 7;
   localparam IN_MAX  = 173;
   localparam OUT_MIN = 0;
   localparam OUT_MAX = 180;
	localparam Z_IN_MIN  = 5;
	localparam Z_IN_MAX  = 170;

// Señales
   wire clk_0, spi_clk, spi_clk_out;
   wire data_update;
   wire [15:0] data_x, data_y, data_z;

// PLL
PLL ip_inst (
   .inclk0     (clk),
   .c0         (clk_0),
   .c1         (spi_clk),
   .c2         (spi_clk_out)
);

// SPI / Acelerómetro
spi_control #(
      .SPI_CLK_FREQ (SPI_CLK_FREQ),
      .UPDATE_FREQ  (UPDATE_FREQ))
   spi_ctrl (
      .reset_n     (rst),
      .clk         (clk_0),
      .spi_clk     (spi_clk),
      .spi_clk_out (spi_clk_out),
      .data_update (data_update),
      .data_x      (data_x),
      .data_y      (data_y),
      .data_z      (data_z),
      .SPI_SDI     (sensor_sdi),
      .SPI_SDO     (sensor_sdo),
      .SPI_CSN     (sensor),
      .SPI_CLK     (sensor_sclk),
      .interrupt   (sensor_int)
);

// Relojes
wire clk_2_hz, clk_60_Hz, clk_50_hz;

clk_divider #(.FREQ(2)) DIVISOR_REFRESH (
   .clk    (clk),
   .rst    (~rst),
   .clk_div(clk_2_hz)
);

clk_divider #(.FREQ(50)) DIVISOR (
   .clk    (clk),
   .rst    (~rst),
   .clk_div(clk_50_hz)
);

clk_divider #(.FREQ(60)) DIVISOR_60 (
   .clk    (clk),
   .rst    (~rst),
   .clk_div(clk_60_hz)
);

//Muestreo de datos
reg [15:0] data_x_reg, data_y_reg_1, data_y_reg_2, data_z_reg;

//datos crudos que nos servirán para el modo automático
assign raw_x = data_x_reg;
assign raw_y = data_y_reg_1;
assign raw_z = data_z_reg; 

always @(posedge clk_2_hz) begin
   data_x_reg <= data_x;
   data_y_reg_1 <= data_y;
	data_y_reg_2 <= data_y;
   data_z_reg <= data_z;
end

//Converter: raw → ángulo 0-180
wire [7:0] angle_x, angle_y_1, angle_y_2, angle_z;

converter conv_x (.coord(data_x_reg), .angle(angle_x));
converter conv_y_1 (.coord(data_y_reg_1), .angle(angle_y_1));
converter conv_y_2 (.coord(data_y_reg_2), .angle(angle_y_2));
converter conv_z (.coord(data_z_reg), .angle(angle_z));

// Rampa / filtro exponencial
reg [7:0] smooth_x, smooth_y_1, smooth_y_2, smooth_z;

always @(posedge clk_50_hz) begin
   if      
		(smooth_x < angle_x) smooth_x <= smooth_x + ((angle_x - smooth_x) >> 3);
   else if 
		(smooth_x > angle_x) smooth_x <= smooth_x - ((smooth_x - angle_x) >> 3);
end

always @(posedge clk_60_hz) begin
   if      
		(smooth_y_1 < angle_y_1) smooth_y_1 <= smooth_y_1 + ((angle_y_1 - smooth_y_1) >> 5);
   else if 
		(smooth_y_1 > angle_y_1) smooth_y_1 <= smooth_y_1 - ((smooth_y_1 - angle_y_1) >> 5);
end

always @(posedge clk_60_hz) begin
   if      
		(smooth_y_2 < angle_y_2) smooth_y_2 <= smooth_y_2 + ((angle_y_2 - smooth_y_2) >> 5);
   else if 
		(smooth_y_2 > angle_y_2) smooth_y_2 <= smooth_y_2 - ((smooth_y_2 - angle_y_2) >> 5);
end

always @(posedge clk_50_hz) begin
   if      
		(smooth_z < angle_z) smooth_z <= smooth_z + ((angle_z - smooth_z) >> 4);
   else if 
		(smooth_z > angle_z) smooth_z <= smooth_z - ((smooth_z - angle_z) >> 4);
end



// Mapeo
wire [15:0] mapped_x, mapped_y_1, mapped_y_2, mapped_z;


assign mapped_x = ((smooth_x - IN_MIN) * (OUT_MAX - OUT_MIN)) / (IN_MAX - IN_MIN) + OUT_MIN;
assign mapped_y_1 = ((smooth_y_1 - IN_MIN) * (OUT_MAX - OUT_MIN)) / (IN_MAX - IN_MIN) + OUT_MIN;
assign mapped_y_2 = OUT_MAX - mapped_y_1;
assign mapped_z = ((Z_IN_MAX - smooth_z) * (OUT_MAX - OUT_MIN)) / (Z_IN_MAX - Z_IN_MIN);

// PWM → servos
pwm #(.MIN(2), .MAX(13)) pwm_x (
   .clk (clk_0),
   .rst_p (~rst),
   .pwm_in (mapped_x[7:0]),
   .pwm_out(pwm_out_x)
);

pwm #(.MIN(2), .MAX(11)) pwm_y_1 (
   .clk (clk_0),
   .rst_p (~rst),
   .pwm_in (mapped_y_1[7:0]),
   .pwm_out(pwm_out_y_1)
);

pwm #(.MIN(2), .MAX(11)) pwm_y_2 (
   .clk (clk_0),
   .rst_p (~rst),
   .pwm_in (mapped_y_2[7:0]),
   .pwm_out(pwm_out_y_2)
);

pwm #(.MIN(2), .MAX(13)) pwm_z (
   .clk (clk_0),
   .rst_p (~rst),
   .pwm_in (mapped_z[7:0]),
   .pwm_out(pwm_out_z)
);

endmodule
//===========================================================================
// accel.v
//===========================================================================

module accel (
   input          ADC_CLK_10,
   input          MAX10_CLK1_50,
   input          MAX10_CLK2_50,
   output [7:0]   HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
   input  [1:0]   KEY,
   output [9:0]   LEDR,
   input  [9:0]   SW,
   output         GSENSOR_CS_N,
   input  [2:1]   GSENSOR_INT,
   output         GSENSOR_SCLK,
   inout          GSENSOR_SDI,
   inout          GSENSOR_SDO,
   output [9:0]   ARDUINO_IO
);

//===== Parámetros
   localparam SPI_CLK_FREQ = 200;
   localparam UPDATE_FREQ  = 1;
   localparam IN_MIN  = 7;
   localparam IN_MAX  = 173;
   localparam OUT_MIN = 0;
   localparam OUT_MAX = 180;
	localparam Z_IN_MIN  = 5;
	localparam Z_IN_MAX  = 170;

//===== Señales
   wire reset_n;
   wire clk, spi_clk, spi_clk_out;
   wire data_update;
   wire [15:0] data_x, data_y, data_z;

//===== PLL
PLL ip_inst (
   .inclk0     (MAX10_CLK1_50),
   .c0         (clk),
   .c1         (spi_clk),
   .c2         (spi_clk_out)
);

//===== SPI / Acelerómetro
spi_control #(
      .SPI_CLK_FREQ (SPI_CLK_FREQ),
      .UPDATE_FREQ  (UPDATE_FREQ))
   spi_ctrl (
      .reset_n     (reset_n),
      .clk         (clk),
      .spi_clk     (spi_clk),
      .spi_clk_out (spi_clk_out),
      .data_update (data_update),
      .data_x      (data_x),
      .data_y      (data_y),
      .data_z      (data_z),
      .SPI_SDI     (GSENSOR_SDI),
      .SPI_SDO     (GSENSOR_SDO),
      .SPI_CSN     (GSENSOR_CS_N),
      .SPI_CLK     (GSENSOR_SCLK),
      .interrupt   (GSENSOR_INT)
);

//===== Reset y relojes
assign reset_n = KEY[0];

wire clk_2_hz, clk_50_hz;

clk_divider #(.FREQ(2)) DIVISOR_REFRESH (
   .clk    (MAX10_CLK1_50),
   .rst    (~reset_n),
   .clk_div(clk_2_hz)
);

clk_divider #(.FREQ(50)) DIVISOR (
   .clk    (MAX10_CLK1_50),
   .rst    (~reset_n),
   .clk_div(clk_50_hz)
);

//Muestreo de datos
reg [15:0] data_x_reg, data_y_reg_1, data_y_reg_2, data_z_reg;

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

always @(posedge clk_50_hz) begin
   if      
		(smooth_y_1 < angle_y_1) smooth_y_1 <= smooth_y_1 + ((angle_y_1 - smooth_y_1) >> 3);
   else if 
		(smooth_y_1 > angle_y_1) smooth_y_1 <= smooth_y_1 - ((smooth_y_1 - angle_y_1) >> 3);
end

always @(posedge clk_50_hz) begin
   if      
		(smooth_y_2 < angle_y_2) smooth_y_2 <= smooth_y_2 + ((angle_y_2 - smooth_y_2) >> 3);
   else if 
		(smooth_y_2 > angle_y_2) smooth_y_2 <= smooth_y_2 - ((smooth_y_2 - angle_y_2) >> 3);
end

always @(posedge clk_50_hz) begin
   if      
		(smooth_z < angle_z) smooth_z <= smooth_z + ((angle_z - smooth_z) >> 3);
   else if 
		(smooth_z > angle_z) smooth_z <= smooth_z - ((smooth_z - angle_z) >> 3);
end

//===== Mapeo
wire [15:0] mapped_x, mapped_y_1, mapped_y_2, mapped_z;


assign mapped_x = ((smooth_x - IN_MIN) * (OUT_MAX - OUT_MIN)) / (IN_MAX - IN_MIN) + OUT_MIN;
assign mapped_y_1 = ((smooth_y_1 - IN_MIN) * (OUT_MAX - OUT_MIN)) / (IN_MAX - IN_MIN) + OUT_MIN;
assign mapped_y_2 = OUT_MAX - mapped_y_1;
assign mapped_z = ((Z_IN_MAX - smooth_z) * (OUT_MAX - OUT_MIN)) / (Z_IN_MAX - Z_IN_MIN);

//===== PWM → servos
pwm #(.MIN(2), .MAX(13)) pwm_x (
   .clk    (clk),
   .rst_p  (~reset_n),
   .pwm_in (mapped_x[7:0]),
   .pwm_out(ARDUINO_IO[0])
);

pwm #(.MIN(2), .MAX(13)) pwm_y_1 (
   .clk    (clk),
   .rst_p  (~reset_n),
   .pwm_in (mapped_y_1[7:0]),
   .pwm_out(ARDUINO_IO[1])
);

pwm #(.MIN(2), .MAX(13)) pwm_y_2 (
   .clk    (clk),
   .rst_p  (~reset_n),
   .pwm_in (mapped_y_2[7:0]),
   .pwm_out(ARDUINO_IO[2])
);

pwm #(.MIN(2), .MAX(13)) pwm_z (
   .clk    (clk),
   .rst_p  (~reset_n),
   .pwm_in (mapped_z[7:0]),
   .pwm_out(ARDUINO_IO[3])
);

endmodule
module top(
   input MAX10_CLK1_50,
   input  [0:0]   KEY,
   output GSENSOR_CS_N,
   input [2:1] GSENSOR_INT,
   output GSENSOR_SCLK,
   inout GSENSOR_SDI,
   inout GSENSOR_SDO,
   output [9:0] ARDUINO_IO
);

	accel WRAP(.clk(MAX10_CLK1_50), .rst(KEY[0]), .sensor(GSENSOR_CS_N), .sensor_int(GSENSOR_INT), .sensor_sclk(GSENSOR_SCLK), .sensor_sdi(GSENSOR_SDI), .sensor_sdo(GSENSOR_SDO), 
					.pwm_out_x(ARDUINO_IO[0]), .pwm_out_y_1(ARDUINO_IO[1]), .pwm_out_y_2(ARDUINO_IO[2]), .pwm_out_z(ARDUINO_IO[3]));
					
endmodule
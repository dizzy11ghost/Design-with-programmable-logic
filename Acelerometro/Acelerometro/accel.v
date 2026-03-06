//===========================================================================
// accel.v
//
// Template module to get the DE10-Lite's accelerator working very quickly.
//
//
//===========================================================================

module accel (
   //////////// CLOCK //////////
   input 		          		ADC_CLK_10,
   input 		          		MAX10_CLK1_50,
   input 		          		MAX10_CLK2_50,

   //////////// SEG7 //////////
   output		     [7:0]		HEX0,
   output		     [7:0]		HEX1,
   output		     [7:0]		HEX2,
   output		     [7:0]		HEX3,
   output		     [7:0]		HEX4,
   output		     [7:0]		HEX5,

   //////////// KEY //////////
   input 		     [1:0]		KEY,

   //////////// LED //////////
   output		     [9:0]		LEDR,

   //////////// SW //////////
   input 		     [9:0]		SW,

   //////////// Accelerometer ports //////////
   output		          		GSENSOR_CS_N,
   input 		     [2:1]		GSENSOR_INT,
   output		          		GSENSOR_SCLK,
   inout 		          		GSENSOR_SDI,
   inout 		          		GSENSOR_SDO,
	
	/////////// ARDUINO IO //////////////
	output [9:0] ARDUINO_IO
   );

//===== Declarations
   localparam SPI_CLK_FREQ  = 200;  // SPI Clock (Hz)
   localparam UPDATE_FREQ   = 1;    // Sampling frequency (Hz)

   // clks and reset
   wire reset_n;
   wire clk, spi_clk, spi_clk_out;

   // output data
   wire data_update;
   wire [15:0] data_x, data_y, data_z;

//===== Phase-locked Loop (PLL) instantiation. Code was copied from a module
//      produced by Quartus' IP Catalog tool.
PLL ip_inst (
   .inclk0 ( MAX10_CLK1_50 ),
   .c0 ( clk ),                 // 25 MHz, phase   0 degrees
   .c1 ( spi_clk ),             //  2 MHz, phase   0 degrees
   .c2 ( spi_clk_out )          //  2 MHz, phase 270 degrees
   );

//===== Instantiation of the spi_control module which provides the logic to 
//      interface to the accelerometer.
spi_control #(     // parameters
      .SPI_CLK_FREQ   (SPI_CLK_FREQ),
      .UPDATE_FREQ    (UPDATE_FREQ))
   spi_ctrl (      // port connections
      .reset_n    (reset_n),
      .clk        (clk),
      .spi_clk    (spi_clk),
      .spi_clk_out(spi_clk_out),
      .data_update(data_update),
      .data_x     (data_x),
      .data_y     (data_y),
		.data_z		(data_z),
      .SPI_SDI    (GSENSOR_SDI),
      .SPI_SDO    (GSENSOR_SDO),
      .SPI_CSN    (GSENSOR_CS_N),
      .SPI_CLK    (GSENSOR_SCLK),
      .interrupt  (GSENSOR_INT)
   );

//===== Main block
//      To make the module do something visible, the 16-bit data_x is 
//      displayed on four of the HEX displays in hexadecimal format.

// Pressing KEY0 resets the system
assign reset_n = KEY[0];  // Reset activo cuando se presiona la tecla

wire clk_2_hz;

clk_divider #(.FREQ(2)) DIVISOR_REFRESH 
(
.clk(MAX10_CLK1_50),
.rst(~reset_n),  
.clk_div(clk_2_hz)
);

reg [15:0] data_x_reg, data_y_reg, data_z_reg;

always @(posedge clk_2_hz)
begin
	data_x_reg = data_x/8;
	data_y_reg = data_y/8;
	data_z_reg = data_z/8;
end

wire [7:0] angle_x, angle_y, angle_z;

converter conv_x(
	.coord(data_x_reg),
	.angle(angle_x)
	);
	
converter conv_y(
	.coord(data_y_reg),
	.angle(angle_y)
	);
	
converter conv_z(
	.coord(data_z_reg),
	.angle(angle_z)
	);
	
pwm #(.MIN(5), .MAX(10)) pwm_x(
	.clk(clk),
	.rst_p(~reset_n),  
	.pwm_in(angle_x),
	.pwm_out(ARDUINO_IO[0])
	);

pwm #(.MIN(5), .MAX(10)) pwm_y(
	.clk(clk),
	.rst_p(~reset_n), 
	.pwm_in(angle_y),
	.pwm_out(ARDUINO_IO[1])
	);

pwm #(.MIN(5), .MAX(10)) pwm_z(
	.clk(clk),
	.rst_p(~reset_n),  
	.pwm_in(angle_z),
	.pwm_out(ARDUINO_IO[2])
	);
	

wire [3:0] unidades_x = angle_x %10;
wire [3:0] decenas_x = (angle_x/10)%10;
wire [3:0] centenas_x = angle_x /100;

wire [3:0] unidades_y = angle_y%10;
wire [3:0] decenas_y = (angle_y/10)%10;
wire [3:0] centenas_y = angle_y/100;

// 7-segment displays HEX0-3 show data_x in hexadecimal
seg7 s0 (
   .in      (unidades_x),
   .display (HEX0) );

seg7 s1 (
   .in      (decenas_x),
   .display (HEX1) );

seg7 s2 (
   .in      (centenas_x),
   .display (HEX2) );

seg7 s3 (
   .in      (unidades_y),
   .display (HEX3) );

// A few statements just to light some LEDs
seg7 s4 ( .in(decenas_y), .display(HEX4) );
seg7 s5 ( .in(centenas_y), .display(HEX5) );
assign LEDR = angle_z[7:0];
endmodule
module converter(
    input  wire signed [15:0] coord,
    output wire [7:0] angle
);
    localparam signed [15:0] SENSOR_MIN = -512;
    localparam signed [15:0] SENSOR_MAX =  512;
    localparam integer       SENSOR_RANGO = 1024;

    wire signed [15:0] coord_clamped;
    wire [31:0] scaled;

    
    assign coord_clamped = ($signed(coord) < SENSOR_MIN) ? SENSOR_MIN :
                           ($signed(coord) > SENSOR_MAX) ? SENSOR_MAX :
                           coord;

    assign scaled = (($signed(coord_clamped) + 512) * 32'd180) / SENSOR_RANGO;
    assign angle  = scaled[7:0];

endmodule
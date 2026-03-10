module converter(
    input  wire signed [15:0] coord,
    output wire [7:0] angle
);
    localparam signed [15:0] SENSOR_MIN = -270;
    localparam signed [15:0] SENSOR_MAX =  270;
    localparam integer SENSOR_RANGO = 540;
    
    wire signed [15:0] coord_clamped;
    wire signed [31:0] scaled; 
    
    assign coord_clamped = ($signed(coord) < SENSOR_MIN) ? SENSOR_MIN :
                           ($signed(coord) > SENSOR_MAX) ? SENSOR_MAX :
                           coord;

    assign scaled = ($signed(coord_clamped) + $signed(16'd270)) * $signed(32'd180) / $signed(32'd540);
    
    assign angle = scaled[7:0];
endmodule
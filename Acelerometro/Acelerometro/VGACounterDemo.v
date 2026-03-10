module VGACounterDemo(
    input MAX10_CLK1_50,
    input [7:0] angle_x,
    input [7:0] angle_y,
    input [7:0] angle_y2,
    input [7:0] angle_z,
    input mode,
    output reg [2:0] pixel,
    output hsync_out,
    output vsync_out
);

    wire inDisplayArea;
    wire [9:0] CounterX;
    wire [9:0] CounterY;

    reg pixel_tick = 0;
    always @(posedge MAX10_CLK1_50)
        pixel_tick <= ~pixel_tick;

    hvsync_generator hvsync(
        .clk(MAX10_CLK1_50),
        .pixel_tick(pixel_tick),
        .vga_h_sync(hsync_out),
        .vga_v_sync(vsync_out),
        .CounterX(CounterX),
        .CounterY(CounterY),
        .inDisplayArea(inDisplayArea)
    );


    // Dígitos

    wire [3:0] ax_d0, ax_d1, ax_d2;
    wire [3:0] ay_d0, ay_d1, ay_d2;
    wire [3:0] ay2_d0, ay2_d1, ay2_d2;
    wire [3:0] az_d0, az_d1, az_d2;

    assign ax_d0 = angle_x % 10;
    assign ax_d1 = (angle_x / 10) % 10;
    assign ax_d2 = (angle_x / 100) % 10;

    assign ay_d0 = angle_y % 10;
    assign ay_d1 = (angle_y / 10) % 10;
    assign ay_d2 = (angle_y / 100) % 10;

    assign ay2_d0 = angle_y2 % 10;
    assign ay2_d1 = (angle_y2 / 10) % 10;
    assign ay2_d2 = (angle_y2 / 100) % 10;

    assign az_d0 = angle_z % 10;
    assign az_d1 = (angle_z / 10) % 10;
    assign az_d2 = (angle_z / 100) % 10;

    // -------------------------------------------------------
    // ASCII
    // -------------------------------------------------------
    wire [7:0] ax_ascii0, ax_ascii1, ax_ascii2;
    wire [7:0] ay_ascii0, ay_ascii1, ay_ascii2;
    wire [7:0] ay2_ascii0, ay2_ascii1, ay2_ascii2;
    wire [7:0] az_ascii0, az_ascii1, az_ascii2;

    assign ax_ascii0 = ax_d0 + "0";
    assign ax_ascii1 = ax_d1 + "0";
    assign ax_ascii2 = ax_d2 + "0";

    assign ay_ascii0 = ay_d0 + "0";
    assign ay_ascii1 = ay_d1 + "0";
    assign ay_ascii2 = ay_d2 + "0";

    assign ay2_ascii0 = ay2_d0 + "0";
    assign ay2_ascii1 = ay2_d1 + "0";
    assign ay2_ascii2 = ay2_d2 + "0";

    assign az_ascii0 = az_d0 + "0";
    assign az_ascii1 = az_d1 + "0";
    assign az_ascii2 = az_d2 + "0";

    parameter MODE_X = 150;
    parameter MODE_Y = 220;  

    wire [3:0] mode_col;    
    wire [3:0] mode_row;

    assign mode_col = CounterX - MODE_X;
    assign mode_row = CounterY - MODE_Y;

    wire [3:0] mode_char_index;
    assign mode_char_index = (CounterX - MODE_X) >> 3;

    reg [7:0] mode_ascii;
    always @* begin
        if (mode == 0) begin
            case(mode_char_index)
                4'd0: mode_ascii = "M";
                4'd1: mode_ascii = "A";
                4'd2: mode_ascii = "N";
                4'd3: mode_ascii = "U";
                4'd4: mode_ascii = "A";
                4'd5: mode_ascii = "L";
                default: mode_ascii = " ";
            endcase
        end else begin
            case(mode_char_index)
                4'd0: mode_ascii = "A";
                4'd1: mode_ascii = "U";
                4'd2: mode_ascii = "T";
                4'd3: mode_ascii = "O";
                4'd4: mode_ascii = "M";
                4'd5: mode_ascii = "A";
                4'd6: mode_ascii = "T";
                4'd7: mode_ascii = "I";
                4'd8: mode_ascii = "C";
                4'd9: mode_ascii = "O";
                default: mode_ascii = " ";
            endcase
        end
    end

    wire [11:0] mode_rom_addr;
    assign mode_rom_addr = (mode_ascii << 4) + mode_row;

    wire [7:0] mode_font_row;
    font_rom font_mode(
        .addr(mode_rom_addr),
        .data(mode_font_row)
    );

    wire mode_pixel_on;
    assign mode_pixel_on = mode_font_row[7-mode_col];

    // -------------------------------------------------------
    // Ángulos: x:XXX y:XXX y2:XXX z:XXX
    // -------------------------------------------------------
    parameter X_START = 150;
    parameter Y_START = 250;

    wire [2:0] col;
    wire [3:0] row;
    assign col = CounterX - X_START;
    assign row = CounterY - Y_START;

    wire [4:0] char_index;
    assign char_index = (CounterX - X_START) >> 3;

    reg [7:0] ascii;
    always @* begin
        case(char_index)
            5'd0:  ascii = "x";
            5'd1:  ascii = ":";
            5'd2:  ascii = ax_ascii2;
            5'd3:  ascii = ax_ascii1;
            5'd4:  ascii = ax_ascii0;
            5'd5:  ascii = " ";
            5'd6:  ascii = "y";
            5'd7:  ascii = ":";
            5'd8:  ascii = ay_ascii2;
            5'd9:  ascii = ay_ascii1;
            5'd10: ascii = ay_ascii0;
            5'd11: ascii = " ";
            5'd12: ascii = "y";
            5'd13: ascii = "2";
            5'd14: ascii = ":";
            5'd15: ascii = ay2_ascii2;
            5'd16: ascii = ay2_ascii1;
            5'd17: ascii = ay2_ascii0;
            5'd18: ascii = " ";
            5'd19: ascii = "z";
            5'd20: ascii = ":";
            5'd21: ascii = az_ascii2;
            5'd22: ascii = az_ascii1;
            5'd23: ascii = az_ascii0;
            default: ascii = " ";
        endcase
    end

    wire [11:0] rom_addr;
    assign rom_addr = (ascii << 4) + row;

    wire [7:0] font_row;
    font_rom font(
        .addr(rom_addr),
        .data(font_row)
    );

    wire pixel_on;
    assign pixel_on = font_row[7-col];

    always @(posedge MAX10_CLK1_50) begin
        if (inDisplayArea) begin

            if (CounterX >= X_START && CounterX < X_START + 192 &&
                CounterY >= Y_START && CounterY < Y_START + 16)
            begin
                pixel <= pixel_on ? 3'b111 : 3'b000;
            end

            else if (CounterX >= MODE_X && CounterX < MODE_X + 88 &&
                     CounterY >= MODE_Y && CounterY < MODE_Y + 16)
            begin
                pixel <= mode_pixel_on ? 3'b111 : 3'b000;
            end

            else
                pixel <= 3'b000;

        end
        else
            pixel <= 3'b000;
    end

endmodule
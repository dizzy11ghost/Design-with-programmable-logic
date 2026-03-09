// Módulo principal que muestra un contador en VGA con fuente 8x16 bits
module VGACounterDemo(
    input MAX10_CLK1_50,      // reloj de 50 MHz de la tarjeta
    output reg [2:0] pixel,   // salida de color RGB (3 bits)
    output hsync_out,         // señal de sincronización horizontal
    output vsync_out          // señal de sincronización vertical
);

//-------------------------------------------------
// Señales del sistema VGA
//-------------------------------------------------

wire inDisplayArea;   // indica si estamos dentro del área visible de la pantalla
wire [9:0] CounterX;  // posición horizontal actual del pixel
wire [9:0] CounterY;  // posición vertical actual del pixel


//-------------------------------------------------
// Generación de pixel clock (25 MHz)
//-------------------------------------------------

// VGA 640x480 usa aproximadamente 25 MHz
// aquí dividimos el reloj de 50 MHz entre 2
reg pixel_tick = 0;

always @(posedge MAX10_CLK1_50)
    pixel_tick <= ~pixel_tick;


//-------------------------------------------------
// Generador de sincronización VGA
//-------------------------------------------------

// Este módulo genera las señales hsync, vsync
// y también las coordenadas del pixel actual
hvsync_generator hvsync(
    .clk(MAX10_CLK1_50),
    .pixel_tick(pixel_tick),
    .vga_h_sync(hsync_out),
    .vga_v_sync(vsync_out),
    .CounterX(CounterX),
    .CounterY(CounterY),
    .inDisplayArea(inDisplayArea)
);


//-------------------------------------------------
// Divisor de reloj para hacer el contador más lento
//-------------------------------------------------

reg [25:0] clk_div = 0; // contador para dividir el reloj
reg slow_clk = 0;       // reloj más lento

always @(posedge MAX10_CLK1_50)
begin
    if(clk_div == 50_000_000-1) // aproximadamente 1 segundo
    begin
        clk_div <= 0;
        slow_clk <= ~slow_clk;  // cambia el estado del reloj lento
    end
    else
        clk_div <= clk_div + 1;
end


//-------------------------------------------------
// Contador principal
//-------------------------------------------------

// contador que se mostrará en pantalla
reg [13:0] counter = 0;

always @(posedge slow_clk)
begin
    counter <= counter + 1;
end


//-------------------------------------------------
// Conversión del contador a dígitos decimales
//-------------------------------------------------

// se separa el número en unidades, decenas, centenas y millares
wire [3:0] d0;
wire [3:0] d1;
wire [3:0] d2;
wire [3:0] d3;

assign d0 = counter % 10;
assign d1 = (counter / 10) % 10;
assign d2 = (counter / 100) % 10;
assign d3 = (counter / 1000) % 10;


//-------------------------------------------------
// Conversión de dígitos a ASCII
//-------------------------------------------------

// se suma "0" para obtener el código ASCII del número
wire [7:0] ascii0;
wire [7:0] ascii1;
wire [7:0] ascii2;
wire [7:0] ascii3;

assign ascii0 = d0 + "0";
assign ascii1 = d1 + "0";
assign ascii2 = d2 + "0";
assign ascii3 = d3 + "0";


//-------------------------------------------------
// Posición donde aparecerá el texto
//-------------------------------------------------

parameter X_START = 200; // posición horizontal inicial
parameter Y_START = 250; // posición vertical inicial


//-------------------------------------------------
// Posición del pixel dentro del carácter
//-------------------------------------------------

// columna dentro del carácter (0-7)
wire [2:0] col;

// fila dentro del carácter (0-15)
wire [3:0] row;

assign col = CounterX - X_START;
assign row = CounterY - Y_START;


//-------------------------------------------------
// Determinar qué carácter se está dibujando
//-------------------------------------------------

// cada carácter mide 8 pixels de ancho
wire [1:0] char_index;

assign char_index = (CounterX - X_START) >> 3;


//-------------------------------------------------
// Selección del dígito que se va a mostrar
//-------------------------------------------------

reg [7:0] ascii;

always @*
begin
    case(char_index)
        2'd0: ascii = ascii3; // millares
        2'd1: ascii = ascii2; // centenas
        2'd2: ascii = ascii1; // decenas
        2'd3: ascii = ascii0; // unidades
        default: ascii = " ";
    endcase
end


//-------------------------------------------------
// Dirección de la memoria de fuente
//-------------------------------------------------

// cada carácter tiene 16 filas
wire [11:0] rom_addr;

assign rom_addr = (ascii << 4) + row;


//-------------------------------------------------
// Lectura de la ROM de fuentes
//-------------------------------------------------

wire [7:0] font_row;

// ROM que contiene los pixels de los caracteres
font_rom font(
    .addr(rom_addr),
    .data(font_row)
);


//-------------------------------------------------
// Determinar si el pixel está encendido
//-------------------------------------------------

wire pixel_on;

// selecciona el bit correspondiente de la fila
assign pixel_on = font_row[7-col];


//-------------------------------------------------
// Dibujar el pixel en pantalla
//-------------------------------------------------

always @(posedge MAX10_CLK1_50)
begin
    if(inDisplayArea) // solo dibujar dentro del área visible
    begin
        // verificar si estamos dentro del área del texto
        if(CounterX >= X_START && CounterX < X_START + 32 &&
           CounterY >= Y_START && CounterY < Y_START + 16)
        begin
            if(pixel_on)
                pixel <= 3'b111; // pixel blanco
            else
                pixel <= 3'b000; // pixel negro
        end
        else
            pixel <= 3'b000;
    end
    else
        pixel <= 3'b000;
end

endmodule
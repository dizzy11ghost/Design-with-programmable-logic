// Módulo de memoria ROM que guarda la fuente de caracteres
module font_rom(
    input [10:0] addr,   // Dirección de memoria (qué parte de la fuente queremos leer)
    output reg [7:0] data // Datos que salen de la ROM (una fila de 8 píxeles del carácter)
);

// Memoria ROM de 4096 posiciones, cada una de 8 bits
// Aquí se guarda la información de todos los caracteres
reg [7:0] rom [0:4095];

// Este bloque se ejecuta al iniciar la simulación o cargar el FPGA
// Carga los datos del archivo font_rom.hex dentro de la memoria
initial begin
    $readmemh("font_rom.hex", rom);
end

// Cada vez que cambia la dirección (addr)
// se lee el valor correspondiente de la ROM
always @*
begin
    data = rom[addr]; // Se envía la fila del carácter solicitada
end

endmodule
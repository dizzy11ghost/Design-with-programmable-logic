module UART_Rx #(parameter BAUD_RATE = 9600, parameter CLOCK_FREQ = 50_000_000, BITS = 8)(
    input wire clk, 
    input wire rst, 
    input wire rx_in,
    output wire idle,
    output wire startbit,
    output wire databits,
    output wire stopbits,
    output [0:6] D_un, D_de, D_ce,
    output reg data_ready 
); 
    
    localparam IDLE = 2'b00, START_BIT = 2'b01, DATA_BITS = 2'b10, STOP_BIT = 2'b11; 
    reg [1:0] state; 
    reg [3:0] bit_index; 
    reg [15:0] baud_counter; 
    reg [BITS-1:0] data_buffer;
    reg [BITS-1:0] data_out;

    reg rx_sync1, rx_sync2;
    always @(posedge clk) begin
        rx_sync1 <= rx_in;
        rx_sync2 <= rx_sync1;
    end

    wire [3:0] unidades, decenas, centenas;
    assign unidades = data_out % 10;
    assign decenas  = (data_out % 100) / 10;
    assign centenas = (data_out % 1000) / 100;
    
    BCD_module Uni(.bcd_in(unidades), .bcd_out(D_un)); 
    BCD_module Dec(.bcd_in(decenas),  .bcd_out(D_de)); 
    BCD_module Cen(.bcd_in(centenas), .bcd_out(D_ce));
    
    assign idle     = (state == IDLE);
    assign startbit = (state == START_BIT);
    assign databits = (state == DATA_BITS);
    assign stopbits = (state == STOP_BIT);
    
    always @(posedge clk or posedge rst) begin 
        if (rst) begin 
            state        <= IDLE; 
            data_out     <= 0; 
            data_ready   <= 0; 
            bit_index    <= 0; 
            baud_counter <= 0;
            data_buffer  <= 0;
        end else begin
            data_ready <= 0; // pulso de 1 ciclo, siempre limpiar

            case (state)
            IDLE: begin
                if (!rx_sync2) begin  // usa señal sincronizada
                    state        <= START_BIT; 
                    baud_counter <= 0; 
                    data_buffer  <= 0;
                end 
            end

            START_BIT: begin
                if (baud_counter < CLOCK_FREQ / BAUD_RATE / 2 - 1) begin 
                    baud_counter <= baud_counter + 1; 
                end else begin 
                    baud_counter <= 0;
                    if (!rx_sync2)  // confirma que sigue en bajo = start real
                        state <= DATA_BITS;
                    else
                        state <= IDLE;  // fue ruido, regresa
                end
            end

            DATA_BITS: begin
                if (baud_counter < CLOCK_FREQ / BAUD_RATE - 1) begin
                    baud_counter <= baud_counter + 1;
                end else begin
                    baud_counter           <= 0;
                    data_buffer[bit_index] <= rx_sync2;
                    if (bit_index < BITS - 1) begin
                        bit_index <= bit_index + 1;
                    end else begin
                        bit_index <= 0;
                        state     <= STOP_BIT;
                    end
                end
            end

            STOP_BIT: begin
                if (baud_counter < CLOCK_FREQ / BAUD_RATE - 1) begin 
                    baud_counter <= baud_counter + 1; 
                end else begin 
                    baud_counter <= 0;
                    if (rx_sync2) begin  // stop bit válido (debe ser alto)
                        data_out   <= data_buffer;
                        data_ready <= 1;
                    end
                    // si stop bit inválido, descarta el byte
                    state <= IDLE;
                end 
            end 
            endcase 
        end 
    end 
endmodule
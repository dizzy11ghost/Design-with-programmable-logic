module fsm(
    input MAX10_CLK1_50,
    input [1:0] KEY, 
    output reg counter_enable,
    output reg write_enable,
    output wire [1:0] current_state
);

wire reset = ~KEY[0];
wire load = KEY[1];
//detector de flanco para KEY[1] para evitar que cuente múltiples veces
reg load_prev;
wire load_pulse;
always @(posedge clk_d) load_prev <= load;
assign load_pulse = load & ~load_prev; //1 sólo ciclo por press

reg[2:0] count; //para limitar cuántas instrucciones le puede dar el usuario al modo automático!
wire clk_d;
assign current_state = state;

clk_divider #(.FREQ(2)) clk_div_inst(
   .clk    (MAX10_CLK1_50),
   .rst    (reset),
   .clk_div(clk_d)
);

parameter S0=0, S1=1, S2=2, S3=3; //S0 IDLE, S1 Manual, S2 Carga, S3 Automático
reg [1:0] state, next;

//current state
always @(posedge clk_d or posedge reset) begin
    if (reset) state <= S0;
    else state <= next;
end

always @(posedge clk_d or posedge reset) begin //contador limite de load
    if (reset)
        count = 0;
    else if (state == S2 && load_pulse) begin
        count = count + 1;
    end
end

//next state
always @(*) begin
    case(state)
        S0: if (reset == 0) next = S1; else next = S0; //IDLE
        S1: if (load_pulse == 1) next = S2; else next = S1; //MANUAL
        S2: if (count >= 5) next = S3; else next = S2; //LOAD
        S3: if (load_pulse) next = S1; else next = S3;  
        default: next = S0;
    endcase
end

//output logic
always @(*) begin //aqui se usa @(*) porque el valor de LEDR depende del estado actual, y no de una señal específica, entonces queremos que se actualice cada vez que cambie el estado
    //inicializamos vars
    counter_enable = 0;
    write_enable = 0;
    
    case(state)
        S2: begin
            write_enable = load_pulse; //solo un pulso cuando llega load, no activo de forma continua.
            counter_enable = load_pulse; //guarda posiciones cuando se usa el botón load
        end
        S3: begin counter_enable = 1; //el contador de la ram avanza sin depender del botón 
        end
    endcase
end
endmodule
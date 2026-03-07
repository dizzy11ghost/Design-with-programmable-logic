module fsm(
    input MAX10_CLK1_50,
    input [1:0] KEY, 
    input load,

    output reg counter_enable,
    output reg write_enable, 
);

wire reset = ~KEY[0];
wire mode_select = KEY[1];
reg[2:0] count; //para limitar cuántas instrucciones le puede dar el usuario al modo automático!
reg clk_d;

clk_divider #(.FREQ(2)) clk(
   .clk    (MAX10_CLK1_50),
   .rst    (~rst),
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
    else if (state == S2 && load) begin
        if (select_mode == 1)
            count = count + 1;
    end
end

//next state
always @(*) begin
    case(state)
        S0: if (reset == 0) next = S1; else next = S0; //IDLE
        S1: if (mode_select == 1) next = S2; else next = S1; //MANUAL
        S2: if (count < 5) next = S2; else next = S3; //LOAD
        S3: next = S3; 
        default: next = S0;
    endcase
end

//output logic
always @(*) begin //aqui se usa @(*) porque el valor de LEDR depende del estado actual, y no de una señal específica, entonces queremos que se actualice cada vez que cambie el estado
    //inicializamos vars
    counter_enable = 0;
    write_enable = 0;
    
    case(state)
        S0: begin end; //en el estado inicial, el primer led esta encendido
        S1: begin end;
        S2: begin
            write_enable = 1; //permite escribir en la memoria
            counter_enable = load; //guarda posiciones cuando se usa el botón load
        end
        S3: begin counter_enable = 1;
        end
    endcase
end
endmodule
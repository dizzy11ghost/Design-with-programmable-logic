module fsm(
    input MAX10_CLK1_50,
    input [1:0] KEY,
    input sw_auto,
    output reg done,
    output reg counter_enable,
    output reg write_enable,
    output wire [1:0] current_state
);
    wire reset = ~KEY[0];
    wire load  = ~KEY[1];
    wire clk_d;

    clk_divider #(.FREQ(60)) clk_div_inst(
        .clk (MAX10_CLK1_50),
        .rst (reset),
        .clk_div(clk_d)
    );

    reg load_prev;
    wire load_pulse;
    always @(posedge clk_d) load_prev <= load;
    assign load_pulse = load & ~load_prev;

    parameter S0=0, S1=1, S2=2, S3=3;
    reg [1:0] state, next;
    reg [2:0] count;

    assign current_state = state;

    // Estado actual
    always @(posedge clk_d or posedge reset) begin
        if (reset) 
			state <= S0;
        else       
			state <= next;
    end

    // Contador 
    always @(posedge clk_d or posedge reset) begin
        if (reset)
            count <= 0;
        else if (state == S1 && next == S2) 
            count <= 0;
        else if (state == S2 && load_pulse && !done)  
            count <= count + 1;
    end

    always @(posedge clk_d or posedge reset) begin
        if (reset)
            done <= 0;
        else if (count >= 5)
            done <= 1;
    end

    // Siguiente estado
    always @(*) begin
        case(state)
            S0: 
					next = (reset == 0) ? S1 : S0;
            S1: if (sw_auto && done)  
                    next = S3;
                else if (load_pulse)
                    next = S2;
                else
                    next = S1;
            S2: 
					if (count >= 5 && sw_auto) 
						next = S3;
                else if (count >= 5)            
						next = S1;
                else                            
						next = S2;
            S3: 
					next = sw_auto ? S3 : S1;
            default: 
					next = S0;
        endcase
    end

    // Lógica de salida
    always @(*) begin
        counter_enable = 0;
        write_enable   = 0;
        case(state)
            S2: begin
                write_enable   = load_pulse && !done;  
                counter_enable = load_pulse && !done; 
            end
            S3: begin
                counter_enable = 1;
            end
        endcase
    end

endmodule

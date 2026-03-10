module password(
	input clk,
	input X, //in
	input rst,
	input enter,
	
	output reg [6:0] seg3, seg2, seg1, seg0
);
	
parameter [3:0] PASSWORD = 4'b1010; //contraseña parametrizada, podemos cambiarla!

//estados: IDLE, D1, D2, D3, D4, GOOD, BAD
parameter IDLE=0, D1=1, D2=2, D3=3, D4=4, GOOD=5, BAD=6;
reg [2:0] state, next;

//current state
always @(posedge clk or posedge rst) begin
	if (rst) state <= IDLE;
   else state <= next;
end

//next state logic
always @(*) begin
    case(state)
        IDLE: if (enter) next = D1; else next = IDLE;
        D1: if (enter) begin
                  if (X == PASSWORD[3])next = D2; else next = BAD;
            end else next = D1;
        D2: if (enter) begin
                  if (X == PASSWORD[2])next = D3; else next = BAD;
              end else next = D2;
        D3:  if (enter) begin
                  if (X == PASSWORD[1]) next = D4; else next = BAD;
              end else next = D3;
        D4:   if (enter) begin
                  if (X == PASSWORD[0]) next = GOOD; else next = BAD;
              end else next = D4;
        GOOD: next = GOOD;
        BAD:  next = BAD;
        default: next = IDLE;
    endcase
end

// output logic
always @(*) begin
	case(state)
		GOOD: begin
			seg3 = 7'b0000010; // G
         seg2 = 7'b1000000; // O
         seg1 = 7'b1000000; // O
         seg0 = 7'b0100001; // d
		end
		BAD: begin
			seg3 = ~7'b0000000; // apagado
         seg2 = 7'b0000011; // b
         seg1 = 7'b0001000; // A
         seg0 = 7'b0100001; // d
		end
		IDLE: begin
         seg3 = ~7'b0000001; // –
         seg2 = ~7'b0000001; // –
         seg1 = ~7'b0000001; // –
         seg0 = ~7'b0000001; // –
        end
		D1: begin
         seg3 = ~7'b0000000; // apagado
         seg2 = ~7'b0000000; // apagado
         seg1 = ~7'b0000000; // apagado
         seg0 = ~7'b0110000; // 1
		end
		D2: begin
         seg3 = ~7'b0000000;
         seg2 = ~7'b0000000;
         seg1 = ~7'b0000000;
			seg0 = ~7'b0110000;
          // 2
		end
		D3: begin
         seg3 = ~7'b0000000;
         seg2 = ~7'b0000000;
         seg1 = ~7'b0000000;
			seg0 = 7'b0100100;
          // 3
		end
		D4: begin
         seg3 = ~7'b0000000;
         seg2 = ~7'b0000000;
         seg1 = ~7'b0000000;
        seg0 = 7'b0110000;
		end
		default: begin
         seg3 = ~7'b0000000;
         seg2 = ~7'b0000000;
         seg1 = ~7'b0000000;
         seg0 = ~7'b0000000;
		end
	 endcase
end

endmodule
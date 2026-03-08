`timescale 1ns/1ps

module tb_top;

// señales
reg clk;
reg [1:0] KEY;

wire GSENSOR_CS_N;
wire [2:1] GSENSOR_INT;
wire GSENSOR_SCLK;
wire GSENSOR_SDI, GSENSOR_SDO;
wire [9:0] ARDUINO_IO;

// señales internas
wire ram_we;
wire counter_en;
wire [2:0] ram_addr;
wire [1:0] fsm_state;

wire load = ~KEY[1];

wire [47:0] ram_data_in = 48'hAABBCC112233;
wire [47:0] ram_data_out;

///////////////////////
//// DUTs
///////////////////////

fsm statesDUT(
    .MAX10_CLK1_50(clk),
    .KEY(KEY),
    .load(load),
    .write_enable(ram_we),
    .counter_enable(counter_en),
    .current_state(fsm_state)
);

counter contramDUT(
    .clk(clk),
    .rst(~KEY[0]),
    .enable(counter_en),
    .addr(ram_addr)
);

memory_RAM #(.NBits(48), .NAddr(3)) ramDUT(
    .clk(clk),
    .rst_a(~KEY[0]),
    .wr_en(ram_we),
    .Data_in(ram_data_in),
    .Data_address(ram_addr),
    .Data_out(ram_data_out)
);

///////////////////////
//// VCD
///////////////////////

initial begin
    $dumpfile("tb_top.vcd");
    $dumpvars(0,tb_top);
end

///////////////////////
//// CLOCK
///////////////////////

initial clk = 0;
always #10 clk = ~clk;

///////////////////////
//// MONITOR
///////////////////////

initial begin
    $monitor("[%0t] state=%0d we=%b ce=%b addr=%0d ram=%h",
        $time,fsm_state,ram_we,counter_en,ram_addr,ram_data_out);
end

///////////////////////
//// TEST
///////////////////////

initial begin

KEY = 2'b11;
#20;

// reset
KEY[0] = 0;
#100;
KEY[0] = 1;
#100;

if (fsm_state == 0)
    $display("PASS reset -> S0");
else
    $display("FAIL reset -> state=%0d",fsm_state);

// estado manual
KEY[1] = 1;
#100;

if (fsm_state == 1)
    $display("PASS S1 manual");
else
    $display("FAIL state=%0d",fsm_state);

// load
KEY[1] = 0;
#100;

if (fsm_state == 2)
    $display("PASS S2 load");
else
    $display("FAIL state=%0d",fsm_state);

// write RAM
if (ram_we == 1 && counter_en == 0)
    $display("PASS write_enable");
else
    $display("FAIL we=%b ce=%b",ram_we,counter_en);

// carga múltiple
repeat(5) begin
    KEY[1]=0; #40;
    KEY[1]=1; #40;
    $display("addr=%0d ram=%h",ram_addr,ram_data_out);
end

#50;

if (fsm_state == 3)
    $display("PASS S3 auto");
else
    $display("FAIL state=%0d",fsm_state);

// contador automático
if (counter_en==1 && ram_we==0)
    $display("PASS counter");
else
    $display("FAIL ce=%b we=%b",counter_en,ram_we);

#200;
$display("addr auto=%0d",ram_addr);

// reset final
KEY[0]=0;
#100;
KEY[0]=1;
#50;

if (fsm_state==0)
    $display("PASS reset final");
else
    $display("FAIL state=%0d",fsm_state);

$display("=== FIN ===");
$finish;

end

endmodule
module BCD_4displays_tb; 

    reg  [9:0] bcd_in; 
    wire [6:0] D_un, D_de, C_ce, D_mi;   

    BCD_4displays dut (
        .bcd_in(bcd_in),
        .D_un(D_un),
        .D_de(D_de),
        .C_ce(C_ce),
        .D_mi(D_mi)
    );
    
    initial 
    begin
        repeat(10)
        begin
            bcd_in = $random % 1024;  // valores de 0 a 1023
            #10;
        end
        $stop;
        $finish;
    end

    initial 
    begin
        $dumpfile("BCD_4displays_tb.vcd");
        $dumpvars(0, BCD_4displays_tb);
    end

endmodule

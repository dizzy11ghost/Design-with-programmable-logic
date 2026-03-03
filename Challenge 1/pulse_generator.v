module pulse_generator(ff1, ff2, pulse);
    input ff1;
    input ff2; 
    output wire pulse; //aquí si usamos wire pq el valor de pulse es una señal combinacional que no depende del tiempo.

    assign pulse = ff1 & ~ff2; 
endmodule
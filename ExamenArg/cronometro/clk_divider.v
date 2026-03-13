module clk_divider #(parameter freq = 1)(
    input clk, rst,
    output reg clk_div
);

    reg [31:0] count;

    parameter clk_freq = 50_000_000;
    parameter constant_num = clk_freq / (2 * freq);

    always @(posedge clk or posedge rst)
    begin 
        if (rst)
            count <= 0;
        else if (count == constant_num - 1)
            count <= 0;
        else
            count <= count + 1;
    end
    
    always @(posedge clk or posedge rst)
    begin
        if(rst)
            clk_div <= 0;
        else if (count == constant_num - 1)
            clk_div <= ~clk_div;
    end

endmodule

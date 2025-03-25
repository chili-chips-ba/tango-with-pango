`timescale 1ns / 1ns

module tb_shfit_reg();

reg         sys_clk;
reg         sys_rst_n;
reg         a;

wire        y;

initial begin
    sys_clk = 1'b1;		
    sys_rst_n <= 1'b0;  
    a <= 1'b0;			
    #201
    sys_rst_n <= 1'b1;
    #100
    a <= 1'b1;
    #100
    a <= 1'b0;
end

always #10 sys_clk <= ~sys_clk;

shfit_reg shfit_reg_inst(
    .sys_clk    (sys_clk    ),
    .sys_rst_n  (sys_rst_n  ),
    .a          (a          ),
                            
    .y          (y          )
    );

endmodule

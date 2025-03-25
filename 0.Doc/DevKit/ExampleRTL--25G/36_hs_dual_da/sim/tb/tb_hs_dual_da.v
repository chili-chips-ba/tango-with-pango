`timescale 1ns / 1ps        //���浥λ/���澫��

module tb_hs_dual_da();

//parameter define
parameter  CLK_PERIOD = 20; //ʱ������ 20ns

//reg define
reg     sys_clk;
reg     sys_rst_n;

//�źų�ʼ��
initial begin
    sys_clk = 1'b0;
    sys_rst_n = 1'b0;
    #200
    sys_rst_n = 1'b1;
end

//����ʱ��
always #(CLK_PERIOD/2) sys_clk = ~sys_clk;

hs_dual_da u_hs_dual_da(
    .sys_clk          (sys_clk        ),
    .sys_rst_n        (sys_rst_n      ),
    .da_clk_1         (),
    .da_data_1        (),
    .da_clk_2         (),
    .da_data_2        ()
    );

endmodule

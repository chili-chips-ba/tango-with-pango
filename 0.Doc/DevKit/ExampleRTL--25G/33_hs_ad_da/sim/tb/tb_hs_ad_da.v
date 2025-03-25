`timescale 1ns / 1ps        //���浥λ/���澫��

module tb_hs_ad_da();

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

hs_ad_da u_hs_ad_da(
    .sys_clk          (sys_clk        ),
    .sys_rst_n        (sys_rst_n      ),
    .da_clk           (),
    .da_data          (),
    .ad_data          (),
    .ad_otr           (),
    .ad_clk           ()
    );

endmodule

`timescale 1ns / 1ps        //���浥λ/���澫��

module tb_ip_pll();

//parameter define
parameter  CLK_PERIOD = 20; //ʱ������ 20ns

//reg define
reg     sys_clk;
reg     sys_rst_n;

//wire define
wire    clk_100m;      
wire    clk_100m_180deg;
wire    clk_50m;     
wire    clk_25m;        

//�źų�ʼ��
initial begin
    sys_clk = 1'b0;
    sys_rst_n = 1'b0;
    #200
    sys_rst_n = 1'b1;
end

//����ʱ��
always #(CLK_PERIOD/2) sys_clk = ~sys_clk;

ip_pll u_ip_pll(
    .sys_clk          (sys_clk        ),
    .sys_rst_n        (sys_rst_n      ),

    .clk_100m         (clk_100m       ),
    .clk_100m_180deg  (clk_100m_180deg),
    .clk_50m          (clk_50m        ),
    .clk_25m          (clk_25m        )  
    );

endmodule

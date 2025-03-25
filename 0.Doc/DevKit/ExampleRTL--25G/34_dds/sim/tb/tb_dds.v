`timescale 1ns / 1ps        //���浥λ/���澫��

module tb_dds();

//parameter define
parameter  CLK_PERIOD = 20; //ʱ������ 20ns

//defparam  define
defparam u_dds.CNT_MAX=5;

//reg define
reg     sys_clk;
reg     sys_rst_n;
reg     key_wave;
reg     key_freq;

//�źų�ʼ��
initial begin
    sys_clk = 1'b0;
    sys_rst_n = 1'b0;
    key_wave = 1'b1;
    key_freq = 1'b1;
    #200
    sys_rst_n = 1'b1;
    //�ı䲨������
    #5000
    key_wave = 1'b0;
    #120
    key_wave = 1'b1;
    #200
    key_wave = 1'b0;
    #120
    key_wave = 1'b1;
    #200
    key_wave = 1'b0;
    #120
    key_wave = 1'b1;
    #200
    key_wave = 1'b0;
    #120
    key_wave = 1'b1;
    //�ı䲨��Ƶ��
    #10
    key_freq = 1'b0;
    #120
    key_freq = 1'b1;
    #200
    key_freq = 1'b0;
    #120
    key_freq = 1'b1;
    #200
    key_freq = 1'b0;
    #120
    key_freq = 1'b1;
    #200
    key_freq = 1'b0;
    #120
    key_freq = 1'b1;
end

//����ʱ��
always #(CLK_PERIOD/2) sys_clk = ~sys_clk;

dds u_dds(
    .sys_clk     (sys_clk   ),
    .sys_rst_n   (sys_rst_n ),
    .key_wave    (key_wave  ),
    .key_freq    (key_freq  ),
    .da_clk      (),
    .da_data     (),
    .ad_data     (),
    .ad_otr      (),
    .ad_clk      ()
    );

endmodule

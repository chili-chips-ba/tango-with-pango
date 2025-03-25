`timescale 1ns / 1ps        //���浥λ/���澫��

module tb_ip_1port_ram();

//ȫ�ָ�λ
reg  grs_n;
GTP_GRS GRS_INST(
    .GRS_N (grs_n)
    );
    
initial begin
    grs_n = 1'b0;
    #5000 grs_n = 1'b1;
end

//parameter define
parameter  CLK_PERIOD = 20; //ʱ������ 20ns

//reg define
reg     sys_clk;
reg     sys_rst_n;

//wire define
wire  [7:0] ram_wr_data;
wire  [7:0] ram_rd_data;
wire  [4:0] ram_addr   ;
wire        ram_rw_en  ;

//�źų�ʼ��
initial begin
    sys_clk = 1'b0;
    sys_rst_n = 1'b0;
    #200
    sys_rst_n = 1'b1;
end

//����ʱ��
always #(CLK_PERIOD/2) sys_clk = ~sys_clk;

ip_1port_ram u_ip_1port_ram(
    .sys_clk          (sys_clk    ),
    .sys_rst_n        (sys_rst_n  ),
    .ram_wr_data      (ram_wr_data),
    .ram_rd_data      (ram_rd_data),
    .ram_addr         (ram_addr   ),
    .ram_rw_en        (ram_rw_en  )
    );

endmodule

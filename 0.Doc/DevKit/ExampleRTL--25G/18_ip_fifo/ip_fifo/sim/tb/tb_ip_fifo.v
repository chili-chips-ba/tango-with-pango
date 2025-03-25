`timescale 1ns / 1ps        //���浥λ/���澫��

module tb_ip_fifo();

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
wire        fifo_wr_en  ;
wire        fifo_rd_en  ;
wire        fifo_full   ;
wire        fifo_empty  ;
wire  [7:0] fifo_wr_data;
wire  [7:0] fifo_rd_data;

//�źų�ʼ��
initial begin
    sys_clk = 1'b0;
    sys_rst_n = 1'b0;
    #200
    sys_rst_n = 1'b1;
end

//����ʱ��
always #(CLK_PERIOD/2) sys_clk = ~sys_clk;

ip_fifo u_ip_fifo(
    .sys_clk        (sys_clk     ),
    .sys_rst_n      (sys_rst_n   ),
    .fifo_wr_en     (fifo_wr_en  ), 
    .fifo_rd_en     (fifo_rd_en  ), 
    .fifo_full      (fifo_full   ), 
    .fifo_empty     (fifo_empty  ), 
    .fifo_wr_data   (fifo_wr_data),
    .fifo_rd_data   (fifo_rd_data)
    );

endmodule
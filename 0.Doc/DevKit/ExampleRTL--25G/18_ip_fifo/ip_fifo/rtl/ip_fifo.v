//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ip_fifo
// Created by:          ����ԭ��
// Created date:        2023��10��10��14:17:02
// Version:             V1.0
// Descriptions:        IP��֮FIFOʵ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ip_fifo(
    input          sys_clk     ,  // ʱ���ź�
    input          sys_rst_n   ,  // ��λ�ź�
    //�����߼���������Ϊ�˽��˿�����ȥ������û������źŵĻ��޷�����ץȡ�ź�
    //�����������
    output         fifo_wr_en  , // FIFOдʹ���ź�
    output         fifo_rd_en  , // FIFO��ʹ���ź�
    output         fifo_full   , // FIFO���ź�
    output         fifo_empty  , // FIFO���ź�
    output  [7:0]  fifo_wr_data, // д�뵽FIFO������
    output  [7:0]  fifo_rd_data  // ��FIFO����������
);

//wire define
wire         pll_lock           ; // ʱ�������ź�
wire         clk_50m            ; // 50Mʱ��
wire         clk_100m           ; // 100Mʱ��
wire         rst_n              ; // ��λ������Ч
wire         almost_full        ; // FIFO�����ź�
wire         almost_empty       ; // FIFO�����ź�
wire  [8:0]  fifo_wr_data_count ; // FIFOдʱ��������ݼ���
wire  [8:0]  fifo_rd_data_count ; // FIFO��ʱ��������ݼ���

//*****************************************************
//**                    main code
//*****************************************************

//ͨ��ϵͳ��λ�źź�ʱ�������ź�������һ���µĸ�λ�ź�
assign   rst_n = sys_rst_n & pll_lock;

//����PLL IP��
pll_clk u_pll_clk (
  .pll_rst           (~sys_rst_n        ), // input
  .clkin1            (sys_clk           ), // input
  .pll_lock          (pll_lock          ), // output
  .clkout0           (clk_50m           ), // output
  .clkout1           (clk_100m          )  // output
);

//����FIFO IP��
async_fifo u_async_fifo (
  .wr_clk            (clk_50m           ), // input
  .wr_rst            (~rst_n            ), // input
  .wr_en             (fifo_wr_en        ), // input
  .wr_data           (fifo_wr_data      ), // input [7:0]
  .wr_full           (fifo_full         ), // output
  .wr_water_level    (fifo_wr_data_count), // output [8:0]
  .almost_full       (almost_full       ), // output
  .rd_clk            (clk_100m          ), // input
  .rd_rst            (~rst_n            ), // input
  .rd_en             (fifo_rd_en        ), // input
  .rd_data           (fifo_rd_data      ), // output [7:0]
  .rd_empty          (fifo_empty        ), // output
  .rd_water_level    (fifo_rd_data_count), // output [8:0]
  .almost_empty      (almost_empty      )  // output
);

//����дFIFOģ��
fifo_wr  u_fifo_wr(
    .wr_clk              (clk_50m           ), // дʱ��
    .rst_n               (rst_n             ), // ��λ�ź�

    .fifo_wr_data_count  (fifo_wr_data_count), // FIFOдʱ��������ݼ���
    .fifo_wr_en          (fifo_wr_en        ), // fifoд����
    .fifo_wr_data        (fifo_wr_data      ), // д��FIFO������
    .fifo_empty          (fifo_empty        )  // fifo���ź�
);

//������FIFOģ��
fifo_rd  u_fifo_rd(
    .rd_clk              (clk_100m          ), // ��ʱ��
    .rst_n               (rst_n             ), // ��λ�ź�

    .fifo_rd_data_count  (fifo_rd_data_count), // FIFO��ʱ��������ݼ���
    .fifo_rd_en          (fifo_rd_en        ), // fifo������
    .fifo_rd_data        (fifo_rd_data      ), // ��FIFO���������
    .fifo_full           (fifo_full         )  // fifo���ź�
);

endmodule 
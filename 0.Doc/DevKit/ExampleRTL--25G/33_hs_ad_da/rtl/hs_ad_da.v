//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           hs_ad_da
// Last modified Date:  2019/07/31 17:04:35
// Last Version:        V1.0
// Descriptions:        ����AD/DAʵ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/07/31 17:04:35
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module hs_ad_da(
    input                 sys_clk     ,  //ϵͳʱ��
    input                 sys_rst_n   ,  //ϵͳ��λ���͵�ƽ��Ч
    //DAоƬ�ӿ�
    output                da_clk      ,  //DA(AD9708)����ʱ��,���֧��125Mhzʱ��
    output    [7:0]       da_data     ,  //�����DA������
    //ADоƬ�ӿ�
    input     [7:0]       ad_data     /* synthesis PAP_MARK_DEBUG="1" */,  //AD��������
    //ģ�������ѹ�������̱�־(��������δ�õ�)
    input                 ad_otr      /* synthesis PAP_MARK_DEBUG="1" */,  //0:�����̷�Χ 1:��������
    output                ad_clk         //AD(AD9280)����ʱ��,���֧��32Mhzʱ�� 
);

//wire define 
wire      [7:0]    rd_addr;              //ROM����ַ
wire      [7:0]    rd_data;              //ROM����������
wire               clk_50m;              //50MHzʱ��
wire               clk_25m;              //25MHzʱ��
wire               pll_lock;             //pllʱ�������ź�
wire               rst_n  ;              //��λ�źţ�����Ч

//*****************************************************
//**                    main code
//*****************************************************

//ͨ��ϵͳ��λ�źź�PLLʱ�������ź�������һ���µĸ�λ�ź�
assign   rst_n = sys_rst_n & pll_lock ;
assign   ad_clk = clk_25m ;

//pll
pll_clk  u_pll_clk(
  .clkin1        (sys_clk),       
  .pll_lock      (pll_lock),    
  .clkout0       (clk_50m),     
  .clkout1       (clk_25m)    
);

//DA���ݷ���
da_wave_send u_da_wave_send(
    .clk         (clk_50m), 
    .rst_n       (rst_n),
    .rd_data     (rd_data),
    .rd_addr     (rd_addr),
    .da_clk      (da_clk),  
    .da_data     (da_data)
    );

//ROM�洢����
rom_256x8b  u_rom_256x8b (
  .clk     (clk_50m), // input wire clka
  .addr    (rd_addr), // input wire [7 : 0] addra
  .rst     (~rst_n),
  .rd_data (rd_data)  // output wire [7 : 0] douta
);
   

endmodule
//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           hs_dual_da
// Last modified Date:  2019/07/31 17:04:35
// Last Version:        V1.0
// Descriptions:        ˫·DAʵ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/07/31 17:04:35
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module hs_dual_da(
    input                 sys_clk    ,  //ϵͳʱ��
    input                 sys_rst_n  ,  //ϵͳ��λ���͵�ƽ��Ч
    //DAоƬ�ӿ�
    output                da_clk_1   ,  //��һ·DAC����ʱ��
    output    [9:0]       da_data_1  ,  //��һ·DAC����
    output                da_clk_2   ,  //�ڶ�·DAC����ʱ��
    output    [9:0]       da_data_2     //�ڶ�·DAC����
);

//wire define 
wire      [9:0]    rd_addr ;            //ROM��ַ
wire      [9:0]    rd_data ;            //ROM����
wire               clk_50m ;            //50MHzʱ��
wire               pll_lock;            //PLLʱ�������ź�
wire               rst_n   ;            //��λ�źţ�����Ч

//*****************************************************
//**                    main code
//*****************************************************

//ͨ��ϵͳ��λ�źź�PLLʱ�������ź�������һ���µĸ�λ�ź�
assign  rst_n = sys_rst_n & pll_lock;
assign  da_clk_2 = da_clk_1;
assign  da_data_2 = da_data_1;

//pll
pll_clk u_pll_clk (
  .clkin1        (sys_clk),       
  .pll_lock      (pll_lock),    
  .clkout0       (clk_50m)    
);
    
//ROMģ��
rom_1024x10b the_instance_name (
  .addr          (rd_addr),          
  .clk           (sys_clk),            
  .rst           (~rst_n),            
  .rd_data       (rd_data)     
);
//DA���ݷ���
da_wave_send u_da_wave_send(
    .clk         (clk_50m  ),
    .rst_n       (rst_n    ),
    .rd_data     (rd_data  ),
    .rd_addr     (rd_addr  ),
    .da_clk      (da_clk_1 ),
    .da_data     (da_data_1)
    );

endmodule
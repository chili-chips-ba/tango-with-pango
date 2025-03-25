//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ip_pll
// Created by:          ����ԭ��
// Created date:        2023��9��8��14:17:02
// Version:             V1.0
// Descriptions:        IP��֮PLLʵ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ip_pll(
    input     sys_clk        ,   //ϵͳʱ��
    input     sys_rst_n      ,   //ϵͳ��λ���͵�ƽ��Ч
    //���ʱ��
    output    clk_100m       ,   //100Mhzʱ��Ƶ��
    output    clk_100m_180deg,   //100Mhzʱ��Ƶ��,��λƫ��180��
    output    clk_50m        ,   //50Mhzʱ��Ƶ��
    output    clk_25m            //25Mhzʱ��Ƶ��
    );

//wire define
wire        pll_lock;

//*****************************************************
//**                    main code
//*****************************************************

//���໷
pll_clk u_pll_clk (
    .pll_rst     (~sys_rst_n     ),      // input    
    .clkin1      (sys_clk        ),      // input
    .pll_lock    (pll_lock       ),      // output
    .clkout0     (clk_100m       ),      // output
    .clkout1     (clk_100m_180deg),      // output
    .clkout2     (clk_50m        ),      // output
    .clkout3     (clk_25m        )       // output
);

endmodule
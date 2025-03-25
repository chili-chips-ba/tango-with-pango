//****************************************Copyright (c)***********************************//
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com 
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡFPGA & STM32���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           hs_dual_ad
// Last modified Date:  2018/1/30 11:12:36
// Last Version:        V1.1
// Descriptions:        ˫·ģ��ת��ģ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2018/1/29 10:55:56
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module hs_dual_ad(
    input          sys_clk    ,  //ϵͳʱ��
    input          sys_rst_n  ,  //ϵͳ��λ
    //��һ·ADC
    input   [9:0]  ad_data_1  /* synthesis PAP_MARK_DEBUG="true" */,  //��һ·ADC����
    input          ad_otr_1   /* synthesis PAP_MARK_DEBUG="true" */,  //��һ·ADC�����ѹ�������̱�־
    output         ad_clk_1   ,  //��һ·ADC����ʱ��
    output         ad_oe_1    ,  //��һ·ADC���ʹ��
    //�ڶ�·ADC
    input   [9:0]  ad_data_2  /* synthesis PAP_MARK_DEBUG="true" */,  //�ڶ�·ADC����
    input          ad_otr_2   /* synthesis PAP_MARK_DEBUG="true" */,  //�ڶ�·ADC�����ѹ�������̱�־
    output         ad_clk_2   ,  //�ڶ�·ADC����ʱ��
    output         ad_oe_2       //�ڶ�·ADC���ʹ��
    );

//wire define 
wire             clk_50m;  //50MHzʱ��
wire             clk_50m_deg180/* synthesis PAP_MARK_DEBUG="<0/c0/0>" */;

//*****************************************************
//**                    main code
//*****************************************************

assign  ad_oe_1 =  1'b0;
assign  ad_oe_2 =  1'b0;
assign  ad_clk_1 = clk_50m;
assign  ad_clk_2 = clk_50m;

//pll
pll_clk u_pll_clk (
  .clkin1      (sys_clk),        
  .pll_lock    (pll_lock),    
  .clkout0     (clk_50m),
  .clkout1     (clk_50m_deg180)     
);     

endmodule

//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           hs_dual_ad
// Last modified Date:  2018/1/30 11:12:36
// Last Version:        V1.1
// Descriptions:        双路模数转换模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/1/29 10:55:56
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module hs_dual_ad(
    input          sys_clk    ,  //系统时钟
    input          sys_rst_n  ,  //系统复位
    //第一路ADC
    input   [9:0]  ad_data_1  /* synthesis PAP_MARK_DEBUG="true" */,  //第一路ADC数据
    input          ad_otr_1   /* synthesis PAP_MARK_DEBUG="true" */,  //第一路ADC输入电压超过量程标志
    output         ad_clk_1   ,  //第一路ADC驱动时钟
    output         ad_oe_1    ,  //第一路ADC输出使能
    //第二路ADC
    input   [9:0]  ad_data_2  /* synthesis PAP_MARK_DEBUG="true" */,  //第二路ADC数据
    input          ad_otr_2   /* synthesis PAP_MARK_DEBUG="true" */,  //第二路ADC输入电压超过量程标志
    output         ad_clk_2   ,  //第二路ADC驱动时钟
    output         ad_oe_2       //第二路ADC输出使能
    );

//wire define 
wire             clk_50m;  //50MHz时钟
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

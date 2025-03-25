//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ip_pll
// Created by:          正点原子
// Created date:        2023年9月8日14:17:02
// Version:             V1.0
// Descriptions:        IP核之PLL实验
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ip_pll(
    input     sys_clk        ,   //系统时钟
    input     sys_rst_n      ,   //系统复位，低电平有效
    //输出时钟
    output    clk_100m       ,   //100Mhz时钟频率
    output    clk_100m_180deg,   //100Mhz时钟频率,相位偏移180度
    output    clk_50m        ,   //50Mhz时钟频率
    output    clk_25m            //25Mhz时钟频率
    );

//wire define
wire        pll_lock;

//*****************************************************
//**                    main code
//*****************************************************

//锁相环
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
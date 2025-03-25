//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           hs_dual_da
// Last modified Date:  2019/07/31 17:04:35
// Last Version:        V1.0
// Descriptions:        双路DA实验
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/07/31 17:04:35
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module hs_dual_da(
    input                 sys_clk    ,  //系统时钟
    input                 sys_rst_n  ,  //系统复位，低电平有效
    //DA芯片接口
    output                da_clk_1   ,  //第一路DAC驱动时钟
    output    [9:0]       da_data_1  ,  //第一路DAC数据
    output                da_clk_2   ,  //第二路DAC驱动时钟
    output    [9:0]       da_data_2     //第二路DAC数据
);

//wire define 
wire      [9:0]    rd_addr ;            //ROM地址
wire      [9:0]    rd_data ;            //ROM数据
wire               clk_50m ;            //50MHz时钟
wire               pll_lock;            //PLL时钟锁定信号
wire               rst_n   ;            //复位信号，低有效

//*****************************************************
//**                    main code
//*****************************************************

//通过系统复位信号和PLL时钟锁定信号来产生一个新的复位信号
assign  rst_n = sys_rst_n & pll_lock;
assign  da_clk_2 = da_clk_1;
assign  da_data_2 = da_data_1;

//pll
pll_clk u_pll_clk (
  .clkin1        (sys_clk),       
  .pll_lock      (pll_lock),    
  .clkout0       (clk_50m)    
);
    
//ROM模块
rom_1024x10b the_instance_name (
  .addr          (rd_addr),          
  .clk           (sys_clk),            
  .rst           (~rst_n),            
  .rd_data       (rd_data)     
);
//DA数据发送
da_wave_send u_da_wave_send(
    .clk         (clk_50m  ),
    .rst_n       (rst_n    ),
    .rd_data     (rd_data  ),
    .rd_addr     (rd_addr  ),
    .da_clk      (da_clk_1 ),
    .da_data     (da_data_1)
    );

endmodule
//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           hs_ad_da
// Last modified Date:  2019/07/31 17:04:35
// Last Version:        V1.0
// Descriptions:        高速AD/DA实验
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/07/31 17:04:35
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module hs_ad_da(
    input                 sys_clk     ,  //系统时钟
    input                 sys_rst_n   ,  //系统复位，低电平有效
    //DA芯片接口
    output                da_clk      ,  //DA(AD9708)驱动时钟,最大支持125Mhz时钟
    output    [7:0]       da_data     ,  //输出给DA的数据
    //AD芯片接口
    input     [7:0]       ad_data     /* synthesis PAP_MARK_DEBUG="1" */,  //AD输入数据
    //模拟输入电压超出量程标志(本次试验未用到)
    input                 ad_otr      /* synthesis PAP_MARK_DEBUG="1" */,  //0:在量程范围 1:超出量程
    output                ad_clk         //AD(AD9280)驱动时钟,最大支持32Mhz时钟 
);

//wire define 
wire      [7:0]    rd_addr;              //ROM读地址
wire      [7:0]    rd_data;              //ROM读出的数据
wire               clk_50m;              //50MHz时钟
wire               clk_25m;              //25MHz时钟
wire               pll_lock;             //pll时钟锁定信号
wire               rst_n  ;              //复位信号，低有效

//*****************************************************
//**                    main code
//*****************************************************

//通过系统复位信号和PLL时钟锁定信号来产生一个新的复位信号
assign   rst_n = sys_rst_n & pll_lock ;
assign   ad_clk = clk_25m ;

//pll
pll_clk  u_pll_clk(
  .clkin1        (sys_clk),       
  .pll_lock      (pll_lock),    
  .clkout0       (clk_50m),     
  .clkout1       (clk_25m)    
);

//DA数据发送
da_wave_send u_da_wave_send(
    .clk         (clk_50m), 
    .rst_n       (rst_n),
    .rd_data     (rd_data),
    .rd_addr     (rd_addr),
    .da_clk      (da_clk),  
    .da_data     (da_data)
    );

//ROM存储波形
rom_256x8b  u_rom_256x8b (
  .clk     (clk_50m), // input wire clka
  .addr    (rd_addr), // input wire [7 : 0] addra
  .rst     (~rst_n),
  .rd_data (rd_data)  // output wire [7 : 0] douta
);
   

endmodule
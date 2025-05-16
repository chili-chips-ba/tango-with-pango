//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ip_fifo
// Created by:          正点原子
// Created date:        2023年10月10日14:17:02
// Version:             V1.0
// Descriptions:        IP核之FIFO实验
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ip_fifo(
    input          sys_clk     ,  // 时钟信号
    input          sys_rst_n   ,  // 复位信号
    //冗余逻辑，仅仅是为了将端口拉出去，否则没有输出信号的话无法在线抓取信号
    //无需分配引脚
    output         fifo_wr_en  , // FIFO写使能信号
    output         fifo_rd_en  , // FIFO读使能信号
    output         fifo_full   , // FIFO满信号
    output         fifo_empty  , // FIFO空信号
    output  [7:0]  fifo_wr_data, // 写入到FIFO的数据
    output  [7:0]  fifo_rd_data  // 从FIFO读出的数据
);

//wire define
wire         pll_lock           ; // 时钟锁定信号
wire         clk_50m            ; // 50M时钟
wire         clk_100m           ; // 100M时钟
wire         rst_n              ; // 复位，低有效
wire         almost_full        ; // FIFO将满信号
wire         almost_empty       ; // FIFO将空信号
wire  [8:0]  fifo_wr_data_count ; // FIFO写时钟域的数据计数
wire  [8:0]  fifo_rd_data_count ; // FIFO读时钟域的数据计数

//*****************************************************
//**                    main code
//*****************************************************

//通过系统复位信号和时钟锁定信号来产生一个新的复位信号
assign   rst_n = sys_rst_n & pll_lock;

//例化PLL IP核
pll_clk u_pll_clk (
  .pll_rst           (~sys_rst_n        ), // input
  .clkin1            (sys_clk           ), // input
  .pll_lock          (pll_lock          ), // output
  .clkout0           (clk_50m           ), // output
  .clkout1           (clk_100m          )  // output
);

//例化FIFO IP核
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

//例化写FIFO模块
fifo_wr  u_fifo_wr(
    .wr_clk              (clk_50m           ), // 写时钟
    .rst_n               (rst_n             ), // 复位信号

    .fifo_wr_data_count  (fifo_wr_data_count), // FIFO写时钟域的数据计数
    .fifo_wr_en          (fifo_wr_en        ), // fifo写请求
    .fifo_wr_data        (fifo_wr_data      ), // 写入FIFO的数据
    .fifo_empty          (fifo_empty        )  // fifo空信号
);

//例化读FIFO模块
fifo_rd  u_fifo_rd(
    .rd_clk              (clk_100m          ), // 读时钟
    .rst_n               (rst_n             ), // 复位信号

    .fifo_rd_data_count  (fifo_rd_data_count), // FIFO读时钟域的数据计数
    .fifo_rd_en          (fifo_rd_en        ), // fifo读请求
    .fifo_rd_data        (fifo_rd_data      ), // 从FIFO输出的数据
    .fifo_full           (fifo_full         )  // fifo满信号
);

endmodule 
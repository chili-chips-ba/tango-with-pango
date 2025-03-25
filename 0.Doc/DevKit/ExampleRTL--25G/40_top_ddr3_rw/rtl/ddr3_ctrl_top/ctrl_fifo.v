//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ctrl_fifo
// Created by:          正点原子
// Created date:        2023年2月3日14:17:02
// Version:             V1.0
// Descriptions:        ctrl_fifo
//
//----------------------------------------------------------------------------------------
//****************************************************************************************///

module ctrl_fifo(
    input               rst_n,
    input               wd_clk,
    input               rd_clk,
    input               clk_100,
    //写fifo接口
    input               wfifo_wr_en,    // wfifo 写请求
    input   [15:0]      wfifo_wr_data,  // wfifo 写入数据
    input               wfifo_rd_en,    // wfifo 读请求
    output  [127:0]     wfifo_rd_data,  // wfifo 读出数据
    output  [10:0]      wfifo_rcount,   // wfifo 读计数
    //读fifo接口
    input               rfifo_wr_en,    // rfifo 写请求
    input   [127:0]     rfifo_wr_data,  // rfifo 写数据
    output  [10:0]      rfifo_wcount,   // rfifo 写计数
    input               rfifo_rd_en,    // rfifo 读出请求
    output  [15:0]      rfifo_rd_data   // rfifo 读数据
);

//*****************************************************
//**                    main code
//***************************************************** 

// 写fifo
wr_fifo u_wr_fifo (
  .wr_clk           (wd_clk         ),
  .wr_rst           (~rst_n         ),
  .wr_en            (wfifo_wr_en    ),
  .wr_data          (wfifo_wr_data  ),
  .wr_full          ( ),
  .wr_water_level   ( ),
  .almost_full      ( ),
  .rd_clk           (clk_100        ),
  .rd_rst           (~rst_n         ),
  .rd_en            (wfifo_rd_en    ),
  .rd_data          (wfifo_rd_data  ),
  .rd_empty         ( ),
  .rd_water_level   (wfifo_rcount ),
  .almost_empty     ( ) 
);

//读fifo
rd_fifo u_rd_fifo (
  .wr_clk           (clk_100        ),
  .wr_rst           (~rst_n         ),
  .wr_en            (rfifo_wr_en    ),
  .wr_data          (rfifo_wr_data  ),
  .wr_full          ( ),
  .wr_water_level   (rfifo_wcount ),
  .almost_full      ( ),
  .rd_clk           (rd_clk         ),
  .rd_rst           (~rst_n         ),
  .rd_en            (rfifo_rd_en    ),
  .rd_data          (rfifo_rd_data  ),
  .rd_empty         ( ),
  .rd_water_level   ( ),
  .almost_empty     ( ) 
);

endmodule
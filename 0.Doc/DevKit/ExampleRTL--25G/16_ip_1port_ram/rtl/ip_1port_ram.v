//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ip_1port_ram
// Created by:          正点原子
// Created date:        2023年9月8日14:17:02
// Version:             V1.0
// Descriptions:        IP核之单端口RAM实验
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ip_1port_ram(
    
    input          sys_clk   ,   //系统时钟
    input          sys_rst_n ,   //系统复位，低电平有效

    //冗余逻辑，仅仅是为了将端口拉出去，否则没有输出信号的话无法在线抓取信号
    //无需分配引脚
    output [7:0] ram_wr_data ,   //ram写数据
    output [7:0] ram_rd_data ,   //ram读数据
    output [4:0] ram_addr    ,   //ram读写地址
    output       ram_rw_en       //ram读写使能，0：读数据  1：写数据
    
    );

//*****************************************************
//**                    main code
//*****************************************************

//例化单端口RAM IP核
ram_1port u_ram_1port (
  .wr_data    (ram_wr_data ),    // input [7:0]
  .addr       (ram_addr    ),    // input [4:0]
  .wr_en      (ram_rw_en   ),    // input
  .clk        (sys_clk     ),    // input
  .rst        (~sys_rst_n  ),    // input
  .rd_data    (ram_rd_data )     // output [7:0]
);

//RAM读写模块
ram_rw u_ram_rw (
    .clk            (sys_clk     ),
    .rst_n          (sys_rst_n   ),
    .ram_rw_en      (ram_rw_en   ),
    .ram_addr       (ram_addr    ),
    .ram_wr_data    (ram_wr_data )
    );
  
endmodule
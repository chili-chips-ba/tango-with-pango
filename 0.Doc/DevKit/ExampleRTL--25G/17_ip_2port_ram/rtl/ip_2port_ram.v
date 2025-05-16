//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ip_2port_ram
// Created by:          正点原子
// Created date:        2023年9月9日14:17:02
// Version:             V1.0
// Descriptions:        IP核之双端口RAM实验
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ip_2port_ram(
    input               sys_clk        ,  //系统时钟
    input               sys_rst_n      ,  //系统复位，低电平有效
    
    //冗余逻辑，仅仅是为了将端口拉出去，否则没有输出信号的话无法在线抓取信号
    //无需分配引脚
    output              ram_wr_en      ,
    output    [4:0]     ram_wr_addr    ,
    output    [7:0]     ram_wr_data    ,
    output    [4:0]     ram_rd_addr    ,
    output    [7:0]     ram_rd_data  
    );
   
//wire define
wire        rd_rst  ;   //读端口复位(使能)信号
wire        rd_flag ;   //读启动标志

//*****************************************************
//**                    main code
//*****************************************************

ram_2port u_ram_2port (
  .wr_data    (ram_wr_data),    // input [7:0]  ram写数据
  .wr_addr    (ram_wr_addr),    // input [4:0]  ram写地址
  .wr_en      (ram_wr_en  ),    // input        
  .wr_clk     (sys_clk    ),    // input
  .wr_rst     (~sys_rst_n ),    // input
  .rd_addr    (ram_rd_addr),    // input [4:0]  ram读地址
  .rd_data    (ram_rd_data),    // output [7:0] ram读数据 
  .rd_clk     (sys_clk    ),    // input
  .rd_rst     (rd_rst     )     // input
);

//RAM写模块
ram_wr u_ram_wr(
    .clk           (sys_clk    ),
    .rst_n         (sys_rst_n  ),
    .rd_flag       (rd_flag    ),
    .ram_wr_en     (ram_wr_en  ), //ram写使能 
    .ram_wr_addr   (ram_wr_addr),
    .ram_wr_data   (ram_wr_data)
    );

//RAM读模块    
ram_rd u_ram_rd(
    .clk           (sys_clk    ),
    .rst_n         (sys_rst_n  ),
    .rd_rst        (rd_rst     ), //ram读端口复位（使能）信号
    .rd_flag       (rd_flag    ),
    .ram_rd_addr   (ram_rd_addr),
    .ram_rd_data   (ram_rd_data)
    );

endmodule
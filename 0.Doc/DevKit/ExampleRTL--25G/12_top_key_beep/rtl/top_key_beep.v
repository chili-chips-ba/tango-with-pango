//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           top_key_beep
// Created by:          正点原子
// Created date:        2023年2月16日14:17:02
// Version:             V1.0
// Descriptions:        按键控制蜂鸣器实验顶层模块
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module top_key_beep(
    input        sys_clk   ,    //系统时钟
    input        sys_rst_n ,    //系统复位，低电平有效

    input        key       ,    //按键    
    output       beep           //蜂鸣器
);

//parameter define
parameter  CNT_MAX = 20'd100_0000;   //消抖时间20ms

//wire define
wire key_filter ;                    //按键消抖后的值

//*****************************************************
//**                    main code
//*****************************************************

//例化按键消抖模块
key_debounce #(
    .CNT_MAX    (CNT_MAX)  
)u_key_debounce(
    .sys_clk       (sys_clk),
    .sys_rst_n     (sys_rst_n),
    .key           (key),
    .key_filter    (key_filter)
    );

//例化按键控制蜂鸣器模块
key_beep  u_key_beep(
    .sys_clk       (sys_clk),
    .sys_rst_n     (sys_rst_n),
    .key_filter    (key_filter),
    .beep          (beep)
    );

endmodule

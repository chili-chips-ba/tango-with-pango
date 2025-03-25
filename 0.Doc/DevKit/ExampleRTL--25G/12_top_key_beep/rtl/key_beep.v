//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           key_beep
// Created by:          正点原子
// Created date:        2023年2月16日14:22:02
// Version:             V1.0
// Descriptions:        按键控制蜂鸣器模块
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module key_beep(
    input        sys_clk,
    input        sys_rst_n,

    input        key_filter,   //消抖后按键值
    output  reg  beep          //蜂鸣器
    );

//reg define
reg    key_filter_d0;          //将消抖后的按键值延迟一个时钟周期

//wire define
wire   neg_key_filter;         //按键有效脉信号
 
//*****************************************************
//**                    main code
//*****************************************************

//捕获按键端口的下降沿，得到一个时钟周期的脉冲信号
assign  neg_key_filter = (~key_filter) & key_filter_d0;

//对按键端口的数据延迟一个时钟周期
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) 
        key_filter_d0 <= 1'b1;
    else 
        key_filter_d0 <= key_filter;
end

//每次按键按下时，就翻转蜂鸣器的状态
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        beep <= 1'b1;
    else if(neg_key_filter)  //有效的一次按键被按下
        beep <= ~beep;
    else
        beep <= beep;
end

endmodule

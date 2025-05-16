//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           tb_led
// Created by:          正点原子
// Created date:        2023年3月30日11:12:36
// Version:             V1.0
// Descriptions:        点亮LED实验激励文件
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

`timescale 1ns / 1ns        //仿真单位/仿真精度

module tb_led();

//reg define
reg           key;
//wire define
wire          led;

//信号初始化
initial begin
    key <= 1'b1;   //按键上电默认高电平

//key信号变化
    #200           //延迟200ns
    key <= 1'b1;   //按键没有被按下
    #1000  
    key <= 1'b0;   //按键被按下
    #600  
    key <= 1'b1;
    #1000  
    key <= 1'b0;
end

//例化led模块
led  u_led(
    .key          (key),
    .led          (led)
    );

endmodule


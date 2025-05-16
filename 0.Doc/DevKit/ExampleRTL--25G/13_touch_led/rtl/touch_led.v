//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           touch_led
// Created by:          正点原子
// Created date:        2023年2月22日14:17:02
// Version:             V1.0
// Descriptions:        触摸按键控制led灯实验
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module touch_led(
    //input
    input        sys_clk,      //时钟信号50Mhz
    input        sys_rst_n,    //复位信号
    input        touch_key,    //触摸按键 
 
    //output
    output  reg  led           //LED灯
);

//reg define
reg    touch_key_d0;    //触摸按键端口的数据延迟一个时钟周期
reg    touch_key_d1;    //触摸按键端口的数据延迟两个时钟周期

//wire define
wire   touch_en;       //触摸有效脉信号

//*****************************************************
//**                    main code
//*****************************************************

//捕获触摸按键端口的上升沿，得到一个时钟周期的脉冲信号
assign  touch_en = (~touch_key_d1) & touch_key_d0;

//对触摸按键端口的数据延迟两个时钟周期
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        touch_key_d0 <= 1'b0;
        touch_key_d1 <= 1'b0;
    end
    else begin
        touch_key_d0 <= touch_key;
        touch_key_d1 <= touch_key_d0;
    end 
end

//根据触摸按键上升沿的脉冲信号切换led状态
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        led <= 1'b1;       //默认状态下,点亮LED
    else begin 
        if (touch_en)      //检测到触摸按键信号
            led <= ~led;
    end
end

endmodule


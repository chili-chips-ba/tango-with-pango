//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           led_disp
// Created by:          正点原子
// Created date:        2023年2月3日14:17:02
// Version:             V1.0
// Descriptions:        led_disp
//
//----------------------------------------------------------------------------------------
//****************************************************************************************///

module led_disp(
    input clk_50m,            //系统时钟
    input rst_n,              //系统复位
    input error_flag,         //错误标志信号
    input init_calib_complete,
    output reg [1:0] led     //LED 灯 
);
//reg define
reg [24:0] led_cnt;          //控制 LED 闪烁周期的计数器

//*****************************************************
//**                    main code
//*****************************************************

//计数器对 50MHz 时钟计数，计数周期为 0.5s
always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n)
        led_cnt <= 25'd0;
    else if(led_cnt < 25'd25000000)
        led_cnt <= led_cnt + 25'd1;
    else
        led_cnt <= 25'd0;
end

//利用 LED 灯不同的显示状态指示错误标志的高低
always @(posedge clk_50m or negedge rst_n) begin
    if(rst_n == 1'b0)begin
        led[1] <= 1'b0;
        led[0] <= 1'b0;
    end
    else if(!init_calib_complete) begin
        if(led_cnt == 25'd25000000)
            led[0] <= ~led[0]; //DDR3初始化失败时，LED[0]每隔0.5s闪烁一次
        else
            led[0] <= led[0];
        end 
    else if(error_flag) begin
        if(led_cnt == 25'd25000000)
            led[1] <= ~led[1]; //错误标志为高时，LED[1]每隔 0.5s 闪烁一次
        else
            led[1] <= led[1];
        end 
    else begin
        led[0] <= 1'b1; //DDR3初始化成功时，LED[0]常亮
        led[1] <= 1'b1; //错误标志为低时，LED[1]常亮
    end
end

endmodule
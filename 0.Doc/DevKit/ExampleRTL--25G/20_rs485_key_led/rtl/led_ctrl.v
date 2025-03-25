//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           led_ctrl
// Created by:          正点原子
// Created date:        2023年5月31日14:17:02
// Version:             V1.0
// Descriptions:        led灯控制模块
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module led_ctrl(
    input            clk     ,    //外部50M时钟
    input            rst_n   ,    //外部复位信号，低有效
    
    input            led_en  ,    //led控制使能
    input      [1:0] led_data,    //led控制数据
    
    output reg [1:0] led          //led灯
    );

//*****************************************************
//**                    main code
//*****************************************************

//控制led灯的变化
always @(posedge clk or negedge rst_n) begin 
    if (!rst_n) 
        led <= 2'b00;
    else if(led_en)              //在led_en使能时，改变led灯的状态
            led <= ~led_data;    //按键按下时为低电平，而led高电平时点亮
        else
            led <= led;
end
    
endmodule 
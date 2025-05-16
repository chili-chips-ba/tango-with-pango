//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           swi_led
// Created by:          正点原子
// Created date:        2023年2月3日14:17:02
// Version:             V1.0
// Descriptions:        swi_led
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module swi_led(
    input              clk    ,
    input              rst_n  ,
    input     [7:0]    swi    ,
    output reg[7:0]    led   
);

//*****************************************************
//**                    main code                      
//*****************************************************

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
        led <= 8'b0000_0000;
    else
        led <= swi;
end

endmodule
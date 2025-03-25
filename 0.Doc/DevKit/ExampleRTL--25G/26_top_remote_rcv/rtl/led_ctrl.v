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
// Last modified Date:  2023年9月8日13:11:06
// Last Version:        V1.0
// Descriptions:        LED灯控制
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2023年9月8日13:11:06
// Version:             V1.0
// Descriptions:        The original version
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module led_ctrl(
    input             sys_clk   ,  //系统时钟
    input             sys_rst_n ,  //系统复位信号，低电平有效
    
    input             repeat_en ,  //重复码触发信号
    output    reg     led          //LED灯
    );

//reg define
reg            repeat_en_d0 ;      //repeat_en信号打拍采沿
reg            repeat_en_d1 ;
reg    [22:0]  led_cnt      ;      //LED灯计数器,用于控制LED灯亮灭

//wire define
wire           pos_repeat_en;

//*****************************************************
//**                    main code
//*****************************************************

assign  pos_repeat_en = ~repeat_en_d1 & repeat_en_d0;

////repeat_en信号打拍采沿
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        repeat_en_d0 <= 1'b0;
        repeat_en_d1 <= 1'b0;
    end
    else begin
        repeat_en_d0 <= repeat_en;
        repeat_en_d1 <= repeat_en_d0;
    end
end    

//单次重复码:亮80ms 灭20ms
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        led <= 1'b0;
    else if (pos_repeat_en)//led亮的时间:4_000_000*20ns=80ms
        led <= 1'b1;
    else if (led_cnt < 23'd1_000_000)//led灭的时间:1_000_000*20ns=20ms
        led <= 1'b0;
    else
        led <= led;
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) 
        led_cnt <= 23'd0;
    else if(pos_repeat_en)
        led_cnt <= 23'd5_000_000;
    else if(led_cnt != 23'd0)
        led_cnt <= led_cnt - 23'd1;
    else
        led_cnt <= led_cnt;
end
  
endmodule
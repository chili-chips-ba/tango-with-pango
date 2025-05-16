//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           breath_led
// Created by:          正点原子
// Created date:        2023年3月1日09:40:02
// Version:             V1.0
// Descriptions:        呼吸灯实验
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module breath_led(
    input       sys_clk ,      //系统时钟 50MHz
    input       sys_rst_n ,    //系统复位，低电平有效
    
    output reg  led            //LED灯
);

//parameter define
parameter CNT_2US_MAX = 7'd100;    
parameter CNT_2MS_MAX = 10'd1000; 
parameter CNT_2S_MAX  = 10'd1000; 

//reg define
reg [6:0] cnt_2us; 
reg [9:0] cnt_2ms;   
reg [9:0] cnt_2s;     
reg       inc_dec_flag; //亮度递增/递减 0:递增 1:递减

//*****************************************************
//**                  main code
//*****************************************************

//cnt_2us:计数2us
always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt_2us <= 7'b0;
    else if(cnt_2us == (CNT_2US_MAX - 7'b1 ))
        cnt_2us <= 7'b0;
    else
        cnt_2us <= cnt_2us + 7'b1;
end

//cnt_2ms:计数2ms
always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt_2ms <= 10'b0;
    else if(cnt_2ms == (CNT_2MS_MAX - 10'b1) && cnt_2us == (CNT_2US_MAX - 7'b1))
        cnt_2ms <= 10'b0;
    else if(cnt_2us == CNT_2US_MAX - 7'b1)
        cnt_2ms <= cnt_2ms + 10'b1;
    else
        cnt_2ms <= cnt_2ms;
end

//cnt_2s:计数2s
always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt_2s <= 10'b0;
    else if(cnt_2s == (CNT_2S_MAX - 10'b1) && cnt_2ms == (CNT_2MS_MAX - 10'b1) && cnt_2us == (CNT_2US_MAX - 7'b1))
        cnt_2s <= 10'b0;
    else if(cnt_2ms == (CNT_2MS_MAX - 10'b1) && cnt_2us == (CNT_2US_MAX - 7'b1))
        cnt_2s <= cnt_2s + 10'b1;
    else
        cnt_2s <= cnt_2s;         
end

//inc_dec_flag为低电平，led灯由暗变亮，inc_dec_flag为高电平，led灯由亮变暗
always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        inc_dec_flag <= 1'b0;
    else if(cnt_2s == (CNT_2S_MAX - 10'b1) && cnt_2ms ==( CNT_2MS_MAX - 10'b1) && cnt_2us == (CNT_2US_MAX - 7'b1))
        inc_dec_flag <= ~inc_dec_flag;
    else
        inc_dec_flag <= inc_dec_flag;
end

//led:输出信号连接到外部的led灯
always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        led <= 1'b0;
    else if((inc_dec_flag == 1'b1 && cnt_2ms >= cnt_2s) || (inc_dec_flag == 1'b0 && cnt_2ms <= cnt_2s))
        led <= 1'b1;
    else
        led <= 1'b0;
end

endmodule
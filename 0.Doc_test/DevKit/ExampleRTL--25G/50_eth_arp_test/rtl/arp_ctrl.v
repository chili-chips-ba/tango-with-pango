//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                 
//----------------------------------------------------------------------------------------
// File name:           arp_ctrl
// Last modified Date:  2020/2/13 9:20:14
// Last Version:        V1.0
// Descriptions:        arp控制模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2020/2/13 9:20:14
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module arp_ctrl(
    input                clk        , //输入时钟   
    input                rst_n      , //复位信号，低电平有效
    
    input                touch_key  , //触摸按键,用于触发开发板发出ARP请求
    input                arp_rx_done, //ARP接收完成信号
    input                arp_rx_type, //ARP接收类型 0:请求  1:应答 
    output  reg          arp_tx_en  , //ARP发送使能信号
    output  reg          arp_tx_type  //ARP发送类型 0:请求  1:应答
    );

//reg define
reg         touch_key_d0;
reg         touch_key_d1;

//wire define
wire        pos_touch_key;  //touch_key信号上升沿

//*****************************************************
//**                    main code
//*****************************************************

assign pos_touch_key = ~touch_key_d1 & touch_key_d0;

//对arp_tx_en信号延时打拍两次,用于采touch_key的上升沿
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        touch_key_d0 <= 1'b0;
        touch_key_d1 <= 1'b0;
    end
    else begin
        touch_key_d0 <= touch_key;
        touch_key_d1 <= touch_key_d0;
    end
end

//为arp_tx_en和arp_tx_type赋值
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        arp_tx_en <= 1'b0;
        arp_tx_type <= 1'b0;
    end
    else begin
        if(pos_touch_key == 1'b1) begin  //检测到输入触摸按键上升沿
            arp_tx_en <= 1'b1;           
            arp_tx_type <= 1'b0;
        end
        //接收到ARP请求,开始控制ARP发送模块应答
        else if((arp_rx_done == 1'b1) && (arp_rx_type == 1'b0)) begin
            arp_tx_en <= 1'b1;
            arp_tx_type <= 1'b1;
        end
        else
            arp_tx_en <= 1'b0;
    end
end

endmodule

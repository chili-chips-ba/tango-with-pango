//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           key_trig
// Created by:          正点原子
// Created date:        2023年5月31日14:17:02
// Version:             V1.0
// Descriptions:        按键触发模块
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module key_trig(
    input            clk           ,  //外部50M时钟
    input            rst_n         ,  //外部复位信号，低有效
    
    input      [1:0] key           ,  //外部按键输入
    
    output reg       key_data_valid,  //按键数据有效标志
    output     [1:0] key_data         //按键数据
    );

//reg define
reg [1:0] key_data_d0;
reg [1:0] key_data_d1;

//*****************************************************
//**                    main code
//*****************************************************

//对key_data信号打两拍用于判断按键是否发生改变
always @(posedge clk or negedge rst_n) begin 
    if (!rst_n) begin 
        key_data_d0 <= 2'b11;
        key_data_d1 <= 2'b11;
    end
    else begin
        key_data_d0 <= key_data;
        key_data_d1 <= key_data_d0;
    end
end

//当检测到按键数据发生改变时，key_data_valid拉高
always @(posedge clk or negedge rst_n) begin 
    if (!rst_n)
        key_data_valid <= 1'b0;
    else if (key_data_d1 != key_data_d0)
        key_data_valid  <= 1'b1;
    else
        key_data_valid  <= 1'b0;
end

//按键0消抖模块
key_debounce u_key_debounce_0(
    .sys_clk        (clk        ), 
    .sys_rst_n      (rst_n      ),
    
    .key            (key[0]     ),
    .key_filter     (key_data[0])
    );

//按键1消抖模块
key_debounce u_key_debounce_1(
    .sys_clk        (clk        ), 
    .sys_rst_n      (rst_n      ),
    
    .key            (key[1]     ),
    .key_filter     (key_data[1])
    );

endmodule 

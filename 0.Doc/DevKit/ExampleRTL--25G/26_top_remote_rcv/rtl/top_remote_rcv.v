//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           top_remote_rcv
// Last modified Date:  2023年9月8日13:11:06
// Last Version:        V1.0
// Descriptions:        红外遥控实验
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2023年9月8日13:11:06
// Version:             V1.0
// Descriptions:        The original version
//----------------------------------------------------------------------------------------
//****************************************************************************************// 

module top_remote_rcvr#(
    //parameter define
    parameter       CHAR_POS_X   = 11'd1            ,   // 字符区域起始点横坐标
    parameter       CHAR_POS_Y   = 11'd1            ,   // 字符区域起始点纵坐标
    parameter       CHAR_WIDTH   = 11'd88           ,   // 字符区域宽度
    parameter       CHAR_HEIGHT  = 11'd16           ,   // 字符区域高度
    parameter       WHITE        = 24'hFFFFFF       ,   // 背景色，白色
    parameter       BLACK        = 24'h0                // 字符颜色，黑色
)(
    input             sys_clk  ,    //系统时钟 
    input             sys_rst_n,    //系统复位信号，低电平有效
    input             remote_in,    //红外接收信号

	output             lcd_hs     ,             // LCD 行同步信号
	output             lcd_vs     ,             // LCD 场同步信号
	output             lcd_de     ,             // LCD 数据输入使能
	inout      [23:0]  lcd_rgb    ,             // LCD RGB颜色数据
	output             lcd_bl     ,             // LCD 背光控制信号
	output             lcd_clk    ,             // LCD 采样时钟
    output             lcd_rst    ,
    output             led                      //led灯
);

//wire define
wire  [7:0]   data       ;
wire          repeat_en  ;

//*****************************************************
//**                    main code
//*****************************************************


//HS0038B驱动模块
remote_rcv u_remote_rcv(               
    .sys_clk        (sys_clk),  
    .sys_rst_n      (sys_rst_n),    
    .remote_in      (remote_in),
    .repeat_en      (repeat_en),                
    .data_en        (),
    .data           (data)
    );

led_ctrl  u_led_ctrl(
    .sys_clk       (sys_clk),
    .sys_rst_n     (sys_rst_n),
    .repeat_en     (repeat_en),
    .led           (led)
    );

//例化LCD显示模块
lcd_rgb_char 
#(
    .CHAR_POS_X     (CHAR_POS_X ),
    .CHAR_POS_Y     (CHAR_POS_Y ),
    .CHAR_WIDTH     (CHAR_WIDTH ),
    .CHAR_HEIGHT    (CHAR_HEIGHT),
    .WHITE          (WHITE      ),
    .BLACK          (BLACK      )
)
u_lcd_rgb_char(
    .sys_clk        (sys_clk    ),
    .sys_rst_n      (sys_rst_n  ),
    .data           (data       ),     
    .lcd_hs         (lcd_hs     ),          // LCD 行同步信号
    .lcd_vs         (lcd_vs     ),          // LCD 场同步信号
    .lcd_de         (lcd_de     ),          // LCD 数据输入使能
    .lcd_rgb        (lcd_rgb    ),          // LCD RGB888颜色数据
    .lcd_bl         (lcd_bl     ),          // LCD 背光控制信号
    .lcd_clk        (lcd_clk    ),          // LCD 采样时钟
    .lcd_rst        (lcd_rst    )
);

endmodule
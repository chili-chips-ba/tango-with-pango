//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           top_dht11
// Last modified Date:  2018年5月24日09:43:39
// Last Version:        V1.0
// Descriptions:        温湿度数码管显示实验
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018年5月24日09:43:44
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
// Modified by:         正点原子
// Modified date:       
// Version:             
// Descriptions:        
//
//----------------------------------------------------------------------------------------
//****************************************************************************************/

module top_dht11#(
    //parameter define
    parameter       CHAR_POS_X   = 11'd1            ,   // 字符区域起始点横坐标
    parameter       CHAR_POS_Y   = 11'd1            ,   // 字符区域起始点纵坐标
    parameter       CHAR_WIDTH   = 11'd88           ,   // 字符区域宽度
    parameter       CHAR_HEIGHT  = 11'd16           ,   // 字符区域高度
    parameter       WHITE        = 24'hFFFFFF       ,   // 背景色，白色
    parameter       BLACK        = 24'h0                // 字符颜色，黑色
)(
    input            sys_clk  	 ,  		   //系统时钟 
    input            sys_rst_n	 ,  		   //系统复位
											   
											  
    inout            dht11    	 ,  		   //DHT11总线
    input            key      	 ,  		   //按键
    output           lcd_hs      ,             // LCD 行同步信号
	output           lcd_vs      ,             // LCD 场同步信号
	output           lcd_de      ,             // LCD 数据输入使能
	inout    [23:0]  lcd_rgb     ,             // LCD RGB颜色数据
	output           lcd_bl      ,             // LCD 背光控制信号
	output           lcd_clk     ,             // LCD 采样时钟
    output           lcd_rst     

);
//wire define
wire  [31:0]  data_valid;
wire  [19:0]  data      ;
wire  [5:0]   point     ;
wire          flag_mux  ;


//*****************************************************
//**                    main code
//*****************************************************

//dht11驱动模块
dht11_drive u_dht11_drive (
    .sys_clk        (sys_clk),
    .rst_n          (sys_rst_n),
    
    .dht11          (dht11),
    .data_valid     (data_valid)
    );


//按键消抖模块
key_debounce u_key_debounce(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    
    .key            (key),
    .key_flag       (key_flag),
    .key_value      (key_value)
    );

//按键控制温/湿度显示
dht11_key u_dht11_key(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    
    .key_flag       (key_flag),
    .key_value      (key_value),
    .data_valid     (data_valid),
    
    .data           (data),
    .sign           (sign),
    .en             (en),   
    .flag_mux       (flag_mux),                  
    .point          (point)
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
    .lcd_rst        (lcd_rst    ),
    .flag_mux       (flag_mux   ),
    .sign           (sign       )
);
endmodule 
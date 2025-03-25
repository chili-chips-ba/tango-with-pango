//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           lcd_rgb_char
// Created by:          正点原子
// Created date:        2023年2月3日14:17:02
// Version:             V1.0
// Descriptions:        lcd_rgb_char
//
//----------------------------------------------------------------------------------------
//****************************************************************************************///

module  lcd_rgb_char(
    input              sys_clk      ,
    input              sys_rst_n    ,
	input      [29:0]  data         , 

    output             lcd_hs       ,       // LCD 行同步信号
    output             lcd_vs       ,       // LCD 场同步信号
    output             lcd_de       ,       // LCD 数据输入使能
    inout      [23:0]  lcd_rgb      ,       // LCD RGB565颜色数据
    output             lcd_bl       ,       // LCD 背光控制信号
    output             lcd_clk      ,       // LCD 采样时钟
    output             lcd_rst              // LCD 复位
);
//parameter define
parameter  CHAR_POS_X  = 11'd1      ;       // 字符区域起始点横坐标
parameter  CHAR_POS_Y  = 11'd1      ;       // 字符区域起始点纵坐标
parameter  CHAR_WIDTH  = 11'd88     ;       // 字符区域宽度
parameter  CHAR_HEIGHT = 11'd16     ;       // 字符区域高度
parameter  WHITE       = 24'hFFFFFF ;       // 背景色，白色
parameter  BLACK       = 24'h0      ;       // 字符颜色，黑色

//wire define
wire  [10:0]  pixel_xpos            ;
wire  [10:0]  pixel_ypos            ;
wire  [23:0]  pixel_data            ;
wire  [15:0]  lcd_id                ;
wire  [23:0]  lcd_rgb_o             ;
wire          lcd_pclk              ;
wire  [35:0]  bcd_data;       //9位

//*****************************************************
//**                    main code
//*****************************************************

//RGB565数据输出
assign lcd_rgb = lcd_de ? lcd_rgb_o : {24{1'bz}};

//读rgb lcd ID 模块
rd_id u_rd_id(
    .clk            (sys_clk    ),
    .rst_n          (sys_rst_n  ),
    .lcd_rgb        (lcd_rgb    ), 
    
    .lcd_id         (lcd_id     )
);

//分频模块，根据不同的LCD ID输出相应的频率的驱动时钟
clk_div  u_clk_div(
    .clk            (sys_clk    ),
    .rst_n          (sys_rst_n  ),
    
    .lcd_id         (lcd_id     ),
    .lcd_pclk       (lcd_pclk   )
);

//二进制转BCD码
binary2bcd u_binary2bcd(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .data           (data    ),
    
    .bcd_data       (bcd_data)
);

//lcd显示模块
lcd_display 
#(
    .CHAR_POS_X     (CHAR_POS_X  ),
    .CHAR_POS_Y     (CHAR_POS_Y  ),
    .CHAR_WIDTH     (CHAR_WIDTH  ),
    .CHAR_HEIGHT    (CHAR_HEIGHT ),
    .WHITE          (WHITE       ),
    .BLACK          (BLACK       )
)
u_lcd_display(
    .lcd_pclk       (lcd_pclk   ),
    .sys_rst_n      (sys_rst_n  ),
    .data           (bcd_data   ),
    
    .pixel_xpos     (pixel_xpos ),
    .pixel_ypos     (pixel_ypos ),
    .pixel_data     (pixel_data )
);

//lcd驱动模块    
lcd_driver u_lcd_driver(
    .lcd_pclk       (lcd_pclk   ),
    .rst_n          (sys_rst_n  ),
    .lcd_id         (lcd_id     ),
    .pixel_data     (pixel_data ),

    .pixel_xpos     (pixel_xpos ),
    .pixel_ypos     (pixel_ypos ),
    .lcd_de         (lcd_de     ),
    .lcd_hs         (lcd_hs     ),
    .lcd_vs         (lcd_vs     ),
    .lcd_bl         (lcd_bl     ),
    .lcd_clk        (lcd_clk    ),
    .lcd_rst        (lcd_rst    ),
    .lcd_rgb        (lcd_rgb_o  )
);

endmodule
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
// Created date:        2023年5月24日14:17:02
// Version:             V1.0
// Descriptions:        RGB LCD顶层模块
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//
module  lcd_rgb_char(
    input              sys_clk  ,
    input              sys_rst_n,
    //时间和日期
    input       [7:0]  sec      ,  // 秒
    input       [7:0]  min      ,  // 分
    input       [7:0]  hour     ,  // 时
    input       [7:0]  day      ,  // 日
    input       [7:0]  mon      ,  // 月
    input       [7:0]  year     ,  // 年   
    
    //RGB LCD接口 
    output             lcd_hs   ,  //LCD 行同步信号
    output             lcd_vs   ,  //LCD 场同步信号
    output             lcd_de   ,  //LCD 数据输入使能
    inout      [23:0]  lcd_rgb  ,  //LCD RGB565颜色数据
    output             lcd_bl   ,  //LCD 背光控制信号
    output             lcd_clk  ,  //LCD 采样时钟
    output             lcd_rst     //LCD 复位
);
    
//wire define    
wire  [15:0]  lcd_id    ;    //LCD屏ID
wire          lcd_pclk  ;    //LCD像素时钟
              
wire  [10:0]  pixel_xpos;    //当前像素点横坐标
wire  [10:0]  pixel_ypos;    //当前像素点纵坐标
wire  [10:0]  h_disp    ;    //LCD屏水平分辨率
wire  [10:0]  v_disp    ;    //LCD屏垂直分辨率
wire  [23:0]  pixel_data;    //像素数据
wire  [23:0]  lcd_rgb_o ;    //输出的像素数据
wire  [23:0]  lcd_rgb_i ;    //输入的像素数据

//*****************************************************
//**                    main code
//*****************************************************

//像素数据方向切换
assign lcd_rgb = lcd_de ?  lcd_rgb_o :  {24{1'bz}};
assign lcd_rgb_i = lcd_rgb;

//读LCD ID模块
rd_id u_rd_id(
    .clk          (sys_clk  ),
    .rst_n        (sys_rst_n),
    .lcd_rgb      (lcd_rgb_i),
    .lcd_id       (lcd_id   )
    );    

//时钟分频模块    
clk_div u_clk_div(
    .clk          (sys_clk  ),
    .rst_n        (sys_rst_n),
    .lcd_id       (lcd_id   ),
    .lcd_pclk     (lcd_pclk )
    );    

//LCD显示模块    
lcd_display u_lcd_display(
    .lcd_pclk    (lcd_pclk  ),    
    .rst_n       (sys_rst_n ),
     //时间和日期
    .sec         (sec       ),
    .min         (min       ),
    .hour        (hour      ),
    .day         (day       ),
    .mon         (mon       ),
    .year        (year      ),
    //像素点坐标
    .pixel_xpos  (pixel_xpos),
    .pixel_ypos  (pixel_ypos),
    .pixel_data  (pixel_data)
    );    

//LCD驱动模块
lcd_driver u_lcd_driver(
    .lcd_pclk      (lcd_pclk  ),
    .rst_n         (sys_rst_n ),
    
    .lcd_id        (lcd_id    ),
    .pixel_data    (pixel_data),
    .pixel_xpos    (pixel_xpos),
    .pixel_ypos    (pixel_ypos),
    .h_disp        (h_disp    ),
    .v_disp        (v_disp    ),
    .data_req      (),

    .lcd_de        (lcd_de    ),
    .lcd_hs        (lcd_hs    ),
    .lcd_vs        (lcd_vs    ),
    .lcd_bl        (lcd_bl    ),
    .lcd_clk       (lcd_clk   ),
    .lcd_rst       (lcd_rst   ),
    .lcd_rgb       (lcd_rgb_o )
    );

endmodule

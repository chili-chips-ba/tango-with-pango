//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           lcd_rgb_top
// Created by:          正点原子
// Created date:        2023年9月14日19:26:07
// Version:             V1.0
// Descriptions:        lcd_rgb_top
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module lcd_rgb_top(
    input           sys_clk      ,  //系统时钟
    input           sys_rst_n,      //复位信号  
    input           sys_init_done, 
    //lcd接口  
    output          lcd_clk,        //LCD驱动时钟    
    output          lcd_hs,         //LCD 行同步信号
    output          lcd_vs,         //LCD 场同步信号
    output          lcd_de,         //LCD 数据输入使能
    inout  [23:0]   lcd_rgb,        //LCD RGB颜色数据
    output          lcd_bl,         //LCD 背光控制信号
    output          lcd_rst,        //LCD 复位信号
    output          lcd_pclk,       //LCD 采样时钟
    output  [15:0]  lcd_id,         //LCD屏ID  
    output          out_vsync,      //lcd场信号 
    output  [10:0]  pixel_xpos,     //像素点横坐标
    output  [10:0]  pixel_ypos,     //像素点纵坐标        
    output  [10:0]  h_disp,         //LCD屏水平分辨率
    output  [10:0]  v_disp,         //LCD屏垂直分辨率         
    input   [15:0]  data_in,        //数据输入
    output          data_req        //请求数据输入
    );

//wire define
wire [15:0]  lcd_data_w  ;          //像素点数据
wire         data_req_w  ;          //请求像素点颜色数据输入 
wire         data_req_big;          //大于640x480分辨率lcd屏的请求信号
wire         data_req_small;        //小于640x480分辨率lcd屏的请求信号 
wire [15:0]  lcd_data;              //选择屏后的数据
wire  [15:0] lcd_rgb_565;           //输出的16位lcd数据
wire  [23:0] lcd_rgb_o ;            //LCD 输出颜色数据
wire  [23:0] lcd_rgb_i ;            //LCD 输入颜色数据

//*****************************************************
//**                    main code
//***************************************************** 

//区分大小屏的读请求 
assign data_req = (lcd_id == 16'h4342) ? data_req_small : data_req_big;   
 
//区分大小屏的数据 
assign lcd_data = (lcd_id == 16'h4342) ? data_in : lcd_data_w ;  

//将摄像头16bit数据转换为24bit的lcd数据
assign lcd_rgb_o = {lcd_rgb_565[15:11],3'b000,lcd_rgb_565[10:5],2'b00,
                    lcd_rgb_565[4:0],3'b000};          

//像素数据方向切换
assign lcd_rgb = lcd_de ?  lcd_rgb_o :  {24{1'bz}};
assign lcd_rgb_i = lcd_rgb;  

//时钟分频模块    
clk_div u_clk_div(
    .clk                    (sys_clk  ),
    .rst_n                  (sys_rst_n),
    .lcd_id                 (lcd_id   ),
    .lcd_pclk               (lcd_clk  )
    );  

//读LCD ID模块
rd_id u_rd_id(
    .clk                    (sys_clk  ),
    .rst_n                  (sys_rst_n),
    .lcd_rgb                (lcd_rgb_i),
    .lcd_id                 (lcd_id   )
    );  

//lcd驱动模块
lcd_driver u_lcd_driver(           
    .lcd_pclk       (lcd_clk),    
    .rst_n          (sys_rst_n & sys_init_done), 
    .lcd_id         (lcd_id),   

    .lcd_hs         (lcd_hs),       
    .lcd_vs         (lcd_vs),       
    .lcd_de         (lcd_de),       
    .lcd_rgb        (lcd_rgb_565),
    .lcd_bl         (lcd_bl),
    .lcd_rst        (lcd_rst),
    .lcd_clk        (lcd_pclk),
    
    .pixel_data     (lcd_data), 
    .data_req       (data_req_small),
    .out_vsync      (out_vsync),
    .h_disp         (h_disp),
    .v_disp         (v_disp), 
    .pixel_xpos     (pixel_xpos), 
    .pixel_ypos     (pixel_ypos)
    ); 
 
//lcd显示模块 
lcd_display u_lcd_display(          
    .lcd_clk        (lcd_clk),    
    .sys_rst_n      (sys_rst_n & sys_init_done),
    .lcd_id         (lcd_id),  
    
    .pixel_xpos     (pixel_xpos),
    .pixel_ypos     (pixel_ypos),
    .h_disp         (h_disp),
    .v_disp         (v_disp), 	
    .cmos_data      (data_in),
    .lcd_data       (lcd_data_w),    
    .data_req       (data_req_big)
    );   
               
endmodule 
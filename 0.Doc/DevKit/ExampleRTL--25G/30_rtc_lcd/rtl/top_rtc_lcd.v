//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           top_rtc_lcd
// Created by:          正点原子
// Created date:        2023年5月18日14:17:02
// Version:             V1.0
// Descriptions:        RTC的时间在RGB LCD液晶屏上显示
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module top_rtc_lcd(
    input                sys_clk,     //系统时钟
    input                sys_rst_n,   //系统复位

    //RGB LCD接口
    output               lcd_de,      //LCD 数据使能信号
    output               lcd_hs,      //LCD 行同步信号
    output               lcd_vs,      //LCD 场同步信号
    output               lcd_bl,      //LCD 背光控制信号
    output               lcd_clk,     //LCD 像素时钟
    output               lcd_rst,     //LCD 复位
    inout        [23:0]  lcd_rgb,     //LCD RGB888颜色数据
    
    //RTC实时时钟
    output               iic_scl,     //RTC的时钟线scl
    inout                iic_sda      //RTC的数据线sda    
    );                                                      

//parameter define
parameter    SLAVE_ADDR = 7'b101_0001          ; //器件地址(SLAVE_ADDR)
parameter    BIT_CTRL   = 1'b0                 ; //字地址位控制参数(16b/8b)
parameter    CLK_FREQ   = 26'd50_000_000       ; //i2c_dri模块的驱动时钟频率
parameter    I2C_FREQ   = 18'd250_000          ; //I2C的SCL时钟频率
parameter    TIME_INIT  = 48'h19_01_01_09_30_00; //初始时间

//wire define
wire          dri_clk   ;   //I2C操作时钟
wire          i2c_exec  ;   //I2C触发控制
wire  [15:0]  i2c_addr  ;   //I2C操作地址
wire  [ 7:0]  i2c_data_w;   //I2C写入的数据
wire          i2c_done  ;   //I2C操作结束标志
wire          i2c_ack   ;   //I2C应答标志 0:应答 1:未应答
wire          i2c_rh_wl ;   //I2C读写控制
wire  [ 7:0]  i2c_data_r;   //I2C读出的数据

wire    [7:0]  sec      ;   //秒
wire    [7:0]  min      ;   //分
wire    [7:0]  hour     ;   //时
wire    [7:0]  day      ;   //日
wire    [7:0]  mon      ;   //月
wire    [7:0]  year     ;   //年

//*****************************************************
//**                    main code
//*****************************************************

//i2c驱动模块
i2c_dri #(
    .SLAVE_ADDR  (SLAVE_ADDR),  //PCF8563从机地址
    .CLK_FREQ    (CLK_FREQ  ),  //模块输入的时钟频率
    .I2C_FREQ    (I2C_FREQ  )   //IIC_SCL的时钟频率
) u_i2c_dri(
    .clk         (sys_clk   ),  
    .rst_n       (sys_rst_n ),  
    //i2c interface
    .i2c_exec    (i2c_exec  ), 
    .bit_ctrl    (BIT_CTRL  ), 
    .i2c_rh_wl   (i2c_rh_wl ), 
    .i2c_addr    (i2c_addr  ), 
    .i2c_data_w  (i2c_data_w), 
    .i2c_data_r  (i2c_data_r), 
    .i2c_done    (i2c_done  ), 
    .i2c_ack     (i2c_ack   ), 
    .scl         (iic_scl   ), 
    .sda         (iic_sda   ), 
    //user interface
    .dri_clk     (dri_clk   )  
);

//PCF8563控制模块
pcf8563_ctrl #(
    .TIME_INIT (TIME_INIT)
   )u_pcf8563_ctrl(
    .clk         (dri_clk   ),
    .rst_n       (sys_rst_n ),
    //IIC
    .i2c_rh_wl   (i2c_rh_wl ),
    .i2c_exec    (i2c_exec  ),
    .i2c_addr    (i2c_addr  ),
    .i2c_data_w  (i2c_data_w),
    .i2c_data_r  (i2c_data_r),
    .i2c_done    (i2c_done  ),
    //时间和日期
    .sec         (sec       ),
    .min         (min       ),
    .hour        (hour      ),
    .day         (day       ),
    .mon         (mon       ),
    .year        (year      )
    );

//LCD字符显示模块
lcd_rgb_char u_lcd_rgb_char(
    .sys_clk     (sys_clk   ),
    .sys_rst_n   (sys_rst_n ),
    //时间和日期
    .sec         (sec       ),
    .min         (min       ),
    .hour        (hour      ),
    .day         (day       ),
    .mon         (mon       ),
    .year        (year      ),
    //RGB LCD接口
    .lcd_de      (lcd_de    ),
    .lcd_hs      (lcd_hs    ),
    .lcd_vs      (lcd_vs    ),
    .lcd_bl      (lcd_bl    ),
    .lcd_clk     (lcd_clk   ),
    .lcd_rst     (lcd_rst   ),
    .lcd_rgb     (lcd_rgb   )
    );

endmodule

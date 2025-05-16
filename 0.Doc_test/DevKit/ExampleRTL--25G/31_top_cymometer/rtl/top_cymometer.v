//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           top_cymometer
// Created by:          正点原子
// Created date:        2023年2月3日14:17:02
// Version:             V1.0
// Descriptions:        top_cymometer
//
//----------------------------------------------------------------------------------------
//****************************************************************************************///

module top_cymometer#(
    //parameter define
    parameter       DIV_N        = 26'd10_000_000   ,   // 分频系数
    parameter       CHAR_POS_X   = 11'd1            ,   // 字符区域起始点横坐标
    parameter       CHAR_POS_Y   = 11'd1            ,   // 字符区域起始点纵坐标
    parameter       CHAR_WIDTH   = 11'd88           ,   // 字符区域宽度
    parameter       CHAR_HEIGHT  = 11'd16           ,   // 字符区域高度
    parameter       WHITE        = 24'hFFFFFF       ,   // 背景色，白色
    parameter       BLACK        = 24'h0            ,   // 字符颜色，黑色
    parameter       CNT_GATE_MAX = 28'd75_000_000   ,   // 测频周期时间为1.5s  
    parameter       CNT_GATE_LOW = 28'd12_500_000   ,   // 闸门为低的时间0.25s
    parameter       CNT_TIME_MAX = 28'd80_000_000   ,   // 测频周期时间为1.6s
    parameter       CLK_FS_FREQ  = 28'd100_000_000  ,
    parameter       DATAWIDTH    = 8'd57
)(
    input              sys_clk    ,             // 时钟信号
    input              sys_rst_n  ,             // 复位信号
    input              clk_fx     ,             // 被测时钟

    output             clk_out1   ,             // 输出时钟5hz
    output             clk_out2   ,             // 输出时钟133.3333Mhz
	output             lcd_hs     ,             // LCD 行同步信号
	output             lcd_vs     ,             // LCD 场同步信号
	output             lcd_de     ,             // LCD 数据输入使能
	inout      [23:0]  lcd_rgb    ,             // LCD RGB颜色数据
	output             lcd_bl     ,             // LCD 背光控制信号
	output             lcd_clk    ,             // LCD 采样时钟
    output             lcd_rst
);
//wire define
wire    [29:0]       data_fx;        // 被测信号测量值       
wire                 clk_fs;

wire        en;             

wire [56:0] dividend;       
wire [56:0] divisor;        

wire        ready;          
wire [56:0] quotient;       
wire [56:0] remainder;     
wire        vld_out;        

//*****************************************************
//**                    main code
//*****************************************************

// 产生基准时钟100M
pll_100m u_pll_100m (
  .pll_rst(~sys_rst_n),      // input
  .clkin1(sys_clk),        // input
  .pll_lock(pll_lock),    // output
  .clkout0(clk_fs),      // output
  .clkout1(clk_out2)       // output
);

//例化等精度频率计模块 
cymometer#(
    .CNT_GATE_MAX   (CNT_GATE_MAX),      // 测频周期时间为1.5s  
    .CNT_GATE_LOW   (CNT_GATE_LOW),      // 闸门为低的时间0.25s
    .CNT_TIME_MAX   (CNT_TIME_MAX),
    .CLK_FS_FREQ    (CLK_FS_FREQ )
)
u_cymometer(
    .sys_clk        (sys_clk    ),       // 系统时钟，50M
    .clk_fs         (clk_fs     ),       // 基准时钟，100M
    .sys_rst_n      (sys_rst_n  ),       // 系统复位，低电平有效
    .clk_fx         (clk_fx     ),       // 被测时钟信号
    .data_fx        (data_fx    ),       // 被测时钟频率值
    .dividend       (dividend   ),       
    .divisor        (divisor    ),       
    .en             (en         ),    
    .ready          (ready      ),       
    .quotient       (quotient   ),       
    .remainder      (remainder  ),       
    .vld_out        (vld_out    )        
    
);

//除法器模块
div_fsm
#(
    .DATAWIDTH      (DATAWIDTH  )
)
u_div_fsm(
    .clk            (sys_clk    ),      
    .rst_n          (sys_rst_n  ),      
    .en             (en         ),      

    .dividend       (dividend   ),      
    .divisor        (divisor    ),      

    .ready          (ready      ),      
    .quotient       (quotient   ),      
    .remainder      (remainder  ),      
    .vld_out        (vld_out    )       
);

//例化测试时钟模块，产生测试时钟
clk_test 
#(
    .DIV_N          (DIV_N      )
)
u_clk_test(
    .clk_in         (sys_clk    ),
    .rst_n          (sys_rst_n  ),
    .clk_out        (clk_out1    )
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
    .data           (data_fx    ),     
    .lcd_hs         (lcd_hs     ),          // LCD 行同步信号
    .lcd_vs         (lcd_vs     ),          // LCD 场同步信号
    .lcd_de         (lcd_de     ),          // LCD 数据输入使能
    .lcd_rgb        (lcd_rgb    ),          // LCD RGB888颜色数据
    .lcd_bl         (lcd_bl     ),          // LCD 背光控制信号
    .lcd_clk        (lcd_clk    ),          // LCD 采样时钟
    .lcd_rst        (lcd_rst    )
);

endmodule
//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                                
//----------------------------------------------------------------------------------------
// File name:           tb_top_traffic
// Last modified Date:  2018/6/8 9:26:44
// Last Version:        V1.0
// Descriptions:        信号灯控制模块
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/6/8 9:26:47
// Version:             V1.0
// Descriptions:        The original version
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2023/5/17 20:30:47
// Version:             V1.0
// Descriptions:        优化代码，增加注释。
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
// Modified by:       正点原子
// Modified date:     
// Version:         
// Descriptions:      
//----------------------------------------------------------------------------------------
//****************************************************************************************//

`timescale 1ns/1ns
module tb_top_traffic     ();    //top_traffic
reg            sys_clk    ;      //系统时钟
reg            sys_rst_n  ;      //系统复位                          
wire  [3:0]    sel        ;      //数码管位选信号
wire  [7:0]    seg_led    ;      //数码管段选信号
wire  [5:0]    led        ;      //led灯控制信号

//paramater difine
parameter  TWINKLE_CNT   = 2;             //黄灯闪烁的时间计数
parameter  TIME_LED_Y    = 3;             //黄灯发光的时间
parameter  TIME_LED_R    = 10;            //红灯发光的时间
parameter  TIME_LED_G    = 7;             //绿灯发光的时间
parameter  WIDTH_CNT     = 8;             //产生频率为1hz的时钟
parameter  WIDTH         = 2;             //计数1ms的计数深度

initial begin
        sys_clk        <= 1'b0;
        sys_rst_n      <= 1'b0;
        # 20 sys_rst_n <= 1'b1;
end

always # 10 sys_clk = ~sys_clk;  //产生频率为50Mhz的时钟

//例化交通灯顶层模块
top_traffic 
#(
    .TWINKLE_CNT (TWINKLE_CNT ),
    .TIME_LED_Y  (TIME_LED_Y  ),
    .TIME_LED_R  (TIME_LED_R  ),
    .TIME_LED_G  (TIME_LED_G  ),
    .WIDTH_CNT   (WIDTH_CNT   ),
    .WIDTH       (WIDTH       )
)
u_top_traffic(
    .sys_clk   (sys_clk   ),
    .sys_rst_n (sys_rst_n ),
    .sel       (sel       ),
    .seg_led   (seg_led   ),
    .led       (led       )
);

endmodule
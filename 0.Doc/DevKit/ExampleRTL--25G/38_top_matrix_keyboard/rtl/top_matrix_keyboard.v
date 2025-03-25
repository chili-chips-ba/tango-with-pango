//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           top_matrix_keyboard
// Created by:          正点原子
// Created date:        2023年2月3日14:17:02
// Version:             V1.0
// Descriptions:        top_matrix_keyboard
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module top_matrix_keyboard(
    input         sys_clk    ,
    input         sys_rst_n  ,
    input   [3:0] key_row    ,
    input   [7:0] swi        ,
    output  [3:0] key_col    ,
    output  [3:0] sel_t      ,
    output  [7:0] seg_led_t  ,
    output  [7:0] led

    );

//wire define
wire [4:0]    key_value    ;
wire          key_flag     ;

//*****************************************************
//**                    main code                      
//*****************************************************

//矩阵键盘扫描模块
key_4x4    u_key_4x4(
    .sys_clk    (sys_clk  ),
    .sys_rst_n  (sys_rst_n),
    .key_row    (key_row  ),
    .key_col    (key_col  ),
    .key_value  (key_value),
    .key_flag   (key_flag )
    );

//数码管显示模块
seg_led    u_seg_led(
    .clk       (sys_clk  ),
    .rst_n     (sys_rst_n),
    .key_value (key_value),
    .key_flag  (key_flag ),
    .sel_t     (sel_t    ),
    .seg_led_t (seg_led_t)
    );

//拨码开关模块
swi_led     u_swi_led(
    .clk     (sys_clk  ),
    .rst_n   (sys_rst_n),
    .swi     (swi      ),
    .led     (led      )
);
endmodule
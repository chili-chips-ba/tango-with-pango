//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           vip
// Last modified Date:  2020/05/04 9:19:08
// Last Version:        V1.0
// Descriptions:        数字图像处理模块封装层
//                      
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/05/04 9:19:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module vip(
    //module clock
    input           clk            ,   // 时钟信号
    input           rst_n          ,   // 复位信号（低有效）

    //图像处理前的数据接口
    input           pre_frame_vsync,
    input           pre_frame_href ,
    input           pre_frame_de   ,
    input    [15:0] pre_rgb        ,

    //图像处理后的数据接口
    output          post_frame_vsync,  // 场同步信号
    output          post_frame_href ,  // 行同步信号
    output          post_frame_de   ,  // 数据输入使能
    output   [15:0] post_rgb           // RGB565颜色数据
);

//wire define
wire   [ 7:0]         img_y;

//*****************************************************
//**                    main code
//*****************************************************

assign  post_rgb = {img_y[7:3],img_y[7:2],img_y[7:3]};

//RGB转YCbCr模块
rgb2ycbcr u_rgb2ycbcr(
    //module clock
    .clk             (clk    ),            // 时钟信号
    .rst_n           (rst_n  ),            // 复位信号（低有效）
    //图像处理前的数据接口
    .pre_frame_vsync (pre_frame_vsync),    // vsync信号
    .pre_frame_href  (pre_frame_href ),    // href信号
    .pre_frame_de    (pre_frame_de   ),    // data enable信号
    .img_red         (pre_rgb[15:11] ),
    .img_green       (pre_rgb[10:5 ] ),
    .img_blue        (pre_rgb[ 4:0 ] ),
    //图像处理后的数据接口
    .post_frame_vsync(post_frame_vsync),   // vsync信号
    .post_frame_href (post_frame_href ),   // href信号
    .post_frame_de   (post_frame_de),      // data enable信号
    .img_y           (img_y),
    .img_cb          (),
    .img_cr          ()
);

endmodule

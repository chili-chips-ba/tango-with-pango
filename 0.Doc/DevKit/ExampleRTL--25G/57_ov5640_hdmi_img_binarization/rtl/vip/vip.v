//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           vip
// Created by:          正点原子
// Created date:        2023年9月12日17:52:55
// Version:             V1.0
// Descriptions:        图像处理
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module vip(
    //module clock
    input           clk               ,  // 时钟信号
    input           rst_n             ,  // 复位信号（低有效）

    //图像处理前的数据接口
    input           pre_frame_vsync   ,
    input           pre_frame_href    ,
    input           pre_frame_de      ,
    input    [15:0] pre_rgb           ,

    //图像处理后的数据接口
    output          post_frame_vsync  ,   // 场同步信号
    output          post_frame_href  ,   // 行同步信号
    output          post_frame_de     ,   // 数据输入使能
    output   [15:0] post_rgb              // RGB565颜色数据

);

//wire define
wire   [ 7:0]         img_y;
wire   [ 7:0]         post_img_y;
wire                  pe_frame_vsync;
wire                  pe_frame_href;
wire                  pe_frame_clken;
wire                  ycbcr_vsync;
wire                  ycbcr_href;
wire                  ycbcr_de;
wire                  monoc;

//*****************************************************
//**                    main code
//*****************************************************

assign  post_rgb = {16{monoc}};

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
    .post_frame_vsync(pe_frame_vsync),     // vsync信号
    .post_frame_href (pe_frame_href),      // href信号
    .post_frame_de   (pe_frame_clken),     // data enable信号
    .img_y           (img_y),              //灰度数据
    .img_cb          (),
    .img_cr          ()
);

//灰度图中值滤波
vip_gray_median_filter u_vip_gray_median_filter(
    .clk             (clk),   
    .rst_n           (rst_n), 
    
    //预处理图像数据
    .pre_frame_vsync (pe_frame_vsync),     // vsync信号
    .pre_frame_href  (pe_frame_href),      // href信号
    .pre_frame_clken (pe_frame_clken),     // data enable信号
    .pre_img_y       (img_y),               
                                           
    //处理后的图像数据                     
    .pos_frame_vsync (ycbcr_vsync),        // vsync信号
    .pos_frame_href  (ycbcr_href ),        // href信号
    .pos_frame_clken (ycbcr_de),           // data enable信号
    .pos_img_y       (post_img_y)          //中值滤波后的灰度数据
);

//二值化模块
binarization  u_binarization(
    .clk             (clk),
    .rst_n           (rst_n),
    //图像处理前的数据接口     
    .ycbcr_vsync     (ycbcr_vsync),
    .ycbcr_href      (ycbcr_href),
    .ycbcr_de        (ycbcr_de),
    .luminance       (post_img_y),
    //图像处理后的数据接口     
    .post_vsync      (post_frame_vsync),
    .post_href       (post_frame_href),
    .post_de         (post_frame_de),
    .monoc           (monoc)              //二值化后的数据
);
endmodule

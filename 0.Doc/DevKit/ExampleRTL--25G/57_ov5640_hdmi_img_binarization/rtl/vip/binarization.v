//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           binarization
// Created by:          正点原子
// Created date:        2023年9月12日17:52:55
// Version:             V1.0
// Descriptions:        二值化
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module binarization(
    //module clock
    input               clk             ,   // 时钟信号
    input               rst_n           ,   // 复位信号（低有效）

    //图像处理前的数据接口
    input               ycbcr_vsync     ,   // vsync信号
    input               ycbcr_href      ,   // href信号
    input               ycbcr_de        ,   // data enable信号
    input   [7:0]       luminance       ,

    //图像处理后的数据接口
    output              post_vsync      ,   // vsync信号
    output              post_href       ,   // href信号
    output              post_de         ,   // data enable信号
    output   reg        monoc               // monochrome（1=白，0=黑）
);

//reg define
reg    ycbcr_vsync_d;
reg    ycbcr_href_d ;
reg    ycbcr_de_d   ;

//*****************************************************
//**                    main code
//*****************************************************

assign  post_vsync = ycbcr_vsync_d;
assign  post_href  = ycbcr_href_d ;
assign  post_de    = ycbcr_de_d   ;

//二值化
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        monoc <= 1'b0;
    else if(luminance > 8'd64)  //阈值
        monoc <= 1'b1;
    else
        monoc <= 1'b0;
end

//延时1拍以同步时钟信号
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        ycbcr_vsync_d <= 1'd0;
        ycbcr_href_d <= 1'd0;
        ycbcr_de_d    <= 1'd0;
    end
    else begin
        ycbcr_vsync_d <= ycbcr_vsync;
        ycbcr_href_d  <= ycbcr_href ;
        ycbcr_de_d    <= ycbcr_de   ;
    end
end

endmodule 
//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           picture_tailor
// Last modified Date:  2020/05/04 9:19:08
// Last Version:        V1.0
// Descriptions:        图片裁剪模块
//                      
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/05/04 9:19:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module picture_tailor(
    input                 gmii_rx_clk          ,  //cmos 数据像素时钟
    input                 sys_rst_n            ,  //复位信号                    
    input                 picture_data_vld0    ,    
    //用户接口  
    output                picture_data_vld1    ,                           
    output   reg [10:0]  picture_data_cntx     ,
    output   reg [10:0]  picture_data_cnty         //数据有效使能信号         
    );
    
//*****************************************************
//**                    main code
//*****************************************************

assign picture_data_vld1 = ((160 <= picture_data_cntx) && 
    (picture_data_cntx< 640) && (104 <= picture_data_cnty) 
    && (picture_data_cnty < 376) && picture_data_vld0)?1'b1:1'b0;
    
//对整个图片像素点横坐标进行计数
always@ (posedge gmii_rx_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) 
        picture_data_cntx <= 11'd0;
    else if(picture_data_vld0)begin
        if(picture_data_cntx == 800 - 1'b1)
            picture_data_cntx <= 11'd0;
        else
            picture_data_cntx <= picture_data_cntx + 1'b1;           
    end
end

//对整个图片像素点纵坐标进行计数
always@ (posedge gmii_rx_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) 
        picture_data_cnty <= 11'd0;
    else begin
        if(picture_data_cntx == 800 - 1'b1) begin
            if(picture_data_cnty ==480 - 1'b1)
                picture_data_cnty <= 11'd0;
            else
                picture_data_cnty <= picture_data_cnty + 1'b1;    
        end
    end    
end
 
endmodule
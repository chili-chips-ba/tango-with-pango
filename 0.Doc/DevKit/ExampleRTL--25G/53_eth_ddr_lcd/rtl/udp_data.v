//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           udp_data
// Last modified Date:  2020/05/04 9:19:08
// Last Version:        V1.0
// Descriptions:        udp数据处理模块
//                      
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/05/04 9:19:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module udp_data(
    input               clk,                    //时钟信号
    input               rst_n,                  //复位信号，低电平有效
    
    input               rec_en,                 //UDP接收的数据使能信号
    input       [7:0]   rec_data,               //以太网图片像素16数据
    input               picture_data_vld1,      //以太网800x460裁剪后像素数据有效信号
    input       [15:0]  lcd_id,                 //LCD ID
    output              picture_data_vld,       //以太网图片像素数据有效信号
    output              picture_data_vld0,      //以太网800x460完整图片像素数据有效信号
    output reg  [15:0]  picture_data            //以太网图片像素16数据
    );
  
//reg define
reg rec_en_cnt  ;  

//wire define
wire rec_en_t   ;
//*****************************************************
//**                    main code
//*****************************************************
//判断屏幕如果是480x272则将裁剪的像素数据有效赋值给像素数据有效信号，否则不裁剪
assign picture_data_vld = (lcd_id==16'h4342)? picture_data_vld1:picture_data_vld0;
//产生以太网16位图片像素数据有效信号
assign rec_en_t = (rec_en & rec_en_cnt)? 1'b1:1'b0;
assign picture_data_vld0 = rec_en_t? 1'b1:1'b0;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin  
        rec_en_cnt <= 0;
    end
    else if(rec_en)
        rec_en_cnt <= rec_en_cnt + 1 ; 
    else 
        rec_en_cnt <= rec_en_cnt ;  
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin  
        picture_data <= 0;
    end
    else if(rec_en & rec_en_cnt)
        picture_data[7:0] <= rec_data ;
    else if(rec_en) 
        picture_data[15:8] <= rec_data ;
    else
        picture_data <= picture_data ;
end
    
endmodule

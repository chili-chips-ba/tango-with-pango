//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ram_rw
// Created by:          正点原子
// Created date:        2023年9月8日14:17:02
// Version:             V1.0
// Descriptions:        RAM读写模块
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ram_rw(
    input               clk         ,  //时钟信号
    input               rst_n       ,  //复位信号，低电平有效

    output              ram_rw_en   ,  //ram读写使能，0：读数据  1：写数据
    output  reg  [4:0]  ram_addr    ,  //ram读写地址
    output  reg  [7:0]  ram_wr_data    //ram写数据  
    );

//reg define
reg  [5:0]  rw_cnt;   //读写控制计数器
reg         ram_en;   //自定义一个ram使能信号，为高时方可进行读写操作

//*****************************************************
//**                    main code
//*****************************************************

//rw_cnt计数范围在0~31,写入数据;32~63时,读出数据
assign ram_rw_en = ((rw_cnt <= 6'd31) && ram_en) ? 1'b1 : 1'b0;

//控制RAM使能信号，防止复位结束后的第一次写操作无效
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ram_en <= 1'b0;    
    else
        ram_en <= 1'b1;    
end 

//读写控制计数器,计数器范围0~63
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rw_cnt <= 6'b0;    
    else if((rw_cnt < 6'd63) && ram_en)
        rw_cnt <= rw_cnt + 6'b1;  
    else
        rw_cnt <= 6'b0;    
end  

//读写地址信号 范围：0~31
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ram_addr <= 5'b0;
    else if((ram_addr < 5'd31) && ram_en)
        ram_addr <= ram_addr + 5'b1;
    else    
        ram_addr <= 5'b0;
end

//产生RAM写数据
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ram_wr_data <= 1'b0;  
    else if((rw_cnt < 6'd31) && ram_rw_en)  //在计数器的0-31范围内，RAM写地址累加
        ram_wr_data <= ram_wr_data + 1'b1;
    else
        ram_wr_data <= 1'b0 ;   
end  

endmodule

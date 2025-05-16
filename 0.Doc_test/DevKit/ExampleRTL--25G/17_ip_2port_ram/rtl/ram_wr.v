//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ram_wr
// Created by:          正点原子
// Created date:        2023年9月9日14:17:02
// Version:             V1.0
// Descriptions:        RAM写模块
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ram_wr(
    input            clk         , //时钟信号
    input            rst_n       , //复位信号，低电平有效
                                    
    //RAM写端口操作 
    output reg       ram_wr_en   , //ram写使能
    output reg       rd_flag     , //读启动信号
    output reg [4:0] ram_wr_addr , //ram写地址        
    output reg [7:0] ram_wr_data   //ram写数据
);

//*****************************************************
//**                    main code
//*****************************************************

//控制RAM使能信号
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ram_wr_en <= 1'b0;
    else 
        ram_wr_en <= 1'b1;
end

//写地址信号 范围:0~31        
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)        
        ram_wr_addr <= 5'd0;
    else if((ram_wr_addr < 5'd31) && ram_wr_en)
        ram_wr_addr <= ram_wr_addr + 5'b1;
    else
        ram_wr_addr <= 5'd0;
end  

//写数据与写地址相同
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)        
        ram_wr_data <= 8'd0;
    else if((ram_wr_addr < 8'd31) && ram_wr_en)
        ram_wr_data <= ram_wr_data + 8'b1;
    else
        ram_wr_data <= 8'd0;
end  

//当写入16个数据（0~15）后，拉高读启动信号
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rd_flag <= 1'b0;
    else if(ram_wr_addr == 5'd15)  
        rd_flag <= 1'b1;
    else
        rd_flag <= rd_flag;
end             

endmodule
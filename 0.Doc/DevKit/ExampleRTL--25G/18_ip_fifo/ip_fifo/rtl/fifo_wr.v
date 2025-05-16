//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           fifo_wr
// Created by:          正点原子
// Created date:        2023年10月10日14:17:02
// Version:             V1.0
// Descriptions:        FIFO写模块
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module fifo_wr(
    input                  wr_clk             ,  // 时钟信号
    input                  rst_n              ,  // 复位信号
    
    input          [8:0]   fifo_wr_data_count ,  //FIFO写时钟域的数据计数
    input                  fifo_empty         ,  // FIFO空信号
    output    reg          fifo_wr_en         ,  // FIFO写使能
    output    reg  [7:0]   fifo_wr_data          // 写入FIFO的数据
);

//reg define
reg        empty_d0;
reg        empty_d1;

//*****************************************************
//**                    main code
//*****************************************************

//因为fifo_empty信号是属于FIFO读时钟域的
//所以对fifo_empty打两拍同步到写时钟域下
always @(posedge wr_clk or negedge rst_n) begin
    if(!rst_n) begin
        empty_d0 <= 1'b0;
        empty_d1 <= 1'b0;
    end
    else begin
        empty_d0 <= fifo_empty;
        empty_d1 <= empty_d0;
    end
end

//对fifo_wr_en赋值，当FIFO为空时开始写入，写满后停止写
always @(posedge wr_clk or negedge rst_n) begin
    if(!rst_n) 
        fifo_wr_en <= 1'b0;
    else if(empty_d1)
        fifo_wr_en <= 1'b1;
    else if(fifo_wr_data_count == 9'd255)
        fifo_wr_en <= 1'b0;  
    else
        fifo_wr_en <= fifo_wr_en;
end  

//对fifo_wr_data赋值,0~255
always @(posedge wr_clk or negedge rst_n) begin
    if(!rst_n) 
        fifo_wr_data <= 8'b0;
    else if(fifo_wr_en && fifo_wr_data < 8'd255)
        fifo_wr_data <= fifo_wr_data + 8'b1;
    else
        fifo_wr_data <= 8'b0;
end

endmodule
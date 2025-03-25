//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           fifo_rd
// Created by:          正点原子
// Created date:        2023年10月10日14:17:02
// Version:             V1.0
// Descriptions:        FIFO读模块
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module fifo_rd(
    input               rd_clk             ,  //时钟信号
    input               rst_n              ,  //复位信号

    input        [8:0]  fifo_rd_data_count ,  //FIFO读时钟域的数据计数
    input        [7:0]  fifo_rd_data       ,  //从FIFO读出的数据
    input               fifo_full          ,  //FIFO满信号
    output  reg         fifo_rd_en            //FIFO读使能
);

//reg define
reg       full_d0;
reg       full_d1;

//*****************************************************
//**                    main code
//*****************************************************

//因为fifo_full信号是属于FIFO写时钟域的
//所以对fifo_full打两拍同步到读时钟域下
always @(posedge rd_clk or negedge rst_n) begin
    if(!rst_n) begin
        full_d0 <= 1'b0;
        full_d1 <= 1'b0;
    end
    else begin
        full_d0 <= fifo_full;
        full_d1 <= full_d0;
    end
end    
    
//对fifo_rd_en进行赋值,FIFO写满之后开始读，读空之后停止读
always @(posedge rd_clk or negedge rst_n) begin
    if(!rst_n) 
        fifo_rd_en <= 1'b0;
    else if(full_d1)
        fifo_rd_en <= 1'b1;
    else if(fifo_rd_data_count == 9'd1)
        fifo_rd_en <= 1'b0; 
    else
        fifo_rd_en <= fifo_rd_en;
end

endmodule
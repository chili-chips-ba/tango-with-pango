//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ram_rd
// Created by:          正点原子
// Created date:        2023年9月9日14:17:02
// Version:             V1.0
// Descriptions:        RAM读模块
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ram_rd(
    input            clk        ,   //时钟信号
    input            rst_n      ,   //复位信号，低电平有效
                                    
    //RAM读端口操作                 
    input            rd_flag    ,   //读启动标志
    input      [7:0] ram_rd_data,   //ram读数据
    output           rd_rst     ,   //ram读端口复位（使能）信号
    output reg [4:0] ram_rd_addr    //ram读地址       
);


//*****************************************************
//**                    main code
//*****************************************************

//控制RAM使能信号
assign rd_rst = ~rd_flag;      

//读地址信号 范围:0~31        
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)        
        ram_rd_addr <= 5'd0;
    else if((ram_rd_addr < 5'd31) && (!rd_rst))
        ram_rd_addr <= ram_rd_addr + 5'b1;
    else
        ram_rd_addr <= 5'd0;
end

endmodule
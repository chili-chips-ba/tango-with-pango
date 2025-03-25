//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                               
//----------------------------------------------------------------------------------------
// File name:           rd_id
// Last modified Date:  2019/8/07 10:41:06
// Last Version:        V1.0
// Descriptions:        测试数据产生模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/8/07 10:41:06
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module test_voltage(
    input                 clk    ,  //时钟
    input                 rst_n  ,  //复位信号，低电平有效
    //DA芯片接口
    output                da_clk ,  //DA芯片驱动时钟,最大支持125Mhz时钟
    output  reg  [7:0]    da_data   //输出给DA的数据  
    );

//parameter define 
parameter TIME_200MS = 25'd10_000_000;//0.2秒计数器

//reg define
reg [24:0]cnt_time;//时间计数器

//*****************************************************
//**                    main code
//*****************************************************
assign  da_clk = ~clk;    

//0.2秒计数
always @(posedge clk or negedge rst_n )begin
    if(!rst_n) 
        cnt_time <= 25'd0;
    else if(cnt_time == TIME_200MS - 1'b1)  
        cnt_time <= 25'd0;
    else
        cnt_time <= cnt_time + 1'd1;
end

//每隔0.2秒更新一次测试数据
always@(posedge clk or negedge rst_n )begin
    if(!rst_n)
        da_data <= 8'd0;
    else if(cnt_time == TIME_200MS - 1'b1)begin
        if(da_data == 8'd255)
            da_data <= 8'd0;
        else
            da_data <= da_data + 1'b1;
    end
    else;
end

endmodule
//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                               
//----------------------------------------------------------------------------------------
// File name:           voltage_data
// Last modified Date:  2019/8/07 10:41:06
// Last Version:        V1.0
// Descriptions:        0V电压校准模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/8/07 10:41:06
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module voltage_calibrator #(parameter WIDTH = 8)(
	input                  clk,
	input                  rst_n,					 
	input      [WIDTH-1:0] ad_data, 
	output reg             voc_finish, //0v校准完成标志
	output reg [WIDTH-1:0] voc_data    //校准后0v对应的ad数值
    );
	
//reg define
reg [WIDTH+9:0] ad_data_sum;//取1024个ad_data求和，最大位宽:[WIDTH+10-1:0]
reg [11:0]      ad_data_cnt;//对ad_data数据计数

//*****************************************************
//**                    main code
//*****************************************************

//当voc_finish为低时对ad_data数据计数
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		ad_data_cnt <= 10'd0;
	else if(!voc_finish)
		ad_data_cnt <= ad_data_cnt + 10'd1;
	else
		ad_data_cnt <= 10'd0;
end

//ad_data_cnt数到2047时，拉高voc_finish信号。	
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		voc_finish <= 1'b0;
	else if(ad_data_cnt == 2047)
		voc_finish <= 1'b1;
	else;
end	

//取1024个ad_data数据进行求和。
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	
		ad_data_sum <= 'd0;
	else if(ad_data_cnt >= 1023&&ad_data_cnt < 2047)
		ad_data_sum <= ad_data_sum + ad_data;
	else;
end

//1024个ad_data数据取平均值。	
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	
		voc_data <= 'd0;
	else if(ad_data_cnt == 2047)begin
		if(ad_data_sum[9:0] >= 10'd512)//四舍五入
			voc_data <= ad_data_sum[WIDTH+9:10] + 1'b1;
		else
			voc_data <= ad_data_sum[WIDTH+9:10];
	end
	else;
end
	
endmodule

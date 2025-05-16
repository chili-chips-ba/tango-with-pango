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
// Descriptions:        电压数据处理模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/8/07 10:41:06
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//
module voltage_data #(parameter WIDTH = 8)(
	input             clk              ,
	input             rst_n            ,							      
	input [WIDTH-1:0] ad_data          ,
	input             ad_otr           ,//0:在量程范围 1:超出量程							      
	input             voc_finish       ,//电平校准完成标志
	input [WIDTH-1:0] voc_data         ,//电平校准完成标志
	output reg        data_symbol      ,//电压值符号位，负电压最高位显示负号,正电压显示空格
	output reg [7:0]  data_percentiles ,//电压值小数点后第二位      
	output reg [7:0]  data_decile      ,//电压值小数点后第一位     
	output reg [7:0]  data_units       ,//电压值的个位数        
	output reg [7:0]  data_tens         //电压值的十位数       
	);

//parameter 	
parameter SIZE = 25'd1024; //取平均值的尺寸 
parameter TIME_200MS = 25'd5_000_000;//计数0.2秒
//parameter TIME_200MS=25'd5000;//0.2毫秒计数器,仅仿真使用

//reg define
reg [24:0]        cnt_time;//时间计数器
reg [10:0]        cnt_aver;//均值计数器
reg [WIDTH+9:0] data_sum;//取1024个ad_data求和，最大位宽:[WIDTH+10-1:0]
reg [WIDTH-1:0 ]  data_aver;//一段数据的均值
reg [16:0]        temp0;
reg [7:0]         temp1;
reg [7:0]         temp2;
reg [7:0]         temp3;

//*****************************************************
//**                    main code
//*****************************************************

//0.2秒计数器
always @(posedge clk or negedge rst_n )begin
	if(!rst_n) 
		cnt_time <= 25'd0;
	else if(voc_finish)begin
		if(cnt_time == TIME_200MS - 1'b1)  
			cnt_time <= 25'd0;
		else
			cnt_time <= cnt_time + 25'd1;
	end
	else
		cnt_time <= 25'd0;
end

//均值计数器，用来计数size个数据求和然后求均值
always @(posedge clk or negedge rst_n )begin
	if(!rst_n) 
		cnt_aver <= 11'd0;
	else if(voc_finish)begin
		if(cnt_aver == SIZE)  
			cnt_aver <= 11'd0;
		else
			cnt_aver <= cnt_aver + 11'd1;
	end
	else
		cnt_aver <= 11'd0;
end

//size个数据求和    
always @(posedge clk or negedge rst_n )begin
	if(!rst_n)
		data_sum <= 'd0;
	else if(voc_finish)begin
		if(cnt_aver == SIZE)
			data_sum <= 'd0;
		else
			data_sum <= data_sum + ad_data;
	end
	else
		data_sum <= 'd0;
end

//求均值 
always @(posedge clk or negedge rst_n )begin
	if(!rst_n)
		data_aver <= 'd0;
	else if(cnt_aver == SIZE)begin
		if(data_sum[9:0] >= 10'd512)//四舍五入
			data_aver <= data_sum[WIDTH+9:10] + 8'd1;
		else
			data_aver <= data_sum[WIDTH+9:10];
	end
	else;
end    

//将均值与0v校准值进行比较，计算得到电压的绝对值，并扩大1000倍
always @(posedge clk or negedge rst_n )begin
	if(!rst_n)
		temp0 <= 17'd0;
	else if(data_aver >= voc_data)
		temp0 <= 5000*(data_aver - voc_data)/(256 - voc_data);
	else
		temp0 <= 5000*(voc_data - data_aver)/(voc_data + 1);
end

//扩大1000倍的电压整除1000，得到电压的个位数值
always @(posedge clk or negedge rst_n )begin
	if(!rst_n)
		temp1 <= 12'd0;
	else 
		temp1 <= temp0 / 1000;
end

//扩大1000倍的电压整除100
always @(posedge clk or negedge rst_n )begin
	if(!rst_n)
		temp2 <= 14'd0;
	else
		temp2 <= temp0 / 100;
end

//扩大1000倍的电压对100取余
always @(posedge clk or negedge rst_n )begin
	if(!rst_n)
		temp3 <= 4'd0;
	else
		temp3 <= temp0%100;
end

//经过计算得到最终显示的电压值   
always @(posedge clk or negedge rst_n )begin
	if(!rst_n)begin
		data_symbol <= 1'b0;
		data_percentiles <= 8'd0;
		data_decile <= 8'd0;
		data_units <= 8'd0;
		data_tens <= 8'd0;
	end
	else if(ad_otr&&cnt_time == TIME_200MS - 1'b1)begin
		data_symbol <= 1'b0;
		data_percentiles <= 8'd9;
		data_decile <= 8'd9;
		data_units <= 8'd9;
		data_tens <= 8'd9;
	end
	else if(cnt_time == TIME_200MS - 1'b1)begin
		if(data_aver >= voc_data)begin
			data_symbol <= 1'b0;
			data_tens <= 1'b0;
			data_units <= temp1;
			data_decile <= temp2 - temp1*10;
			data_percentiles <= temp3/10;
		end
		else begin
			data_symbol <= 1'b1;
			data_tens <= 1'b0;
			data_units <= temp1;
			data_decile <= temp2 - temp1*10;
			data_percentiles <= temp3/10;
		end
	end
	else ;
end   
	
endmodule
 

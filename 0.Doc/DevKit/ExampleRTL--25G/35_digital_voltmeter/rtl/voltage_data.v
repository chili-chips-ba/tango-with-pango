//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com 
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved                               
//----------------------------------------------------------------------------------------
// File name:           voltage_data
// Last modified Date:  2019/8/07 10:41:06
// Last Version:        V1.0
// Descriptions:        ��ѹ���ݴ���ģ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
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
	input             ad_otr           ,//0:�����̷�Χ 1:��������							      
	input             voc_finish       ,//��ƽУ׼��ɱ�־
	input [WIDTH-1:0] voc_data         ,//��ƽУ׼��ɱ�־
	output reg        data_symbol      ,//��ѹֵ����λ������ѹ���λ��ʾ����,����ѹ��ʾ�ո�
	output reg [7:0]  data_percentiles ,//��ѹֵС�����ڶ�λ      
	output reg [7:0]  data_decile      ,//��ѹֵС������һλ     
	output reg [7:0]  data_units       ,//��ѹֵ�ĸ�λ��        
	output reg [7:0]  data_tens         //��ѹֵ��ʮλ��       
	);

//parameter 	
parameter SIZE = 25'd1024; //ȡƽ��ֵ�ĳߴ� 
parameter TIME_200MS = 25'd5_000_000;//����0.2��
//parameter TIME_200MS=25'd5000;//0.2���������,������ʹ��

//reg define
reg [24:0]        cnt_time;//ʱ�������
reg [10:0]        cnt_aver;//��ֵ������
reg [WIDTH+9:0] data_sum;//ȡ1024��ad_data��ͣ����λ��:[WIDTH+10-1:0]
reg [WIDTH-1:0 ]  data_aver;//һ�����ݵľ�ֵ
reg [16:0]        temp0;
reg [7:0]         temp1;
reg [7:0]         temp2;
reg [7:0]         temp3;

//*****************************************************
//**                    main code
//*****************************************************

//0.2�������
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

//��ֵ����������������size���������Ȼ�����ֵ
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

//size���������    
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

//���ֵ 
always @(posedge clk or negedge rst_n )begin
	if(!rst_n)
		data_aver <= 'd0;
	else if(cnt_aver == SIZE)begin
		if(data_sum[9:0] >= 10'd512)//��������
			data_aver <= data_sum[WIDTH+9:10] + 8'd1;
		else
			data_aver <= data_sum[WIDTH+9:10];
	end
	else;
end    

//����ֵ��0vУ׼ֵ���бȽϣ�����õ���ѹ�ľ���ֵ��������1000��
always @(posedge clk or negedge rst_n )begin
	if(!rst_n)
		temp0 <= 17'd0;
	else if(data_aver >= voc_data)
		temp0 <= 5000*(data_aver - voc_data)/(256 - voc_data);
	else
		temp0 <= 5000*(voc_data - data_aver)/(voc_data + 1);
end

//����1000���ĵ�ѹ����1000���õ���ѹ�ĸ�λ��ֵ
always @(posedge clk or negedge rst_n )begin
	if(!rst_n)
		temp1 <= 12'd0;
	else 
		temp1 <= temp0 / 1000;
end

//����1000���ĵ�ѹ����100
always @(posedge clk or negedge rst_n )begin
	if(!rst_n)
		temp2 <= 14'd0;
	else
		temp2 <= temp0 / 100;
end

//����1000���ĵ�ѹ��100ȡ��
always @(posedge clk or negedge rst_n )begin
	if(!rst_n)
		temp3 <= 4'd0;
	else
		temp3 <= temp0%100;
end

//��������õ�������ʾ�ĵ�ѹֵ   
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
 

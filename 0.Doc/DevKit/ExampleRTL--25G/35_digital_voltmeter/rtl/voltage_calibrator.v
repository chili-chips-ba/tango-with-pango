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
// Descriptions:        0V��ѹУ׼ģ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
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
	output reg             voc_finish, //0vУ׼��ɱ�־
	output reg [WIDTH-1:0] voc_data    //У׼��0v��Ӧ��ad��ֵ
    );
	
//reg define
reg [WIDTH+9:0] ad_data_sum;//ȡ1024��ad_data��ͣ����λ��:[WIDTH+10-1:0]
reg [11:0]      ad_data_cnt;//��ad_data���ݼ���

//*****************************************************
//**                    main code
//*****************************************************

//��voc_finishΪ��ʱ��ad_data���ݼ���
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		ad_data_cnt <= 10'd0;
	else if(!voc_finish)
		ad_data_cnt <= ad_data_cnt + 10'd1;
	else
		ad_data_cnt <= 10'd0;
end

//ad_data_cnt����2047ʱ������voc_finish�źš�	
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		voc_finish <= 1'b0;
	else if(ad_data_cnt == 2047)
		voc_finish <= 1'b1;
	else;
end	

//ȡ1024��ad_data���ݽ�����͡�
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	
		ad_data_sum <= 'd0;
	else if(ad_data_cnt >= 1023&&ad_data_cnt < 2047)
		ad_data_sum <= ad_data_sum + ad_data;
	else;
end

//1024��ad_data����ȡƽ��ֵ��	
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	
		voc_data <= 'd0;
	else if(ad_data_cnt == 2047)begin
		if(ad_data_sum[9:0] >= 10'd512)//��������
			voc_data <= ad_data_sum[WIDTH+9:10] + 1'b1;
		else
			voc_data <= ad_data_sum[WIDTH+9:10];
	end
	else;
end
	
endmodule

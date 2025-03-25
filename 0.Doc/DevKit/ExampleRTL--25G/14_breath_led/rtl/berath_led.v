//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           breath_led
// Created by:          ����ԭ��
// Created date:        2023��3��1��09:40:02
// Version:             V1.0
// Descriptions:        ������ʵ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module breath_led(
    input       sys_clk ,      //ϵͳʱ�� 50MHz
    input       sys_rst_n ,    //ϵͳ��λ���͵�ƽ��Ч
    
    output reg  led            //LED��
);

//parameter define
parameter CNT_2US_MAX = 7'd100;    
parameter CNT_2MS_MAX = 10'd1000; 
parameter CNT_2S_MAX  = 10'd1000; 

//reg define
reg [6:0] cnt_2us; 
reg [9:0] cnt_2ms;   
reg [9:0] cnt_2s;     
reg       inc_dec_flag; //���ȵ���/�ݼ� 0:���� 1:�ݼ�

//*****************************************************
//**                  main code
//*****************************************************

//cnt_2us:����2us
always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt_2us <= 7'b0;
    else if(cnt_2us == (CNT_2US_MAX - 7'b1 ))
        cnt_2us <= 7'b0;
    else
        cnt_2us <= cnt_2us + 7'b1;
end

//cnt_2ms:����2ms
always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt_2ms <= 10'b0;
    else if(cnt_2ms == (CNT_2MS_MAX - 10'b1) && cnt_2us == (CNT_2US_MAX - 7'b1))
        cnt_2ms <= 10'b0;
    else if(cnt_2us == CNT_2US_MAX - 7'b1)
        cnt_2ms <= cnt_2ms + 10'b1;
    else
        cnt_2ms <= cnt_2ms;
end

//cnt_2s:����2s
always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt_2s <= 10'b0;
    else if(cnt_2s == (CNT_2S_MAX - 10'b1) && cnt_2ms == (CNT_2MS_MAX - 10'b1) && cnt_2us == (CNT_2US_MAX - 7'b1))
        cnt_2s <= 10'b0;
    else if(cnt_2ms == (CNT_2MS_MAX - 10'b1) && cnt_2us == (CNT_2US_MAX - 7'b1))
        cnt_2s <= cnt_2s + 10'b1;
    else
        cnt_2s <= cnt_2s;         
end

//inc_dec_flagΪ�͵�ƽ��led���ɰ�������inc_dec_flagΪ�ߵ�ƽ��led�������䰵
always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        inc_dec_flag <= 1'b0;
    else if(cnt_2s == (CNT_2S_MAX - 10'b1) && cnt_2ms ==( CNT_2MS_MAX - 10'b1) && cnt_2us == (CNT_2US_MAX - 7'b1))
        inc_dec_flag <= ~inc_dec_flag;
    else
        inc_dec_flag <= inc_dec_flag;
end

//led:����ź����ӵ��ⲿ��led��
always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        led <= 1'b0;
    else if((inc_dec_flag == 1'b1 && cnt_2ms >= cnt_2s) || (inc_dec_flag == 1'b0 && cnt_2ms <= cnt_2s))
        led <= 1'b1;
    else
        led <= 1'b0;
end

endmodule
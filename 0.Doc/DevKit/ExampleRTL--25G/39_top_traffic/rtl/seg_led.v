//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           seg_led
// Created by:          ����ԭ��
// Created date:        2023��2��3��14:17:02
// Version:             V1.0
// Descriptions:        seg_led
//
//----------------------------------------------------------------------------------------
//****************************************************************************************///

module seg_led(
    input                  sys_clk     ,     //ϵͳʱ�� 
    input                  sys_rst_n   ,     //ϵͳ��λ 
    input        [7:0]     ew_time     ,     //�������������Ҫ��ʾ����ֵ
    input        [7:0]     sn_time     ,     //�ϱ����������Ҫ��ʾ��ֵ
    output  reg  [3:0]     sel         ,     //�����λѡ�ź�
    output  reg  [7:0]     seg_led           //����ܶ�ѡ�ź�,����С����
);
//parameter define
parameter  WIDTH = 50_000;                   // ����1ms�ļ������
//reg define                                    
reg    [15:0]             cnt_1ms;           // ����1ms�ļ�����
reg    [1:0]              cnt_state;         // �����л�Ҫ���������
reg    [3:0]              num;               // �����Ҫ��ʾ������
//wire define                                   
wire   [3:0]              data_ew_0;         // ������������ܵ�ʮλ
wire   [3:0]              data_ew_1;         // ������������ܵĸ�λ
wire   [3:0]              data_sn_0;         // �ϱ���������ܵ�ʮλ
wire   [3:0]              data_sn_1;         // �ϱ���������ܵĸ�λ

//*****************************************************
//**                    main code                      
//*****************************************************

assign  data_ew_0   = ew_time[7:4];          // ������ʱ�����ݵ�ʮλ
assign  data_ew_1   = ew_time[3:0];          // ������ʱ�����ݵĸ�λ
assign  data_sn_0   = sn_time[7:4];          // �ϱ���ʱ�����ݵ�ʮλ
assign  data_sn_1   = sn_time[3:0];          // �ϱ���ʱ�����ݵĸ�λ

//����1ms
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        cnt_1ms <= 15'b0;
    else if (cnt_1ms < WIDTH - 1'b1)
        cnt_1ms <= cnt_1ms + 1'b1;
    else
        cnt_1ms <= 15'b0;
end

//�������������л�����ܵ�����4��״̬
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        cnt_state <= 2'd0;
    else  if (cnt_1ms == WIDTH - 1'b1)
        cnt_state <= cnt_state + 1'b1;
    else
        cnt_state <= cnt_state;
end
 
//����ʾ������������ܵ�ʮλ��Ȼ���Ǹ�λ������ʾ�ϱ���������ܵ�ʮλ��Ȼ���λ
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        sel  <= 4'b1111;
        num  <= 4'b0;
    end 
    else begin       
        case (cnt_state) 
            3'd0 : begin     
                sel <= 4'b1110;              //����������������ܵ�ʮλ  
                num <= data_ew_0;
            end       
            3'd1 : begin     
                sel <= 4'b1101;              //����������������ܵĸ�λ
                num <= data_ew_1;
            end 
            3'd2 : begin 
                sel <= 4'b1011;              //�����ϱ���������ܵ�ʮλ
                num  <= data_sn_0;
            end
            3'd3 : begin 
                sel <= 4'b0111;              //�����ϱ���������ܵĸ�λ
                num  <= data_sn_1 ;    
            end
            default : begin     
                sel <= 4'b1111;                     
                num <= 4'b0;
            end 
        endcase
    end
end
 
//�����Ҫ��ʾ����ֵ����Ӧ�Ķ�ѡ�ź�      
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) 
        seg_led <= 8'b0; 
    else begin
        case (num)              
            4'd0 : seg_led <= 8'b1100_0000;                                                      
            4'd1 : seg_led <= 8'b1111_1001;                          
            4'd2 : seg_led <= 8'b1010_0100;                          
            4'd3 : seg_led <= 8'b1011_0000;                          
            4'd4 : seg_led <= 8'b1001_1001;                          
            4'd5 : seg_led <= 8'b1001_0010;                          
            4'd6 : seg_led <= 8'b1000_0010;                          
            4'd7 : seg_led <= 8'b1111_1000;    
            4'd8 : seg_led <= 8'b1000_0000;    
            4'd9 : seg_led <= 8'b1001_0000;
            default : seg_led <= 8'b1100_0000;
        endcase
    end 
end

endmodule
//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           key_beep
// Created by:          ����ԭ��
// Created date:        2023��2��16��14:22:02
// Version:             V1.0
// Descriptions:        �������Ʒ�����ģ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module key_beep(
    input        sys_clk,
    input        sys_rst_n,

    input        key_filter,   //�����󰴼�ֵ
    output  reg  beep          //������
    );

//reg define
reg    key_filter_d0;          //��������İ���ֵ�ӳ�һ��ʱ������

//wire define
wire   neg_key_filter;         //������Ч���ź�
 
//*****************************************************
//**                    main code
//*****************************************************

//���񰴼��˿ڵ��½��أ��õ�һ��ʱ�����ڵ������ź�
assign  neg_key_filter = (~key_filter) & key_filter_d0;

//�԰����˿ڵ������ӳ�һ��ʱ������
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) 
        key_filter_d0 <= 1'b1;
    else 
        key_filter_d0 <= key_filter;
end

//ÿ�ΰ�������ʱ���ͷ�ת��������״̬
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        beep <= 1'b1;
    else if(neg_key_filter)  //��Ч��һ�ΰ���������
        beep <= ~beep;
    else
        beep <= beep;
end

endmodule

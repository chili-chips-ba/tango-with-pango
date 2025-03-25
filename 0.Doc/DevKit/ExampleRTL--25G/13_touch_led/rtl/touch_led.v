//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           touch_led
// Created by:          ����ԭ��
// Created date:        2023��2��22��14:17:02
// Version:             V1.0
// Descriptions:        ������������led��ʵ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module touch_led(
    //input
    input        sys_clk,      //ʱ���ź�50Mhz
    input        sys_rst_n,    //��λ�ź�
    input        touch_key,    //�������� 
 
    //output
    output  reg  led           //LED��
);

//reg define
reg    touch_key_d0;    //���������˿ڵ������ӳ�һ��ʱ������
reg    touch_key_d1;    //���������˿ڵ������ӳ�����ʱ������

//wire define
wire   touch_en;       //������Ч���ź�

//*****************************************************
//**                    main code
//*****************************************************

//�����������˿ڵ������أ��õ�һ��ʱ�����ڵ������ź�
assign  touch_en = (~touch_key_d1) & touch_key_d0;

//�Դ��������˿ڵ������ӳ�����ʱ������
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        touch_key_d0 <= 1'b0;
        touch_key_d1 <= 1'b0;
    end
    else begin
        touch_key_d0 <= touch_key;
        touch_key_d1 <= touch_key_d0;
    end 
end

//���ݴ������������ص������ź��л�led״̬
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        led <= 1'b1;       //Ĭ��״̬��,����LED
    else begin 
        if (touch_en)      //��⵽���������ź�
            led <= ~led;
    end
end

endmodule


//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           top_key_beep
// Created by:          ����ԭ��
// Created date:        2023��2��16��14:17:02
// Version:             V1.0
// Descriptions:        �������Ʒ�����ʵ�鶥��ģ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module top_key_beep(
    input        sys_clk   ,    //ϵͳʱ��
    input        sys_rst_n ,    //ϵͳ��λ���͵�ƽ��Ч

    input        key       ,    //����    
    output       beep           //������
);

//parameter define
parameter  CNT_MAX = 20'd100_0000;   //����ʱ��20ms

//wire define
wire key_filter ;                    //�����������ֵ

//*****************************************************
//**                    main code
//*****************************************************

//������������ģ��
key_debounce #(
    .CNT_MAX    (CNT_MAX)  
)u_key_debounce(
    .sys_clk       (sys_clk),
    .sys_rst_n     (sys_rst_n),
    .key           (key),
    .key_filter    (key_filter)
    );

//�����������Ʒ�����ģ��
key_beep  u_key_beep(
    .sys_clk       (sys_clk),
    .sys_rst_n     (sys_rst_n),
    .key_filter    (key_filter),
    .beep          (beep)
    );

endmodule

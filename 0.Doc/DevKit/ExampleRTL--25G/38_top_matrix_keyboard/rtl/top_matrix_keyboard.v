//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           top_matrix_keyboard
// Created by:          ����ԭ��
// Created date:        2023��2��3��14:17:02
// Version:             V1.0
// Descriptions:        top_matrix_keyboard
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module top_matrix_keyboard(
    input         sys_clk    ,
    input         sys_rst_n  ,
    input   [3:0] key_row    ,
    input   [7:0] swi        ,
    output  [3:0] key_col    ,
    output  [3:0] sel_t      ,
    output  [7:0] seg_led_t  ,
    output  [7:0] led

    );

//wire define
wire [4:0]    key_value    ;
wire          key_flag     ;

//*****************************************************
//**                    main code                      
//*****************************************************

//�������ɨ��ģ��
key_4x4    u_key_4x4(
    .sys_clk    (sys_clk  ),
    .sys_rst_n  (sys_rst_n),
    .key_row    (key_row  ),
    .key_col    (key_col  ),
    .key_value  (key_value),
    .key_flag   (key_flag )
    );

//�������ʾģ��
seg_led    u_seg_led(
    .clk       (sys_clk  ),
    .rst_n     (sys_rst_n),
    .key_value (key_value),
    .key_flag  (key_flag ),
    .sel_t     (sel_t    ),
    .seg_led_t (seg_led_t)
    );

//���뿪��ģ��
swi_led     u_swi_led(
    .clk     (sys_clk  ),
    .rst_n   (sys_rst_n),
    .swi     (swi      ),
    .led     (led      )
);
endmodule
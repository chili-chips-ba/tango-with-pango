//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           top_remote_rcv
// Last modified Date:  2023��9��8��13:11:06
// Last Version:        V1.0
// Descriptions:        ����ң��ʵ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2023��9��8��13:11:06
// Version:             V1.0
// Descriptions:        The original version
//----------------------------------------------------------------------------------------
//****************************************************************************************// 

module top_remote_rcvr#(
    //parameter define
    parameter       CHAR_POS_X   = 11'd1            ,   // �ַ�������ʼ�������
    parameter       CHAR_POS_Y   = 11'd1            ,   // �ַ�������ʼ��������
    parameter       CHAR_WIDTH   = 11'd88           ,   // �ַ�������
    parameter       CHAR_HEIGHT  = 11'd16           ,   // �ַ�����߶�
    parameter       WHITE        = 24'hFFFFFF       ,   // ����ɫ����ɫ
    parameter       BLACK        = 24'h0                // �ַ���ɫ����ɫ
)(
    input             sys_clk  ,    //ϵͳʱ�� 
    input             sys_rst_n,    //ϵͳ��λ�źţ��͵�ƽ��Ч
    input             remote_in,    //��������ź�

	output             lcd_hs     ,             // LCD ��ͬ���ź�
	output             lcd_vs     ,             // LCD ��ͬ���ź�
	output             lcd_de     ,             // LCD ��������ʹ��
	inout      [23:0]  lcd_rgb    ,             // LCD RGB��ɫ����
	output             lcd_bl     ,             // LCD ��������ź�
	output             lcd_clk    ,             // LCD ����ʱ��
    output             lcd_rst    ,
    output             led                      //led��
);

//wire define
wire  [7:0]   data       ;
wire          repeat_en  ;

//*****************************************************
//**                    main code
//*****************************************************


//HS0038B����ģ��
remote_rcv u_remote_rcv(               
    .sys_clk        (sys_clk),  
    .sys_rst_n      (sys_rst_n),    
    .remote_in      (remote_in),
    .repeat_en      (repeat_en),                
    .data_en        (),
    .data           (data)
    );

led_ctrl  u_led_ctrl(
    .sys_clk       (sys_clk),
    .sys_rst_n     (sys_rst_n),
    .repeat_en     (repeat_en),
    .led           (led)
    );

//����LCD��ʾģ��
lcd_rgb_char 
#(
    .CHAR_POS_X     (CHAR_POS_X ),
    .CHAR_POS_Y     (CHAR_POS_Y ),
    .CHAR_WIDTH     (CHAR_WIDTH ),
    .CHAR_HEIGHT    (CHAR_HEIGHT),
    .WHITE          (WHITE      ),
    .BLACK          (BLACK      )
)
u_lcd_rgb_char(
    .sys_clk        (sys_clk    ),
    .sys_rst_n      (sys_rst_n  ),
    .data           (data       ),     
    .lcd_hs         (lcd_hs     ),          // LCD ��ͬ���ź�
    .lcd_vs         (lcd_vs     ),          // LCD ��ͬ���ź�
    .lcd_de         (lcd_de     ),          // LCD ��������ʹ��
    .lcd_rgb        (lcd_rgb    ),          // LCD RGB888��ɫ����
    .lcd_bl         (lcd_bl     ),          // LCD ��������ź�
    .lcd_clk        (lcd_clk    ),          // LCD ����ʱ��
    .lcd_rst        (lcd_rst    )
);

endmodule
//****************************************Copyright (c)***********************************//
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com 
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡFPGA & STM32���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved                                
//----------------------------------------------------------------------------------------
// File name:           tb_top_traffic
// Last modified Date:  2018/6/8 9:26:44
// Last Version:        V1.0
// Descriptions:        �źŵƿ���ģ��
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2018/6/8 9:26:47
// Version:             V1.0
// Descriptions:        The original version
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2023/5/17 20:30:47
// Version:             V1.0
// Descriptions:        �Ż����룬����ע�͡�
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
// Modified by:       ����ԭ��
// Modified date:     
// Version:         
// Descriptions:      
//----------------------------------------------------------------------------------------
//****************************************************************************************//

`timescale 1ns/1ns
module tb_top_traffic     ();    //top_traffic
reg            sys_clk    ;      //ϵͳʱ��
reg            sys_rst_n  ;      //ϵͳ��λ                          
wire  [3:0]    sel        ;      //�����λѡ�ź�
wire  [7:0]    seg_led    ;      //����ܶ�ѡ�ź�
wire  [5:0]    led        ;      //led�ƿ����ź�

//paramater difine
parameter  TWINKLE_CNT   = 2;             //�Ƶ���˸��ʱ�����
parameter  TIME_LED_Y    = 3;             //�ƵƷ����ʱ��
parameter  TIME_LED_R    = 10;            //��Ʒ����ʱ��
parameter  TIME_LED_G    = 7;             //�̵Ʒ����ʱ��
parameter  WIDTH_CNT     = 8;             //����Ƶ��Ϊ1hz��ʱ��
parameter  WIDTH         = 2;             //����1ms�ļ������

initial begin
        sys_clk        <= 1'b0;
        sys_rst_n      <= 1'b0;
        # 20 sys_rst_n <= 1'b1;
end

always # 10 sys_clk = ~sys_clk;  //����Ƶ��Ϊ50Mhz��ʱ��

//������ͨ�ƶ���ģ��
top_traffic 
#(
    .TWINKLE_CNT (TWINKLE_CNT ),
    .TIME_LED_Y  (TIME_LED_Y  ),
    .TIME_LED_R  (TIME_LED_R  ),
    .TIME_LED_G  (TIME_LED_G  ),
    .WIDTH_CNT   (WIDTH_CNT   ),
    .WIDTH       (WIDTH       )
)
u_top_traffic(
    .sys_clk   (sys_clk   ),
    .sys_rst_n (sys_rst_n ),
    .sel       (sel       ),
    .seg_led   (seg_led   ),
    .led       (led       )
);

endmodule
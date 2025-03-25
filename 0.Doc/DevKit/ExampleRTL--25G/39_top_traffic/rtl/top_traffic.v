//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           top_traffic
// Created by:          ����ԭ��
// Created date:        2023��2��3��14:17:02
// Version:             V1.0
// Descriptions:        top_traffic
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module top_traffic( 
    input                  sys_clk   ,    //ϵͳʱ���ź�
    input                  sys_rst_n ,    //ϵͳ��λ�ź�
    output       [3:0]     sel       ,    //�����λѡ�ź�
    output       [7:0]     seg_led   ,    //����ܶ�ѡ�ź�
    output       [5:0]     led            //LEDʹ���ź�,���̻Ƶ�
);
//paramater difine
parameter  TWINKLE_CNT   = 10000000;      //�Ƶ���˸��ʱ�����
parameter  TIME_LED_Y    = 3;             //�ƵƷ����ʱ��
parameter  TIME_LED_R    = 30;            //��Ʒ����ʱ��
parameter  TIME_LED_G    = 27;            //�̵Ʒ����ʱ��
parameter  WIDTH_CNT     = 25000000;      //����Ƶ��Ϊ1hz��ʱ��
parameter  WIDTH         = 50000;         //����1ms�ļ������
//wire define    
wire   [5:0]    ew_time;                    //��������״̬ʣ��ʱ������
wire   [5:0]    sn_time;                    //�ϱ�����״̬ʣ��ʱ������ 
wire   [1:0]    state  ;                    //��ͨ�Ƶ�״̬�����ڿ���LED�Ƶĵ���
wire   [7:0]    ew_bcd_time;
wire   [7:0]    sn_bcd_time;

//*****************************************************
//**                    main code                      
//*****************************************************

//��ͨ�ƿ���ģ��    
traffic_light_ctrl 
#(
    .TIME_LED_Y     (TIME_LED_Y ),
    .TIME_LED_R     (TIME_LED_R ),
    .TIME_LED_G     (TIME_LED_G ),
    .WIDTH_CNT      (WIDTH_CNT  )
)
u_traffic_light_ctrl(
    .sys_clk        (sys_clk   ),
    .sys_rst_n      (sys_rst_n ),
    .state          (state     ),
    .ew_time        (ew_time   ),
    .sn_time        (sn_time   )
);

//������תBCD
binary2bcd u_binary2bcd_ew(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .data           (ew_time),
    
    .bcd_data       (ew_bcd_time)
    
);

//������תBCD
binary2bcd u_binary2bcd_sn(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .data           (sn_time),
    
    .bcd_data       (sn_bcd_time)
    
);

//�������ʾģ��   
seg_led 
#(
    .WIDTH (WIDTH )
)
u_seg_led(
    .sys_clk        (sys_clk   ),
    .sys_rst_n      (sys_rst_n ),
    .ew_time        (ew_bcd_time),
    .sn_time        (sn_bcd_time),
    .sel            (sel       ),
    .seg_led        (seg_led   )
);

//led�ƿ���ģ��
led_ctrl 
#(
    .TWINKLE_CNT (TWINKLE_CNT )
)
u_led_ctrl(
    .sys_clk       (sys_clk   ),
    .sys_rst_n     (sys_rst_n ),
    .state         (state     ),
    .led           (led       )
);

endmodule        
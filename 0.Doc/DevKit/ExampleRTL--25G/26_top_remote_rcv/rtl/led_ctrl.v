//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           led_ctrl
// Last modified Date:  2023��9��8��13:11:06
// Last Version:        V1.0
// Descriptions:        LED�ƿ���
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2023��9��8��13:11:06
// Version:             V1.0
// Descriptions:        The original version
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module led_ctrl(
    input             sys_clk   ,  //ϵͳʱ��
    input             sys_rst_n ,  //ϵͳ��λ�źţ��͵�ƽ��Ч
    
    input             repeat_en ,  //�ظ��봥���ź�
    output    reg     led          //LED��
    );

//reg define
reg            repeat_en_d0 ;      //repeat_en�źŴ��Ĳ���
reg            repeat_en_d1 ;
reg    [22:0]  led_cnt      ;      //LED�Ƽ�����,���ڿ���LED������

//wire define
wire           pos_repeat_en;

//*****************************************************
//**                    main code
//*****************************************************

assign  pos_repeat_en = ~repeat_en_d1 & repeat_en_d0;

////repeat_en�źŴ��Ĳ���
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        repeat_en_d0 <= 1'b0;
        repeat_en_d1 <= 1'b0;
    end
    else begin
        repeat_en_d0 <= repeat_en;
        repeat_en_d1 <= repeat_en_d0;
    end
end    

//�����ظ���:��80ms ��20ms
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        led <= 1'b0;
    else if (pos_repeat_en)//led����ʱ��:4_000_000*20ns=80ms
        led <= 1'b1;
    else if (led_cnt < 23'd1_000_000)//led���ʱ��:1_000_000*20ns=20ms
        led <= 1'b0;
    else
        led <= led;
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) 
        led_cnt <= 23'd0;
    else if(pos_repeat_en)
        led_cnt <= 23'd5_000_000;
    else if(led_cnt != 23'd0)
        led_cnt <= led_cnt - 23'd1;
    else
        led_cnt <= led_cnt;
end
  
endmodule
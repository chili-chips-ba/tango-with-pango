//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           rw_result_led
// Created by:          ����ԭ��
// Created date:        2023��5��17��14:17:02
// Version:             V1.0
// Descriptions:        LED0�Ƴ�����ʾ��д������ȷ��LED0��˸��ʾ��д���Դ���
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module rw_result_led 
    #(parameter L_TIME = 17'd125_000
    )
    (
    input        clk       ,  //ʱ���ź�
    input        rst_n     ,  //��λ�ź�
                 
    input        rw_done   ,  //�����־
    input        rw_result ,  //E2PROM��д�������
    output  reg  led          //E2PROM��д���Խ�� 0:ʧ�� 1:�ɹ�
);

//reg define
reg          rw_done_flag;    //��д������ɱ�־
reg  [16:0]  led_cnt     ;    //led����

//*****************************************************
//**                    main code
//*****************************************************

//��д������ɱ�־
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rw_done_flag <= 1'b0;
    else if(rw_done)
        rw_done_flag <= 1'b1;
end        

//�����־Ϊ1ʱLED0��˸������LED0����
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        led_cnt <= 17'd0;
        led <= 1'b0;
    end
    else begin
        if(rw_done_flag) begin
            if(rw_result)                          //��д������ȷ
                led <= 1'b1;                       //led�Ƴ���
            else begin                             //��д���Դ���
                led_cnt <= led_cnt + 17'd1;
                if(led_cnt == (L_TIME - 17'b1)) begin
                    led_cnt <= 17'd0;
                    led <= ~led;                   //led����˸
                end
                else
                    led <= led;
            end
        end
        else
            led <= 1'b0;                           //��д�������֮ǰ,led��Ϩ��
    end    
end

endmodule

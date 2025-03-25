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
// Created by:          ����ԭ��
// Created date:        2023��5��31��14:17:02
// Version:             V1.0
// Descriptions:        led�ƿ���ģ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module led_ctrl(
    input            clk     ,    //�ⲿ50Mʱ��
    input            rst_n   ,    //�ⲿ��λ�źţ�����Ч
    
    input            led_en  ,    //led����ʹ��
    input      [1:0] led_data,    //led��������
    
    output reg [1:0] led          //led��
    );

//*****************************************************
//**                    main code
//*****************************************************

//����led�Ƶı仯
always @(posedge clk or negedge rst_n) begin 
    if (!rst_n) 
        led <= 2'b00;
    else if(led_en)              //��led_enʹ��ʱ���ı�led�Ƶ�״̬
            led <= ~led_data;    //��������ʱΪ�͵�ƽ����led�ߵ�ƽʱ����
        else
            led <= led;
end
    
endmodule 
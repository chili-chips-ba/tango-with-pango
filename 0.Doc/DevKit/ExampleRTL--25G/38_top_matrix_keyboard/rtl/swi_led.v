//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           swi_led
// Created by:          ����ԭ��
// Created date:        2023��2��3��14:17:02
// Version:             V1.0
// Descriptions:        swi_led
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module swi_led(
    input              clk    ,
    input              rst_n  ,
    input     [7:0]    swi    ,
    output reg[7:0]    led   
);

//*****************************************************
//**                    main code                      
//*****************************************************

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
        led <= 8'b0000_0000;
    else
        led <= swi;
end

endmodule
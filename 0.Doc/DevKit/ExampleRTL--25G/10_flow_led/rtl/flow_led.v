//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           flow_led
// Created by:          ����ԭ��
// Created date:        2023��2��22��14:17:02
// Version:             V1.0
// Descriptions:        ��ˮ��ʵ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module flow_led(
    input               sys_clk  ,  //ϵͳʱ��
    input               sys_rst_n,  //ϵͳ��λ���͵�ƽ��Ч

    output  reg  [3:0]  led         //LED��
);

//reg define
reg  [24:0]  cnt ;                  //������

//*****************************************************
//**                    main code
//*****************************************************

//��������ʱ0.5s
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt <= 25'd0;
    else if(cnt < (25'd2500_0000 - 25'd1))
        cnt <= cnt + 25'd1;
    else
        cnt <= 25'd0;
end

//��LED�ƽ�����λ���ƣ������4λLED��״̬
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        led <= 2'b01;
    else if(cnt == (25'd2500_0000 - 25'd1))
        led <= {led[2],led[1],led[0],led[3]};
    else
        led <= led;
end

endmodule

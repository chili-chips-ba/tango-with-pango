//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                 
//----------------------------------------------------------------------------------------
// File name:           arp_ctrl
// Last modified Date:  2020/2/13 9:20:14
// Last Version:        V1.0
// Descriptions:        arp����ģ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2020/2/13 9:20:14
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module arp_ctrl(
    input                clk        , //����ʱ��   
    input                rst_n      , //��λ�źţ��͵�ƽ��Ч
    
    input                touch_key  , //��������,���ڴ��������巢��ARP����
    input                arp_rx_done, //ARP��������ź�
    input                arp_rx_type, //ARP�������� 0:����  1:Ӧ�� 
    output  reg          arp_tx_en  , //ARP����ʹ���ź�
    output  reg          arp_tx_type  //ARP�������� 0:����  1:Ӧ��
    );

//reg define
reg         touch_key_d0;
reg         touch_key_d1;

//wire define
wire        pos_touch_key;  //touch_key�ź�������

//*****************************************************
//**                    main code
//*****************************************************

assign pos_touch_key = ~touch_key_d1 & touch_key_d0;

//��arp_tx_en�ź���ʱ��������,���ڲ�touch_key��������
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        touch_key_d0 <= 1'b0;
        touch_key_d1 <= 1'b0;
    end
    else begin
        touch_key_d0 <= touch_key;
        touch_key_d1 <= touch_key_d0;
    end
end

//Ϊarp_tx_en��arp_tx_type��ֵ
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        arp_tx_en <= 1'b0;
        arp_tx_type <= 1'b0;
    end
    else begin
        if(pos_touch_key == 1'b1) begin  //��⵽���봥������������
            arp_tx_en <= 1'b1;           
            arp_tx_type <= 1'b0;
        end
        //���յ�ARP����,��ʼ����ARP����ģ��Ӧ��
        else if((arp_rx_done == 1'b1) && (arp_rx_type == 1'b0)) begin
            arp_tx_en <= 1'b1;
            arp_tx_type <= 1'b1;
        end
        else
            arp_tx_en <= 1'b0;
    end
end

endmodule

//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           key_trig
// Created by:          ����ԭ��
// Created date:        2023��5��31��14:17:02
// Version:             V1.0
// Descriptions:        ��������ģ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module key_trig(
    input            clk           ,  //�ⲿ50Mʱ��
    input            rst_n         ,  //�ⲿ��λ�źţ�����Ч
    
    input      [1:0] key           ,  //�ⲿ��������
    
    output reg       key_data_valid,  //����������Ч��־
    output     [1:0] key_data         //��������
    );

//reg define
reg [1:0] key_data_d0;
reg [1:0] key_data_d1;

//*****************************************************
//**                    main code
//*****************************************************

//��key_data�źŴ����������жϰ����Ƿ����ı�
always @(posedge clk or negedge rst_n) begin 
    if (!rst_n) begin 
        key_data_d0 <= 2'b11;
        key_data_d1 <= 2'b11;
    end
    else begin
        key_data_d0 <= key_data;
        key_data_d1 <= key_data_d0;
    end
end

//����⵽�������ݷ����ı�ʱ��key_data_valid����
always @(posedge clk or negedge rst_n) begin 
    if (!rst_n)
        key_data_valid <= 1'b0;
    else if (key_data_d1 != key_data_d0)
        key_data_valid  <= 1'b1;
    else
        key_data_valid  <= 1'b0;
end

//����0����ģ��
key_debounce u_key_debounce_0(
    .sys_clk        (clk        ), 
    .sys_rst_n      (rst_n      ),
    
    .key            (key[0]     ),
    .key_filter     (key_data[0])
    );

//����1����ģ��
key_debounce u_key_debounce_1(
    .sys_clk        (clk        ), 
    .sys_rst_n      (rst_n      ),
    
    .key            (key[1]     ),
    .key_filter     (key_data[1])
    );

endmodule 

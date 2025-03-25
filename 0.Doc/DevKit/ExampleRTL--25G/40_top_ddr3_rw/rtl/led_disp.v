//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           led_disp
// Created by:          ����ԭ��
// Created date:        2023��2��3��14:17:02
// Version:             V1.0
// Descriptions:        led_disp
//
//----------------------------------------------------------------------------------------
//****************************************************************************************///

module led_disp(
    input clk_50m,            //ϵͳʱ��
    input rst_n,              //ϵͳ��λ
    input error_flag,         //�����־�ź�
    input init_calib_complete,
    output reg [1:0] led     //LED �� 
);
//reg define
reg [24:0] led_cnt;          //���� LED ��˸���ڵļ�����

//*****************************************************
//**                    main code
//*****************************************************

//�������� 50MHz ʱ�Ӽ�������������Ϊ 0.5s
always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n)
        led_cnt <= 25'd0;
    else if(led_cnt < 25'd25000000)
        led_cnt <= led_cnt + 25'd1;
    else
        led_cnt <= 25'd0;
end

//���� LED �Ʋ�ͬ����ʾ״ָ̬ʾ�����־�ĸߵ�
always @(posedge clk_50m or negedge rst_n) begin
    if(rst_n == 1'b0)begin
        led[1] <= 1'b0;
        led[0] <= 1'b0;
    end
    else if(!init_calib_complete) begin
        if(led_cnt == 25'd25000000)
            led[0] <= ~led[0]; //DDR3��ʼ��ʧ��ʱ��LED[0]ÿ��0.5s��˸һ��
        else
            led[0] <= led[0];
        end 
    else if(error_flag) begin
        if(led_cnt == 25'd25000000)
            led[1] <= ~led[1]; //�����־Ϊ��ʱ��LED[1]ÿ�� 0.5s ��˸һ��
        else
            led[1] <= led[1];
        end 
    else begin
        led[0] <= 1'b1; //DDR3��ʼ���ɹ�ʱ��LED[0]����
        led[1] <= 1'b1; //�����־Ϊ��ʱ��LED[1]����
    end
end

endmodule
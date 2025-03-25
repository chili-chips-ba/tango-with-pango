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
// Created date:        2023��2��3��14:17:02
// Version:             V1.0
// Descriptions:        led_ctrl
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module led_ctrl (
    input              sys_clk   ,       //ϵͳʱ��
    input              sys_rst_n ,       //ϵͳ��λ
    input       [1:0]  state     ,       //��ͨ�Ƶ�״̬
    output reg  [5:0]  led               //�����LED�Ʒ���ʹ�� 
);
//parameter define
parameter  TWINKLE_CNT = 10_000_000;     //�Ƶ���˸��ʱ�����
//reg define
reg    [24:0]     cnt;                   //�ƵƲ�����˸Ч����ʱ�������

//*****************************************************
//**                    main code                      
//*****************************************************

//����ʱ��Ϊ0.2s�ļ������������ûƵ���˸                    
always @(posedge sys_clk or negedge sys_rst_n)begin       
    if(!sys_rst_n)                                        
        cnt <= 25'b0;                          
    else if (cnt < TWINKLE_CNT - 1'b1)               
        cnt <= cnt + 1'b1;                                
    else
        cnt <= 25'b0;
end
//�ڽ�ͨ�Ƶ��ĸ�״̬�ʹ��Ӧ��led�Ʒ���                   
always @(posedge sys_clk or negedge sys_rst_n)begin       
    if(!sys_rst_n)
        led <= 6'b100100;                                 
    else begin                                            
        case(state)                              
            2'b00:led<=6'b100010;                   //led�Ĵ����Ӹߵ��ͷֱ�������������       
                                                    //���̻Ƶƣ��ϱ�����̻Ƶ�              
            2'b01: begin                                     
                    led[5:1]<=5'b10000;                   
                    if(cnt == TWINKLE_CNT - 1'b1)   //������0.2���ûƵƵ�����״���л�һ��
                        led[0] <= ~led[0];          //������˸��Ч��                     
                    else                                
                    led[0] <= led[0];                 
            end                                       
            2'b10:led <= 6'b010100;                   
            2'b11: begin                              
                    led[5:4] <= 2'b00;                
                    led[2:0] <= 3'b100;               
                    if(cnt == TWINKLE_CNT - 1'b1)     
                        led[3] <= ~led[3];            
                    else                              
                        led[3] <= led[3];             
            end                                       
            default : led <= 6'b100100;               
        endcase                                       
    end                                               
end                                                   
endmodule                
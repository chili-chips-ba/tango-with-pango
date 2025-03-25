//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           fifo_rd
// Created by:          ����ԭ��
// Created date:        2023��10��10��14:17:02
// Version:             V1.0
// Descriptions:        FIFO��ģ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module fifo_rd(
    input               rd_clk             ,  //ʱ���ź�
    input               rst_n              ,  //��λ�ź�

    input        [8:0]  fifo_rd_data_count ,  //FIFO��ʱ��������ݼ���
    input        [7:0]  fifo_rd_data       ,  //��FIFO����������
    input               fifo_full          ,  //FIFO���ź�
    output  reg         fifo_rd_en            //FIFO��ʹ��
);

//reg define
reg       full_d0;
reg       full_d1;

//*****************************************************
//**                    main code
//*****************************************************

//��Ϊfifo_full�ź�������FIFOдʱ�����
//���Զ�fifo_full������ͬ������ʱ������
always @(posedge rd_clk or negedge rst_n) begin
    if(!rst_n) begin
        full_d0 <= 1'b0;
        full_d1 <= 1'b0;
    end
    else begin
        full_d0 <= fifo_full;
        full_d1 <= full_d0;
    end
end    
    
//��fifo_rd_en���и�ֵ,FIFOд��֮��ʼ��������֮��ֹͣ��
always @(posedge rd_clk or negedge rst_n) begin
    if(!rst_n) 
        fifo_rd_en <= 1'b0;
    else if(full_d1)
        fifo_rd_en <= 1'b1;
    else if(fifo_rd_data_count == 9'd1)
        fifo_rd_en <= 1'b0; 
    else
        fifo_rd_en <= fifo_rd_en;
end

endmodule
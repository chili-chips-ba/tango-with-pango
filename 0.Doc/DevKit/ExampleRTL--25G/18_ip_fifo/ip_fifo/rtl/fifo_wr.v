//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           fifo_wr
// Created by:          ����ԭ��
// Created date:        2023��10��10��14:17:02
// Version:             V1.0
// Descriptions:        FIFOдģ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module fifo_wr(
    input                  wr_clk             ,  // ʱ���ź�
    input                  rst_n              ,  // ��λ�ź�
    
    input          [8:0]   fifo_wr_data_count ,  //FIFOдʱ��������ݼ���
    input                  fifo_empty         ,  // FIFO���ź�
    output    reg          fifo_wr_en         ,  // FIFOдʹ��
    output    reg  [7:0]   fifo_wr_data          // д��FIFO������
);

//reg define
reg        empty_d0;
reg        empty_d1;

//*****************************************************
//**                    main code
//*****************************************************

//��Ϊfifo_empty�ź�������FIFO��ʱ�����
//���Զ�fifo_empty������ͬ����дʱ������
always @(posedge wr_clk or negedge rst_n) begin
    if(!rst_n) begin
        empty_d0 <= 1'b0;
        empty_d1 <= 1'b0;
    end
    else begin
        empty_d0 <= fifo_empty;
        empty_d1 <= empty_d0;
    end
end

//��fifo_wr_en��ֵ����FIFOΪ��ʱ��ʼд�룬д����ֹͣд
always @(posedge wr_clk or negedge rst_n) begin
    if(!rst_n) 
        fifo_wr_en <= 1'b0;
    else if(empty_d1)
        fifo_wr_en <= 1'b1;
    else if(fifo_wr_data_count == 9'd255)
        fifo_wr_en <= 1'b0;  
    else
        fifo_wr_en <= fifo_wr_en;
end  

//��fifo_wr_data��ֵ,0~255
always @(posedge wr_clk or negedge rst_n) begin
    if(!rst_n) 
        fifo_wr_data <= 8'b0;
    else if(fifo_wr_en && fifo_wr_data < 8'd255)
        fifo_wr_data <= fifo_wr_data + 8'b1;
    else
        fifo_wr_data <= 8'b0;
end

endmodule
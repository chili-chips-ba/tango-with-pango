//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ram_rw
// Created by:          ����ԭ��
// Created date:        2023��9��8��14:17:02
// Version:             V1.0
// Descriptions:        RAM��дģ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ram_rw(
    input               clk         ,  //ʱ���ź�
    input               rst_n       ,  //��λ�źţ��͵�ƽ��Ч

    output              ram_rw_en   ,  //ram��дʹ�ܣ�0��������  1��д����
    output  reg  [4:0]  ram_addr    ,  //ram��д��ַ
    output  reg  [7:0]  ram_wr_data    //ramд����  
    );

//reg define
reg  [5:0]  rw_cnt;   //��д���Ƽ�����
reg         ram_en;   //�Զ���һ��ramʹ���źţ�Ϊ��ʱ���ɽ��ж�д����

//*****************************************************
//**                    main code
//*****************************************************

//rw_cnt������Χ��0~31,д������;32~63ʱ,��������
assign ram_rw_en = ((rw_cnt <= 6'd31) && ram_en) ? 1'b1 : 1'b0;

//����RAMʹ���źţ���ֹ��λ������ĵ�һ��д������Ч
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ram_en <= 1'b0;    
    else
        ram_en <= 1'b1;    
end 

//��д���Ƽ�����,��������Χ0~63
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rw_cnt <= 6'b0;    
    else if((rw_cnt < 6'd63) && ram_en)
        rw_cnt <= rw_cnt + 6'b1;  
    else
        rw_cnt <= 6'b0;    
end  

//��д��ַ�ź� ��Χ��0~31
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ram_addr <= 5'b0;
    else if((ram_addr < 5'd31) && ram_en)
        ram_addr <= ram_addr + 5'b1;
    else    
        ram_addr <= 5'b0;
end

//����RAMд����
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ram_wr_data <= 1'b0;  
    else if((rw_cnt < 6'd31) && ram_rw_en)  //�ڼ�������0-31��Χ�ڣ�RAMд��ַ�ۼ�
        ram_wr_data <= ram_wr_data + 1'b1;
    else
        ram_wr_data <= 1'b0 ;   
end  

endmodule

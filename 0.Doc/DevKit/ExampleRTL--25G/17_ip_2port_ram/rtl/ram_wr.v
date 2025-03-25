//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ram_wr
// Created by:          ����ԭ��
// Created date:        2023��9��9��14:17:02
// Version:             V1.0
// Descriptions:        RAMдģ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ram_wr(
    input            clk         , //ʱ���ź�
    input            rst_n       , //��λ�źţ��͵�ƽ��Ч
                                    
    //RAMд�˿ڲ��� 
    output reg       ram_wr_en   , //ramдʹ��
    output reg       rd_flag     , //�������ź�
    output reg [4:0] ram_wr_addr , //ramд��ַ        
    output reg [7:0] ram_wr_data   //ramд����
);

//*****************************************************
//**                    main code
//*****************************************************

//����RAMʹ���ź�
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ram_wr_en <= 1'b0;
    else 
        ram_wr_en <= 1'b1;
end

//д��ַ�ź� ��Χ:0~31        
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)        
        ram_wr_addr <= 5'd0;
    else if((ram_wr_addr < 5'd31) && ram_wr_en)
        ram_wr_addr <= ram_wr_addr + 5'b1;
    else
        ram_wr_addr <= 5'd0;
end  

//д������д��ַ��ͬ
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)        
        ram_wr_data <= 8'd0;
    else if((ram_wr_addr < 8'd31) && ram_wr_en)
        ram_wr_data <= ram_wr_data + 8'b1;
    else
        ram_wr_data <= 8'd0;
end  

//��д��16�����ݣ�0~15�������߶������ź�
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rd_flag <= 1'b0;
    else if(ram_wr_addr == 5'd15)  
        rd_flag <= 1'b1;
    else
        rd_flag <= rd_flag;
end             

endmodule
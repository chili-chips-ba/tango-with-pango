//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ram_rd
// Created by:          ����ԭ��
// Created date:        2023��9��9��14:17:02
// Version:             V1.0
// Descriptions:        RAM��ģ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ram_rd(
    input            clk        ,   //ʱ���ź�
    input            rst_n      ,   //��λ�źţ��͵�ƽ��Ч
                                    
    //RAM���˿ڲ���                 
    input            rd_flag    ,   //��������־
    input      [7:0] ram_rd_data,   //ram������
    output           rd_rst     ,   //ram���˿ڸ�λ��ʹ�ܣ��ź�
    output reg [4:0] ram_rd_addr    //ram����ַ       
);


//*****************************************************
//**                    main code
//*****************************************************

//����RAMʹ���ź�
assign rd_rst = ~rd_flag;      

//����ַ�ź� ��Χ:0~31        
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)        
        ram_rd_addr <= 5'd0;
    else if((ram_rd_addr < 5'd31) && (!rd_rst))
        ram_rd_addr <= ram_rd_addr + 5'b1;
    else
        ram_rd_addr <= 5'd0;
end

endmodule
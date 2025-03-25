//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           picture_tailor
// Last modified Date:  2020/05/04 9:19:08
// Last Version:        V1.0
// Descriptions:        ͼƬ�ü�ģ��
//                      
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/05/04 9:19:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module picture_tailor(
    input                 gmii_rx_clk          ,  //cmos ��������ʱ��
    input                 sys_rst_n            ,  //��λ�ź�                    
    input                 picture_data_vld0    ,    
    //�û��ӿ�  
    output                picture_data_vld1    ,                           
    output   reg [10:0]  picture_data_cntx     ,
    output   reg [10:0]  picture_data_cnty         //������Чʹ���ź�         
    );
    
//*****************************************************
//**                    main code
//*****************************************************

assign picture_data_vld1 = ((160 <= picture_data_cntx) && 
    (picture_data_cntx< 640) && (104 <= picture_data_cnty) 
    && (picture_data_cnty < 376) && picture_data_vld0)?1'b1:1'b0;
    
//������ͼƬ���ص��������м���
always@ (posedge gmii_rx_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) 
        picture_data_cntx <= 11'd0;
    else if(picture_data_vld0)begin
        if(picture_data_cntx == 800 - 1'b1)
            picture_data_cntx <= 11'd0;
        else
            picture_data_cntx <= picture_data_cntx + 1'b1;           
    end
end

//������ͼƬ���ص���������м���
always@ (posedge gmii_rx_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) 
        picture_data_cnty <= 11'd0;
    else begin
        if(picture_data_cntx == 800 - 1'b1) begin
            if(picture_data_cnty ==480 - 1'b1)
                picture_data_cnty <= 11'd0;
            else
                picture_data_cnty <= picture_data_cnty + 1'b1;    
        end
    end    
end
 
endmodule
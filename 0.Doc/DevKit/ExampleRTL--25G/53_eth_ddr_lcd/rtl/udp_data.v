//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           udp_data
// Last modified Date:  2020/05/04 9:19:08
// Last Version:        V1.0
// Descriptions:        udp���ݴ���ģ��
//                      
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/05/04 9:19:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module udp_data(
    input               clk,                    //ʱ���ź�
    input               rst_n,                  //��λ�źţ��͵�ƽ��Ч
    
    input               rec_en,                 //UDP���յ�����ʹ���ź�
    input       [7:0]   rec_data,               //��̫��ͼƬ����16����
    input               picture_data_vld1,      //��̫��800x460�ü�������������Ч�ź�
    input       [15:0]  lcd_id,                 //LCD ID
    output              picture_data_vld,       //��̫��ͼƬ����������Ч�ź�
    output              picture_data_vld0,      //��̫��800x460����ͼƬ����������Ч�ź�
    output reg  [15:0]  picture_data            //��̫��ͼƬ����16����
    );
  
//reg define
reg rec_en_cnt  ;  

//wire define
wire rec_en_t   ;
//*****************************************************
//**                    main code
//*****************************************************
//�ж���Ļ�����480x272�򽫲ü�������������Ч��ֵ������������Ч�źţ����򲻲ü�
assign picture_data_vld = (lcd_id==16'h4342)? picture_data_vld1:picture_data_vld0;
//������̫��16λͼƬ����������Ч�ź�
assign rec_en_t = (rec_en & rec_en_cnt)? 1'b1:1'b0;
assign picture_data_vld0 = rec_en_t? 1'b1:1'b0;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin  
        rec_en_cnt <= 0;
    end
    else if(rec_en)
        rec_en_cnt <= rec_en_cnt + 1 ; 
    else 
        rec_en_cnt <= rec_en_cnt ;  
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin  
        picture_data <= 0;
    end
    else if(rec_en & rec_en_cnt)
        picture_data[7:0] <= rec_data ;
    else if(rec_en) 
        picture_data[15:8] <= rec_data ;
    else
        picture_data <= picture_data ;
end
    
endmodule

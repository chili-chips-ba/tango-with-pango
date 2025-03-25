//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           binarization
// Created by:          ����ԭ��
// Created date:        2023��9��12��17:52:55
// Version:             V1.0
// Descriptions:        ��ֵ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module binarization(
    //module clock
    input               clk             ,   // ʱ���ź�
    input               rst_n           ,   // ��λ�źţ�����Ч��

    //ͼ����ǰ�����ݽӿ�
    input               ycbcr_vsync     ,   // vsync�ź�
    input               ycbcr_href      ,   // href�ź�
    input               ycbcr_de        ,   // data enable�ź�
    input   [7:0]       luminance       ,

    //ͼ���������ݽӿ�
    output              post_vsync      ,   // vsync�ź�
    output              post_href       ,   // href�ź�
    output              post_de         ,   // data enable�ź�
    output   reg        monoc               // monochrome��1=�ף�0=�ڣ�
);

//reg define
reg    ycbcr_vsync_d;
reg    ycbcr_href_d ;
reg    ycbcr_de_d   ;

//*****************************************************
//**                    main code
//*****************************************************

assign  post_vsync = ycbcr_vsync_d;
assign  post_href  = ycbcr_href_d ;
assign  post_de    = ycbcr_de_d   ;

//��ֵ��
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        monoc <= 1'b0;
    else if(luminance > 8'd64)  //��ֵ
        monoc <= 1'b1;
    else
        monoc <= 1'b0;
end

//��ʱ1����ͬ��ʱ���ź�
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        ycbcr_vsync_d <= 1'd0;
        ycbcr_href_d <= 1'd0;
        ycbcr_de_d    <= 1'd0;
    end
    else begin
        ycbcr_vsync_d <= ycbcr_vsync;
        ycbcr_href_d  <= ycbcr_href ;
        ycbcr_de_d    <= ycbcr_de   ;
    end
end

endmodule 
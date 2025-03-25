//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           vip
// Created by:          ����ԭ��
// Created date:        2023��9��12��17:52:55
// Version:             V1.0
// Descriptions:        ͼ����
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module vip(
    //module clock
    input           clk               ,  // ʱ���ź�
    input           rst_n             ,  // ��λ�źţ�����Ч��

    //ͼ����ǰ�����ݽӿ�
    input           pre_frame_vsync   ,
    input           pre_frame_href    ,
    input           pre_frame_de      ,
    input    [15:0] pre_rgb           ,

    //ͼ���������ݽӿ�
    output          post_frame_vsync  ,   // ��ͬ���ź�
    output          post_frame_href  ,   // ��ͬ���ź�
    output          post_frame_de     ,   // ��������ʹ��
    output   [15:0] post_rgb              // RGB565��ɫ����

);

//wire define
wire   [ 7:0]         img_y;
wire   [ 7:0]         post_img_y;
wire                  pe_frame_vsync;
wire                  pe_frame_href;
wire                  pe_frame_clken;

//*****************************************************
//**                    main code
//*****************************************************

assign  post_rgb = {post_img_y[7:3],post_img_y[7:2],post_img_y[7:3]};

//RGBתYCbCrģ��
rgb2ycbcr u_rgb2ycbcr(
    //module clock
    .clk             (clk    ),            // ʱ���ź�
    .rst_n           (rst_n  ),            // ��λ�źţ�����Ч��
    //ͼ����ǰ�����ݽӿ�
    .pre_frame_vsync (pre_frame_vsync),    // vsync�ź�
    .pre_frame_href  (pre_frame_href ),    // href�ź�
    .pre_frame_de    (pre_frame_de   ),    // data enable�ź�
    .img_red         (pre_rgb[15:11] ),
    .img_green       (pre_rgb[10:5 ] ),
    .img_blue        (pre_rgb[ 4:0 ] ),
    //ͼ���������ݽӿ�
    .post_frame_vsync(pe_frame_vsync),     // vsync�ź�
    .post_frame_href (pe_frame_href),      // href�ź�
    .post_frame_de   (pe_frame_clken),     // data enable�ź�
    .img_y           (img_y),              //�Ҷ�����
    .img_cb          (),
    .img_cr          ()
);

//�Ҷ�ͼ��ֵ�˲�
vip_gray_median_filter u_vip_gray_median_filter(
    .clk    (clk),   
    .rst_n  (rst_n), 
    
    //����ǰͼ������
    .pre_frame_vsync (pe_frame_vsync),     // vsync�ź�
    .pre_frame_href  (pe_frame_href),      // href�ź�
    .pre_frame_clken (pe_frame_clken),     // data enable�ź�
    .pre_img_y       (img_y),
    
    //������ͼ������
    .pos_frame_vsync (post_frame_vsync),   // vsync�ź�
    .pos_frame_href  (post_frame_href),    // href�ź�
    .pos_frame_clken (post_frame_de),      // data enable�ź�
    .pos_img_y       (post_img_y)          //��ֵ�˲���ĻҶ�����
);
endmodule

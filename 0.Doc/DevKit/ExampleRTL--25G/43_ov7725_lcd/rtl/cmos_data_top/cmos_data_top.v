//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           cmos_data_top
// Created by:          ����ԭ��
// Created date:        2023��9��14��19:26:07
// Version:             V1.0
// Descriptions:        cmos_data_top
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module cmos_data_top(
    input                 rst_n            ,  //��λ�ź�
    input       [15:0]    lcd_id           ,  //LCD����ID��
    input       [10:0]    h_disp           ,  //LCD��ˮƽ�ֱ���
    input       [10:0]    v_disp           ,  //LCD����ֱ�ֱ���      
    //����ͷ�ӿ�                           
    input                 cam_pclk         ,  //cmos ��������ʱ��
    input                 cam_vsync        ,  //cmos ��ͬ���ź�
    input                 cam_href         ,  //cmos ��ͬ���ź�
    input       [7:0]     cam_data         ,                      
    //�û��ӿ� 
    output      [10:0]    h_pixel          ,  //����ddr3��ˮƽ�ֱ���
    output      [10:0]    v_pixel          ,  //����ddr3�Ĵ�ֱ�ֱ���    
    output      [27:0]    ddr3_addr_max    ,  //����DDR3������д��ַ 
    output                cmos_frame_vsync ,  //֡��Ч�ź�    
    output                cmos_frame_href  ,  //����Ч�ź�
    output                cmos_frame_valid ,  //������Чʹ���ź�
    output       [15:0]   cmos_frame_data     //��Ч����       
    );

//wire define       
wire         data_valid;         //�����ü�������ͷ���� 
wire  [15:0] wr_data;            //û�о����ü�������ͷ���� 

//*****************************************************
//**                    main code
//*****************************************************   

//����ͷ���ݲü�ģ��
cmos_tailor  u_cmos_tailor(
    .rst_n                 (rst_n),  
    .lcd_id                (lcd_id),
    .cam_pclk              (cam_pclk),
    .cam_vsync             (cmos_frame_vsync),
    .cam_href              (cmos_frame_href),
    .cam_data              (wr_data), 
    .cam_data_valid        (data_valid),
    .h_disp                (h_disp),
    .v_disp                (v_disp),  
    .h_pixel               (h_pixel),
    .v_pixel               (v_pixel), 
    .ddr3_addr_max         (ddr3_addr_max),
    .cmos_frame_valid      (cmos_frame_valid),     
    .cmos_frame_data       (cmos_frame_data)                

);

//����ͷ���ݲɼ�ģ��
cmos_capture_data u_cmos_capture_data(

    .rst_n                 (rst_n),
    .cam_pclk              (cam_pclk),   
    .cam_vsync             (cam_vsync),
    .cam_href              (cam_href),
    .cam_data              (cam_data),           
    .cmos_frame_vsync      (cmos_frame_vsync),
    .cmos_frame_href       (cmos_frame_href),
    .cmos_frame_valid      (data_valid),     
    .cmos_frame_data       (wr_data)             
    );
       
endmodule
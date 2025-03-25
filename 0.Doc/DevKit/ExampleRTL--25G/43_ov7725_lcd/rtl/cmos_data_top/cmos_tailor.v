//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           cmos_tailor
// Created by:          ����ԭ��
// Created date:        2023��9��14��19:26:07
// Version:             V1.0
// Descriptions:        cmos_tailor
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module cmos_tailor(
    input                 rst_n            ,  //��λ�ź�                    
    input       [15:0]    lcd_id           ,  //LCD����ID��
    input       [10:0]    h_disp           ,  //LCD��ˮƽ�ֱ���
    input       [10:0]    v_disp           ,  //LCD����ֱ�ֱ���  
    output reg  [10:0]    h_pixel          ,  //����ddr3��ˮƽ�ֱ���
    output reg  [10:0]    v_pixel          ,  //����ddr3������ֱ�ֱ���  
    output      [27:0]    ddr3_addr_max    ,  //����ddr3������д��ַ    
    //����ͷ�ӿ�                           
    input                 cam_pclk         ,  //cmos ��������ʱ��
    input                 cam_vsync        ,  //cmos ��ͬ���ź�
    input                 cam_href         ,  //cmos ��ͬ���ź�
    input        [15:0]   cam_data         , 
    input                 cam_data_valid   ,    
    //�û��ӿ�                              
    output                cmos_frame_valid ,  //������Чʹ���ź�
    output      [15:0]    cmos_frame_data     //��Ч����        
    );

//reg define                     
reg             cam_vsync_d0     ;
reg             cam_vsync_d1     ;
reg             cam_href_d0      ;
reg             cam_href_d1      ;
reg    [10:0]   h_cnt            ;            //���м���       
reg    [10:0]   v_cnt            ;            //�Գ�����
reg    [10:0]   h_disp_a         ;            //LCD��ˮƽ�ֱ���
reg    [10:0]   v_disp_a         ;            //LCD����ֱ�ֱ��� 
reg             data_valid_tailor;   
reg    [15:0]   wr_data_tailor   ;
reg    [15:0]   lcd_id_a         ;            //ʱ��ͬ�����LCD����ID��  

//wire define                    
wire            pos_vsync        ;            //�����볡ͬ���źŵ�������
wire            neg_hsync        ;            //��������ͬ���źŵ��½���
wire   [10:0]   cmos_h_pixel     ;            //CMOSˮƽ�������ظ���
wire   [10:0]   cmos_v_pixel     ;            //CMOS��ֱ�������ظ���							      
wire   [10:0]   cam_border_pos_l ;            //���߽�ĺ�����
wire   [10:0]   cam_border_pos_r ;            //�Ҳ�߽�ĺ�����
wire   [10:0]   cam_border_pos_t ;            //�϶˱߽��������
wire   [10:0]   cam_border_pos_b ;            //�¶˱߽��������

//*****************************************************
//**                    main code
//*****************************************************

assign cmos_frame_valid = (lcd_id_a == 16'h4342) ? data_valid_tailor : cam_data_valid ;    
assign cmos_frame_data = (lcd_id_a == 16'h4342) ? wr_data_tailor : cam_data ;

assign  ddr3_addr_max = h_pixel * v_pixel;   //����ddr3������д��ַ

assign  cmos_h_pixel = 11'd640 ;  //CMOSˮƽ�������ظ���
assign  cmos_v_pixel = 11'd480 ;  //CMOS��ֱ�������ظ��� 

//�����볡ͬ���źŵ�������
assign pos_vsync = (~cam_vsync_d1) & cam_vsync_d0; 

//��������ͬ���źŵ��½���
assign neg_hsync = (~cam_href_d0) & cam_href_d1;

//���߽�ĺ�������� 
assign cam_border_pos_l  = (cmos_h_pixel - h_disp_a)/2-1;

//�Ҳ�߽�ĺ�������� 
assign cam_border_pos_r = h_disp + (cmos_h_pixel - h_disp_a)/2-1;

//�϶˱߽����������� 
assign cam_border_pos_t  = (cmos_v_pixel - v_disp_a)/2;

//�¶˱߽�����������
assign cam_border_pos_b = v_disp_a + (cmos_v_pixel - v_disp_a)/2;

always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        cam_vsync_d0 <= 1'b0;
        cam_vsync_d1 <= 1'b0;
        cam_href_d0 <= 1'b0;
        cam_href_d1 <= 1'b0;
        lcd_id_a <= 0;
        v_disp_a <= 0;
        h_disp_a <= 0;        
    end
    else begin
        cam_vsync_d0 <= cam_vsync;
        cam_vsync_d1 <= cam_vsync_d0;
        cam_href_d0 <= cam_href;
        cam_href_d1 <= cam_href_d0;
        lcd_id_a <= lcd_id;
        v_disp_a <= v_disp;     
        h_disp_a <= h_disp;               
    end
end

//�������ddr3�ķֱ���
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        h_pixel <= 11'b0;
        v_pixel <= 11'b0;
    end
    else begin
        if(lcd_id_a == 16'h4342)begin
            h_pixel <= h_disp_a;
            v_pixel <= v_disp_a;      
      end
      else begin
          h_pixel <= cmos_h_pixel;
          v_pixel <= cmos_v_pixel;           
      end        
    end
end

//���м���
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) 
        h_cnt <= 11'b0;
    else begin
        if(pos_vsync||neg_hsync)
            h_cnt <= 11'b0;      
        else if(cam_data_valid)
            h_cnt <= h_cnt + 1'b1;           
        else if (cam_href_d0)
            h_cnt <= h_cnt; 
        else		
            h_cnt <= h_cnt; 	  
    end
end

//�Գ�����
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) 
        v_cnt <= 11'b0;
    else begin
        if(pos_vsync)
            v_cnt <= 11'b0;      
        else if(neg_hsync)
            v_cnt <= v_cnt + 1'b1;           
        else
            v_cnt <= v_cnt; 	  
    end
end

//�������������Ч�ź�(data_valid_tailor)
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        data_valid_tailor <= 1'b0;
    else if(h_cnt[10:0]>=cam_border_pos_l && h_cnt[10:0]<cam_border_pos_r&&
		    v_cnt[10:0]>=cam_border_pos_t && v_cnt[10:0]<cam_border_pos_b)
            data_valid_tailor <= cam_data_valid;
    else
            data_valid_tailor <= 1'b0;

end 

always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        wr_data_tailor <= 15'b0;
    else if(h_cnt[10:0]>=cam_border_pos_l && h_cnt[10:0]<cam_border_pos_r&&
		    v_cnt[10:0]>=cam_border_pos_t && v_cnt[10:0]<cam_border_pos_b)
            wr_data_tailor <= cam_data;
    else
            wr_data_tailor <= 15'b0;

end 
      
endmodule
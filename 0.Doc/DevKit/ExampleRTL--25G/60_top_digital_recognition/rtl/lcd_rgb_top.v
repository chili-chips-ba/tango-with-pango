//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved    
//----------------------------------------------------------------------------------------
// File name:           lcd_rgb_top
// Last modified Date:  2023/05/04 9:19:08
// Last Version:        V1.0
// Descriptions:        LCD����ģ��
//                      
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/05/04 9:19:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module lcd_rgb_top(
    input           sys_clk      ,  //ϵͳʱ��
    input           sys_rst_n,      //��λ�ź�  
    input           sys_init_done, 
    input   [23:0]  data         ,
    //lcd�ӿ�  
    output          lcd_clk,        //LCD����ʱ��    
    output          lcd_hs,         //LCD ��ͬ���ź�
    output          lcd_vs,         //LCD ��ͬ���ź�
    output          lcd_de,         //LCD ��������ʹ��
    inout  [23:0]   lcd_rgb,        //LCD RGB��ɫ����
    output          lcd_bl,         //LCD ��������ź�
    output          lcd_rst,        //LCD ��λ�ź�
    output          lcd_pclk,       //LCD ����ʱ��
    output  [15:0]  lcd_id,         //LCD��ID  
    output          out_vsync,      //lcd���ź� 
    output  [10:0]  pixel_xpos,     //���ص������
    output  [10:0]  pixel_ypos,     //���ص�������        
    output  [10:0]  h_disp,         //LCD��ˮƽ�ֱ���
    output  [10:0]  v_disp,         //LCD����ֱ�ֱ���   
    output  [15:0]  pre_rgb, 
	input   [15:0]  post_rgb,
    input           post_de,	           
    input   [15:0]  data_in,        //��������   
    output          data_req        //������������
    
    );

//parameter define
parameter  CHAR_POS_X  = 11'd1      ;       // �ַ�������ʼ�������
parameter  CHAR_POS_Y  = 11'd1      ;       // �ַ�������ʼ��������
parameter  CHAR_WIDTH  = 11'd88     ;       // �ַ�������
parameter  CHAR_HEIGHT = 11'd16     ;       // �ַ�����߶�
parameter  WHITE       = 24'hFFFFFF ;       // ����ɫ����ɫ
parameter  BLACK       = 24'h0      ;       // �ַ���ɫ����ɫ

//wire define
wire  [15:0] lcd_rgb_565;           //�����16λlcd����
wire  [15:0] colour_rgb;            //�����16λlcd����
wire  [23:0] lcd_rgb_o ;            //LCD �����ɫ����
wire  [23:0] lcd_rgb_i ;            //LCD ������ɫ����
wire  [10:0]  pixel_xpos            ;
wire  [10:0]  pixel_ypos            ;
wire  [23:0]  pixel_data            ;
wire  [15:0]  lcd_id                ;
wire  [23:0]  bcd_data              ; 
//*****************************************************
//**                    main code
//***************************************************** 
//������ͷ16bit����ת��Ϊ24bit��lcd����
assign lcd_rgb_o = {lcd_rgb_565[15:11],3'b000,lcd_rgb_565[10:5],2'b00,
                    lcd_rgb_565[4:0],3'b000};          

assign lcd_rgb_565 = post_de ? pixel_data   : 16'd0;

assign pre_rgb = lcd_de  ? colour_rgb : 16'd0;

//�������ݷ����л�
assign lcd_rgb = post_de ?  lcd_rgb_o :  {24{1'bz}};
assign lcd_rgb_i = lcd_rgb;
            
//ʱ�ӷ�Ƶģ��    
clk_div u_clk_div(
    .clk                    (sys_clk  ),
    .rst_n                  (sys_rst_n),
    .lcd_id                 (lcd_id   ),
    .lcd_pclk               (lcd_clk  )
    );  

//��LCD IDģ��
rd_id u_rd_id(
    .clk                    (sys_clk  ),
    .rst_n                  (sys_rst_n),
    .lcd_rgb                (lcd_rgb_i),
    .lcd_id                 (lcd_id   )
    );  

//lcd����ģ��
lcd_driver u_lcd_driver(           
    .lcd_clk        (lcd_clk),    
    .rst_n          (sys_rst_n & sys_init_done), 
    .lcd_id         (lcd_id),   

    .lcd_hs         (lcd_hs),       
    .lcd_vs         (lcd_vs),       
    .lcd_de         (lcd_de),       
    .lcd_rgb        (colour_rgb),
    .lcd_bl         (lcd_bl),
    .lcd_rst        (lcd_rst),
    .lcd_pclk       (lcd_pclk),
    
    .pixel_data     (data_in), 
    .data_req       (data_req),
    .out_vsync      (out_vsync),
    .h_disp         (h_disp),
    .v_disp         (v_disp), 
    .pixel_xpos     (pixel_xpos), 
    .pixel_ypos     (pixel_ypos)
    ); 
             
 //lcd��ʾģ��
lcd_display 
#(
    .CHAR_POS_X     (CHAR_POS_X  ),
    .CHAR_POS_Y     (CHAR_POS_Y  ),
    .CHAR_WIDTH     (CHAR_WIDTH  ),
    .CHAR_HEIGHT    (CHAR_HEIGHT ),
    .WHITE          (WHITE       ),
    .BLACK          (BLACK       )
)
u_lcd_display(
    .lcd_pclk       (lcd_pclk   ),
    .sys_rst_n      (sys_rst_n  ),
    .data           (data       ),
    .data_in        (post_rgb   ),
    .pixel_xpos     (pixel_xpos ),
    .pixel_ypos     (pixel_ypos ),
    .pixel_data     (pixel_data )
);   
 
endmodule 
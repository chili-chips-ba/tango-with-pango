//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           lcd_rgb_char
// Created by:          ����ԭ��
// Created date:        2023��5��24��14:17:02
// Version:             V1.0
// Descriptions:        RGB LCD����ģ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//
module  lcd_rgb_char(
    input              sys_clk  ,
    input              sys_rst_n,
    //ʱ�������
    input       [7:0]  sec      ,  // ��
    input       [7:0]  min      ,  // ��
    input       [7:0]  hour     ,  // ʱ
    input       [7:0]  day      ,  // ��
    input       [7:0]  mon      ,  // ��
    input       [7:0]  year     ,  // ��   
    
    //RGB LCD�ӿ� 
    output             lcd_hs   ,  //LCD ��ͬ���ź�
    output             lcd_vs   ,  //LCD ��ͬ���ź�
    output             lcd_de   ,  //LCD ��������ʹ��
    inout      [23:0]  lcd_rgb  ,  //LCD RGB565��ɫ����
    output             lcd_bl   ,  //LCD ��������ź�
    output             lcd_clk  ,  //LCD ����ʱ��
    output             lcd_rst     //LCD ��λ
);
    
//wire define    
wire  [15:0]  lcd_id    ;    //LCD��ID
wire          lcd_pclk  ;    //LCD����ʱ��
              
wire  [10:0]  pixel_xpos;    //��ǰ���ص������
wire  [10:0]  pixel_ypos;    //��ǰ���ص�������
wire  [10:0]  h_disp    ;    //LCD��ˮƽ�ֱ���
wire  [10:0]  v_disp    ;    //LCD����ֱ�ֱ���
wire  [23:0]  pixel_data;    //��������
wire  [23:0]  lcd_rgb_o ;    //�������������
wire  [23:0]  lcd_rgb_i ;    //�������������

//*****************************************************
//**                    main code
//*****************************************************

//�������ݷ����л�
assign lcd_rgb = lcd_de ?  lcd_rgb_o :  {24{1'bz}};
assign lcd_rgb_i = lcd_rgb;

//��LCD IDģ��
rd_id u_rd_id(
    .clk          (sys_clk  ),
    .rst_n        (sys_rst_n),
    .lcd_rgb      (lcd_rgb_i),
    .lcd_id       (lcd_id   )
    );    

//ʱ�ӷ�Ƶģ��    
clk_div u_clk_div(
    .clk          (sys_clk  ),
    .rst_n        (sys_rst_n),
    .lcd_id       (lcd_id   ),
    .lcd_pclk     (lcd_pclk )
    );    

//LCD��ʾģ��    
lcd_display u_lcd_display(
    .lcd_pclk    (lcd_pclk  ),    
    .rst_n       (sys_rst_n ),
     //ʱ�������
    .sec         (sec       ),
    .min         (min       ),
    .hour        (hour      ),
    .day         (day       ),
    .mon         (mon       ),
    .year        (year      ),
    //���ص�����
    .pixel_xpos  (pixel_xpos),
    .pixel_ypos  (pixel_ypos),
    .pixel_data  (pixel_data)
    );    

//LCD����ģ��
lcd_driver u_lcd_driver(
    .lcd_pclk      (lcd_pclk  ),
    .rst_n         (sys_rst_n ),
    
    .lcd_id        (lcd_id    ),
    .pixel_data    (pixel_data),
    .pixel_xpos    (pixel_xpos),
    .pixel_ypos    (pixel_ypos),
    .h_disp        (h_disp    ),
    .v_disp        (v_disp    ),
    .data_req      (),

    .lcd_de        (lcd_de    ),
    .lcd_hs        (lcd_hs    ),
    .lcd_vs        (lcd_vs    ),
    .lcd_bl        (lcd_bl    ),
    .lcd_clk       (lcd_clk   ),
    .lcd_rst       (lcd_rst   ),
    .lcd_rgb       (lcd_rgb_o )
    );

endmodule

//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           top_rtc_lcd
// Created by:          ����ԭ��
// Created date:        2023��5��18��14:17:02
// Version:             V1.0
// Descriptions:        RTC��ʱ����RGB LCDҺ��������ʾ
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module top_rtc_lcd(
    input                sys_clk,     //ϵͳʱ��
    input                sys_rst_n,   //ϵͳ��λ

    //RGB LCD�ӿ�
    output               lcd_de,      //LCD ����ʹ���ź�
    output               lcd_hs,      //LCD ��ͬ���ź�
    output               lcd_vs,      //LCD ��ͬ���ź�
    output               lcd_bl,      //LCD ��������ź�
    output               lcd_clk,     //LCD ����ʱ��
    output               lcd_rst,     //LCD ��λ
    inout        [23:0]  lcd_rgb,     //LCD RGB888��ɫ����
    
    //RTCʵʱʱ��
    output               iic_scl,     //RTC��ʱ����scl
    inout                iic_sda      //RTC��������sda    
    );                                                      

//parameter define
parameter    SLAVE_ADDR = 7'b101_0001          ; //������ַ(SLAVE_ADDR)
parameter    BIT_CTRL   = 1'b0                 ; //�ֵ�ַλ���Ʋ���(16b/8b)
parameter    CLK_FREQ   = 26'd50_000_000       ; //i2c_driģ�������ʱ��Ƶ��
parameter    I2C_FREQ   = 18'd250_000          ; //I2C��SCLʱ��Ƶ��
parameter    TIME_INIT  = 48'h19_01_01_09_30_00; //��ʼʱ��

//wire define
wire          dri_clk   ;   //I2C����ʱ��
wire          i2c_exec  ;   //I2C��������
wire  [15:0]  i2c_addr  ;   //I2C������ַ
wire  [ 7:0]  i2c_data_w;   //I2Cд�������
wire          i2c_done  ;   //I2C����������־
wire          i2c_ack   ;   //I2CӦ���־ 0:Ӧ�� 1:δӦ��
wire          i2c_rh_wl ;   //I2C��д����
wire  [ 7:0]  i2c_data_r;   //I2C����������

wire    [7:0]  sec      ;   //��
wire    [7:0]  min      ;   //��
wire    [7:0]  hour     ;   //ʱ
wire    [7:0]  day      ;   //��
wire    [7:0]  mon      ;   //��
wire    [7:0]  year     ;   //��

//*****************************************************
//**                    main code
//*****************************************************

//i2c����ģ��
i2c_dri #(
    .SLAVE_ADDR  (SLAVE_ADDR),  //PCF8563�ӻ���ַ
    .CLK_FREQ    (CLK_FREQ  ),  //ģ�������ʱ��Ƶ��
    .I2C_FREQ    (I2C_FREQ  )   //IIC_SCL��ʱ��Ƶ��
) u_i2c_dri(
    .clk         (sys_clk   ),  
    .rst_n       (sys_rst_n ),  
    //i2c interface
    .i2c_exec    (i2c_exec  ), 
    .bit_ctrl    (BIT_CTRL  ), 
    .i2c_rh_wl   (i2c_rh_wl ), 
    .i2c_addr    (i2c_addr  ), 
    .i2c_data_w  (i2c_data_w), 
    .i2c_data_r  (i2c_data_r), 
    .i2c_done    (i2c_done  ), 
    .i2c_ack     (i2c_ack   ), 
    .scl         (iic_scl   ), 
    .sda         (iic_sda   ), 
    //user interface
    .dri_clk     (dri_clk   )  
);

//PCF8563����ģ��
pcf8563_ctrl #(
    .TIME_INIT (TIME_INIT)
   )u_pcf8563_ctrl(
    .clk         (dri_clk   ),
    .rst_n       (sys_rst_n ),
    //IIC
    .i2c_rh_wl   (i2c_rh_wl ),
    .i2c_exec    (i2c_exec  ),
    .i2c_addr    (i2c_addr  ),
    .i2c_data_w  (i2c_data_w),
    .i2c_data_r  (i2c_data_r),
    .i2c_done    (i2c_done  ),
    //ʱ�������
    .sec         (sec       ),
    .min         (min       ),
    .hour        (hour      ),
    .day         (day       ),
    .mon         (mon       ),
    .year        (year      )
    );

//LCD�ַ���ʾģ��
lcd_rgb_char u_lcd_rgb_char(
    .sys_clk     (sys_clk   ),
    .sys_rst_n   (sys_rst_n ),
    //ʱ�������
    .sec         (sec       ),
    .min         (min       ),
    .hour        (hour      ),
    .day         (day       ),
    .mon         (mon       ),
    .year        (year      ),
    //RGB LCD�ӿ�
    .lcd_de      (lcd_de    ),
    .lcd_hs      (lcd_hs    ),
    .lcd_vs      (lcd_vs    ),
    .lcd_bl      (lcd_bl    ),
    .lcd_clk     (lcd_clk   ),
    .lcd_rst     (lcd_rst   ),
    .lcd_rgb     (lcd_rgb   )
    );

endmodule

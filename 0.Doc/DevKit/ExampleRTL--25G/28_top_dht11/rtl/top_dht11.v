//****************************************Copyright (c)***********************************//
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com 
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡFPGA & STM32���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           top_dht11
// Last modified Date:  2018��5��24��09:43:39
// Last Version:        V1.0
// Descriptions:        ��ʪ���������ʾʵ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2018��5��24��09:43:44
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
// Modified by:         ����ԭ��
// Modified date:       
// Version:             
// Descriptions:        
//
//----------------------------------------------------------------------------------------
//****************************************************************************************/

module top_dht11#(
    //parameter define
    parameter       CHAR_POS_X   = 11'd1            ,   // �ַ�������ʼ�������
    parameter       CHAR_POS_Y   = 11'd1            ,   // �ַ�������ʼ��������
    parameter       CHAR_WIDTH   = 11'd88           ,   // �ַ�������
    parameter       CHAR_HEIGHT  = 11'd16           ,   // �ַ�����߶�
    parameter       WHITE        = 24'hFFFFFF       ,   // ����ɫ����ɫ
    parameter       BLACK        = 24'h0                // �ַ���ɫ����ɫ
)(
    input            sys_clk  	 ,  		   //ϵͳʱ�� 
    input            sys_rst_n	 ,  		   //ϵͳ��λ
											   
											  
    inout            dht11    	 ,  		   //DHT11����
    input            key      	 ,  		   //����
    output           lcd_hs      ,             // LCD ��ͬ���ź�
	output           lcd_vs      ,             // LCD ��ͬ���ź�
	output           lcd_de      ,             // LCD ��������ʹ��
	inout    [23:0]  lcd_rgb     ,             // LCD RGB��ɫ����
	output           lcd_bl      ,             // LCD ��������ź�
	output           lcd_clk     ,             // LCD ����ʱ��
    output           lcd_rst     

);
//wire define
wire  [31:0]  data_valid;
wire  [19:0]  data      ;
wire  [5:0]   point     ;
wire          flag_mux  ;


//*****************************************************
//**                    main code
//*****************************************************

//dht11����ģ��
dht11_drive u_dht11_drive (
    .sys_clk        (sys_clk),
    .rst_n          (sys_rst_n),
    
    .dht11          (dht11),
    .data_valid     (data_valid)
    );


//��������ģ��
key_debounce u_key_debounce(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    
    .key            (key),
    .key_flag       (key_flag),
    .key_value      (key_value)
    );

//����������/ʪ����ʾ
dht11_key u_dht11_key(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    
    .key_flag       (key_flag),
    .key_value      (key_value),
    .data_valid     (data_valid),
    
    .data           (data),
    .sign           (sign),
    .en             (en),   
    .flag_mux       (flag_mux),                  
    .point          (point)
    );

//����LCD��ʾģ��
lcd_rgb_char 
#(
    .CHAR_POS_X     (CHAR_POS_X ),
    .CHAR_POS_Y     (CHAR_POS_Y ),
    .CHAR_WIDTH     (CHAR_WIDTH ),
    .CHAR_HEIGHT    (CHAR_HEIGHT),
    .WHITE          (WHITE      ),
    .BLACK          (BLACK      )
)
u_lcd_rgb_char(
    .sys_clk        (sys_clk    ),
    .sys_rst_n      (sys_rst_n  ),
    .data           (data       ),     
    .lcd_hs         (lcd_hs     ),          // LCD ��ͬ���ź�
    .lcd_vs         (lcd_vs     ),          // LCD ��ͬ���ź�
    .lcd_de         (lcd_de     ),          // LCD ��������ʹ��
    .lcd_rgb        (lcd_rgb    ),          // LCD RGB888��ɫ����
    .lcd_bl         (lcd_bl     ),          // LCD ��������ź�
    .lcd_clk        (lcd_clk    ),          // LCD ����ʱ��
    .lcd_rst        (lcd_rst    ),
    .flag_mux       (flag_mux   ),
    .sign           (sign       )
);
endmodule 
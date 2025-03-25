//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com 
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved                               
//----------------------------------------------------------------------------------------
// File name:           voltage_measurement
// Last modified Date:  2019/8/07 10:41:06
// Last Version:        V1.0
// Descriptions:        ��ѹ��ʵ�鶥��ģ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/8/07 10:41:06
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module top_dvm #(parameter WIDTH = 8)(
    input             sys_clk  , //ϵͳʱ��
    input             sys_rst_n, //ϵͳ��λ���͵�ƽ��Ч
    input [WIDTH-1:0] ad_data  , //AD��������
    input             ad_otr   , //ģ�������ѹ�������̱�־0:�����̷�Χ 1:��������
    output reg        ad_clk   , //AD����ʱ��,���֧��32Mhzʱ��  
    output            da_clk   , //DA����ʱ��
    output [7:0]      da_data  , //DA�������
    //RGB LCD�ӿ�              
    output            lcd_de   , //LCD ����ʹ���ź�
    output            lcd_hs   , //LCD ��ͬ���ź�
    output            lcd_vs   , //LCD ��ͬ���ź�
    output            lcd_clk  , //LCD ����ʱ��
    inout [23:0]      lcd_rgb  , //LCD ��ɫ����
    output            lcd_rst  , //LCD��λ
    output            lcd_bl     //LCD����
    );

//wire define 
wire [7:0] data_tens;  
wire [7:0] data_units; 
wire [7:0] data_decile; 
wire [7:0] data_percentiles; 
wire       data_symbol;  
wire [7:0] voc_data;
wire       voc_finish;

//*****************************************************
//**                    main code
//*****************************************************

//ʱ�ӷ�Ƶ(2��Ƶ,ʱ��Ƶ��Ϊ25Mhz),����ADʱ��
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        ad_clk <= 1'b0;
    else 
        ad_clk <= ~ad_clk; 
end    

//������ĵ�ѹ���ݽ��д���ת����ʵ�ʵ�ֵ��lcd��ʾ
voltage_data #(
	.WIDTH (WIDTH)
) 
u_voltage_data
(
    .clk              (ad_clk          ),  
    .rst_n            (sys_rst_n       ),  		     
    .ad_data          (ad_data         ),  
    .ad_otr           (ad_otr          ),  		     
    .data_tens        (data_tens       ),  
    .data_units       (data_units      ),  
    .data_decile      (data_decile     ),  
    .data_percentiles (data_percentiles),
    .data_symbol      (data_symbol     ),
	.voc_finish       (voc_finish      ), //0vУ׼��ɱ�־
    .voc_data         (voc_data        )    //У׼��0v��Ӧ��ad��ֵ
);

//0v��ѹУ׼
voltage_calibrator #(
	.WIDTH (WIDTH)
)
u_voltage_calibrator
(
	.clk              (ad_clk          ),
	.rst_n            (sys_rst_n       ),		  
	.ad_data          (ad_data         ), 
    .voc_finish       (voc_finish      ), //0vУ׼��ɱ�־
    .voc_data         (voc_data        )  //У׼��0v��Ӧ��ad��ֵ
);

//LCD�ַ���ʾģ��
lcd_disp_char u_lcd_disp_char(
    .sys_clk          (sys_clk         ),
    .sys_rst_n        (sys_rst_n       ),
    //��ʾ��ѹֵ
    .data_symbol      (data_symbol     ),//��ѹֵ����λ������ѹ���λ��ʾ���� ,��ֵ��ʾ�ո� 
    .data_percentiles (data_percentiles),//��ѹֵС�����ڶ�λ   
    .data_decile      (data_decile     ),//��ѹֵС������һλ   
    .data_units       (data_units      ),//��ѹֵ�ĸ�λ��      
    .data_tens        (data_tens       ),//��ѹֵ��ʮλ��      
    //RGB LCD�ӿ�
    .lcd_de           (lcd_de          ),
    .lcd_hs           (lcd_hs          ),
    .lcd_vs           (lcd_vs          ),
    .lcd_clk          (lcd_clk         ),
    .lcd_rgb          (lcd_rgb         ),
    .lcd_bl           (lcd_bl          ),
    .lcd_rst          (lcd_rst         )
    );      

//����DAоƬ����һ���仯�Ĳ��Ե�ѹ        
test_voltage u_test_voltage(    
    .clk              (sys_clk         ),
    .rst_n            (sys_rst_n       ),
    .da_clk           (da_clk          ),
    .da_data          (da_data         )
);    
    
endmodule


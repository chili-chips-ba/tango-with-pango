//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                               
//----------------------------------------------------------------------------------------
// File name:           voltage_measurement
// Last modified Date:  2019/8/07 10:41:06
// Last Version:        V1.0
// Descriptions:        电压表实验顶层模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/8/07 10:41:06
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module top_dvm #(parameter WIDTH = 8)(
    input             sys_clk  , //系统时钟
    input             sys_rst_n, //系统复位，低电平有效
    input [WIDTH-1:0] ad_data  , //AD输入数据
    input             ad_otr   , //模拟输入电压超出量程标志0:在量程范围 1:超出量程
    output reg        ad_clk   , //AD驱动时钟,最大支持32Mhz时钟  
    output            da_clk   , //DA驱动时钟
    output [7:0]      da_data  , //DA输出数据
    //RGB LCD接口              
    output            lcd_de   , //LCD 数据使能信号
    output            lcd_hs   , //LCD 行同步信号
    output            lcd_vs   , //LCD 场同步信号
    output            lcd_clk  , //LCD 像素时钟
    inout [23:0]      lcd_rgb  , //LCD 颜色数据
    output            lcd_rst  , //LCD复位
    output            lcd_bl     //LCD背光
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

//时钟分频(2分频,时钟频率为25Mhz),产生AD时钟
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        ad_clk <= 1'b0;
    else 
        ad_clk <= ~ad_clk; 
end    

//对输入的电压数据进行处理并转换成实际的值给lcd显示
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
	.voc_finish       (voc_finish      ), //0v校准完成标志
    .voc_data         (voc_data        )    //校准后0v对应的ad数值
);

//0v电压校准
voltage_calibrator #(
	.WIDTH (WIDTH)
)
u_voltage_calibrator
(
	.clk              (ad_clk          ),
	.rst_n            (sys_rst_n       ),		  
	.ad_data          (ad_data         ), 
    .voc_finish       (voc_finish      ), //0v校准完成标志
    .voc_data         (voc_data        )  //校准后0v对应的ad数值
);

//LCD字符显示模块
lcd_disp_char u_lcd_disp_char(
    .sys_clk          (sys_clk         ),
    .sys_rst_n        (sys_rst_n       ),
    //显示电压值
    .data_symbol      (data_symbol     ),//电压值符号位，负电压最高位显示负号 ,正值显示空格 
    .data_percentiles (data_percentiles),//电压值小数点后第二位   
    .data_decile      (data_decile     ),//电压值小数点后第一位   
    .data_units       (data_units      ),//电压值的个位数      
    .data_tens        (data_tens       ),//电压值的十位数      
    //RGB LCD接口
    .lcd_de           (lcd_de          ),
    .lcd_hs           (lcd_hs          ),
    .lcd_vs           (lcd_vs          ),
    .lcd_clk          (lcd_clk         ),
    .lcd_rgb          (lcd_rgb         ),
    .lcd_bl           (lcd_bl          ),
    .lcd_rst          (lcd_rst         )
    );      

//利用DA芯片产生一个变化的测试电压        
test_voltage u_test_voltage(    
    .clk              (sys_clk         ),
    .rst_n            (sys_rst_n       ),
    .da_clk           (da_clk          ),
    .da_data          (da_data         )
);    
    
endmodule


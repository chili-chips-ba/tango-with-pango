//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com                                                                
//技术支持：http://www.openedv.com/forum.php                                                     
//淘宝店铺：https://zhengdianyuanzi.tmall.com                                                    
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。                                     
//版权所有，盗版必究。                                                                                
//Copyright(C) 正点原子 2023-2033                                                               
//All rights reserved                                                                       
//----------------------------------------------------------------------------------------  
// File name:           and_gate                                                            
// Created by:          正点原子                                                                
// Created date:        2023年05月08日 8:41:06                                                 
// Version:             V1.0                                                                
// Descriptions:        边沿检测模块                                                               
//                                                                                          
//----------------------------------------------------------------------------------------  
//****************************************************************************************//

module edge_test(
	   input			sys_clk		,
	   input			sys_rst_n	,
	   input			a			,
	
	   output			a_posedge	,
	   output			a_negedge	,
	   output			a_edge
    );

//define reg 	
reg		a_dly;

always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
		a_dly <= 1'b0;
	else
		a_dly <= a;
end

assign	a_posedge = a & ~a_dly;		//取上升沿
assign	a_negedge = ~a & a_dly;		//取下降沿
assign	a_edge    = a ^ a_dly ;		//取双沿
	
endmodule

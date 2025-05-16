//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com                                                                
//技术支持：http://www.openedv.com/forum.php                                                     
//淘宝店铺：https://zhengdianyuanzi.tmall.com                                                    
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。                                     
//版权所有，盗版必究。                                                                                
//Copyright(C) 正点原子 2023-2033                                                               
//All rights reserved                                                                       
//----------------------------------------------------------------------------------------  
// File name:           divider_4                                                            
// Created by:          正点原子                                                                
// Created date:        2023年05月08日 8:41:06                                                 
// Version:             V1.0                                                                
// Descriptions:        4分频模块                                                               
//                                                                                          
//----------------------------------------------------------------------------------------  
//****************************************************************************************//

module divider_4(
	input			sys_clk		,			//系统时钟
	input			sys_rst_n	,           //系统复位
											
	output	reg		out_clk                 //输出时钟
);

//parameter	N = 7;							//分频系数
//parameter	EDGE = N/2-1;					//取沿数
//
reg	 [2:0]	cnt		;						//3位计数器
//reg			out_clk1;						
//reg			out_clk2;						
//
////计数器模块
//always@(posedge sys_clk or negedge sys_rst_n) begin
//	if(!sys_rst_n)
//		cnt <= 3'd0;
//	else if(cnt == N - 1'b1)
//		cnt <= 3'd0;
//	else
//		cnt <= cnt + 'd1;
//end
//
////out_clk1在上升沿进行翻转
//always@(posedge sys_clk or negedge sys_rst_n) begin
//	if(!sys_rst_n)
//		out_clk1 <= 1'b0;
//	else if(cnt <= EDGE)
//		out_clk1 <= 1'b0;
//	else
//		out_clk1 <= 1'b1;
//end		
//
////out_clk1在下降沿进行翻转
//always@(negedge sys_clk or negedge sys_rst_n) begin
//	if(!sys_rst_n)
//		out_clk2 <= 1'b0;
//	else if(cnt <= EDGE)
//		out_clk2 <= 1'b0;
//	else
//		out_clk2 <= 1'b1;
//end
//				
//assign out_clk = out_clk1 & out_clk2;
//
//endmodule

always@(posedge sys_clk or negedge sys_rst_n)
	if(!sys_rst_n)
		cnt <= 2'd0;
	else if(cnt == 2'd1)
		cnt <= 2'd0;
	else
		cnt <= cnt + 2'd1;
		
		
always@(posedge sys_clk or negedge sys_rst_n)		
	if(!sys_rst_n)
		out_clk <= 1'b0;
	else if(cnt == 2'd1)
		out_clk <= ~out_clk;
		

endmodule

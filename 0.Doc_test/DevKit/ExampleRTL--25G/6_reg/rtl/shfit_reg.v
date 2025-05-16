//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com                                                                
//技术支持：http://www.openedv.com/forum.php                                                     
//淘宝店铺：https://zhengdianyuanzi.tmall.com                                                    
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。                                     
//版权所有，盗版必究。                                                                                
//Copyright(C) 正点原子 2023-2033                                                               
//All rights reserved                                                                       
//----------------------------------------------------------------------------------------  
// File name:           shfit_reg                                                         
// Created by:          正点原子                                                                
// Created date:        2019年05月08日 8:41:06                                                 
// Version:             V1.0                                                                
// Descriptions:        移位寄存器模块                                                               
//                                                                                          
//----------------------------------------------------------------------------------------  
//****************************************************************************************//

module shfit_reg(
	input			sys_clk		,
	input			sys_rst_n	,
	input			a			,
	
	output			y
    );
	
reg		a_reg1;
reg		a_reg2;
reg		a_reg3;
reg		a_reg4;

always@(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)begin
		a_reg1 <= 1'b0;
		a_reg2 <= 1'b0;
		a_reg3 <= 1'b0;
		a_reg4 <= 1'b0;
	end
	else begin
		a_reg1 <= a;
		a_reg2 <= a_reg1;
		a_reg3 <= a_reg2;
		a_reg4 <= a_reg3;
	end
end

assign y = a_reg4;

endmodule

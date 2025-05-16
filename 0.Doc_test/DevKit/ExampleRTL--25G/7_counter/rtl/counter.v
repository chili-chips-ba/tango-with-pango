//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com                                                                
//技术支持：http://www.openedv.com/forum.php                                                     
//淘宝店铺：https://zhengdianyuanzi.tmall.com                                                    
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。                                     
//版权所有，盗版必究。                                                                                
//Copyright(C) 正点原子 2023-2033                                                               
//All rights reserved                                                                       
//----------------------------------------------------------------------------------------  
// File name:           counter                                                            
// Created by:          正点原子                                                                
// Created date:        2023年05月08日 8:41:06                                                 
// Version:             V1.0                                                                
// Descriptions:        计数器模块                                                               
//                                                                                          
//----------------------------------------------------------------------------------------  
//****************************************************************************************//

module counter(
	input				sys_clk,
	input				sys_rst_n,
	
	output	reg [2:0]	cnt
    );

always@(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)
		cnt <= 3'd0;
	else
		cnt <= cnt + 3'd1;
end

endmodule

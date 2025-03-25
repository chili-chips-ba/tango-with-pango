//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com                                                                
//技术支持：http://www.openedv.com/forum.php                                                     
//淘宝店铺：https://zhengdianyuanzi.tmall.com                                                    
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。                                     
//版权所有，盗版必究。                                                                                
//Copyright(C) 正点原子 2023-2033                                                               
//All rights reserved                                                                       
//----------------------------------------------------------------------------------------  
// File name:           decoder3_8                                                            
// Created by:          正点原子                                                                
// Created date:        2023年05月08日 8:41:06                                                 
// Version:             V1.0                                                                
// Descriptions:        38译码器模块                                                               
//                                                                                          
//----------------------------------------------------------------------------------------  
//****************************************************************************************//

module decoder3_8(
    input               A,
    input               B,
    input               C,
    
    output  reg [7:0]   out
    );
    
//define wire
wire [2:0] sel;

//使用assign语句进行位拼接
assign sel = {A, B, C};

//使用case语句
always@(*) begin
	case(sel)
		3'b000 : out = 8'b0000_0001;
		3'b001 : out = 8'b0000_0010;
		3'b010 : out = 8'b0000_0100;
		3'b011 : out = 8'b0000_1000;
		3'b100 : out = 8'b0001_0000;
		3'b101 : out = 8'b0010_0000;
		3'b110 : out = 8'b0100_0000;
		3'b111 : out = 8'b1000_0000;
		default : ;
	endcase
end

endmodule

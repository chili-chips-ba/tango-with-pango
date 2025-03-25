//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com                                                                
//技术支持：http://www.openedv.com/forum.php                                                     
//淘宝店铺：https://zhengdianyuanzi.tmall.com                                                    
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。                                     
//版权所有，盗版必究。                                                                                
//Copyright(C) 正点原子 2023-2033                                                               
//All rights reserved                                                                       
//----------------------------------------------------------------------------------------  
// File name:           latch                                                            
// Created by:          正点原子                                                                
// Created date:        2023年05月08日 8:41:06                                                 
// Version:             V1.0                                                                
// Descriptions:        latch模块                                                               
//                                                                                          
//----------------------------------------------------------------------------------------  
//****************************************************************************************//

module latch(
    input       a,
    input       b,
    
    output reg  y
    );
    
//产生latch
//always@(*) begin
//    if(a == 1)
//        y = b;
//    else
//        y = 0;
//end

//不会产生latch
always@(*) begin
	case (a)
		1: y = b;
	default : y = 0;
	endcase 
end

endmodule

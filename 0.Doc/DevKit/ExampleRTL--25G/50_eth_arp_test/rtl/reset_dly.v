//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                
//----------------------------------------------------------------------------------------
// File name:           reset_dly
// Last modified Date:  2022/7/13 9:20:14
// Last Version:        V1.0
// Descriptions:        复位模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2022/7/13 9:20:14
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module reset_dly(
	input           clk,
	input           rst_n,
	output reg      rst_n_dly
);


reg[31:0] dly_cnt;

always@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		rst_n_dly<=1'b0;
		dly_cnt<=32'd0;
    end

	else begin
    if(dly_cnt>32'hffffff)
		rst_n_dly<=1'b1;
    else 
		dly_cnt<=dly_cnt+1'b1;
    end
end    

endmodule

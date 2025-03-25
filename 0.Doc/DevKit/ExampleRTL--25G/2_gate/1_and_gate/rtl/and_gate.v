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
// Descriptions:        逻辑与模块
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module and_gate(
  input       A,  //输入A
  input       B,  //输入B
 
  output      Y   //输出Y
     );
 
 //assign相当于一条连线，输入A和输入B相与后连接输出Y。
assign  Y = A & B;
 
endmodule


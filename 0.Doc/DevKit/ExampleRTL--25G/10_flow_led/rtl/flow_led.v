//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           flow_led
// Created by:          正点原子
// Created date:        2023年2月22日14:17:02
// Version:             V1.0
// Descriptions:        流水灯实验
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module flow_led(
    input               sys_clk  ,  //系统时钟
    input               sys_rst_n,  //系统复位，低电平有效

    output  reg  [3:0]  led         //LED灯
);

//reg define
reg  [24:0]  cnt ;                  //计数器

//*****************************************************
//**                    main code
//*****************************************************

//计数器计时0.5s
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt <= 25'd0;
    else if(cnt < (25'd2500_0000 - 25'd1))
        cnt <= cnt + 25'd1;
    else
        cnt <= 25'd0;
end

//对LED灯进行移位控制，以输出4位LED的状态
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        led <= 2'b01;
    else if(cnt == (25'd2500_0000 - 25'd1))
        led <= {led[2],led[1],led[0],led[3]};
    else
        led <= led;
end

endmodule

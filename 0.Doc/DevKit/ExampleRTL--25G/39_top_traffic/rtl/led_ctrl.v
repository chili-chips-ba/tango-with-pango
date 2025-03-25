//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           led_ctrl
// Created by:          正点原子
// Created date:        2023年2月3日14:17:02
// Version:             V1.0
// Descriptions:        led_ctrl
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module led_ctrl (
    input              sys_clk   ,       //系统时钟
    input              sys_rst_n ,       //系统复位
    input       [1:0]  state     ,       //交通灯的状态
    output reg  [5:0]  led               //红黄绿LED灯发光使能 
);
//parameter define
parameter  TWINKLE_CNT = 10_000_000;     //黄灯闪烁的时间计数
//reg define
reg    [24:0]     cnt;                   //黄灯产生闪烁效果的时间计数器

//*****************************************************
//**                    main code                      
//*****************************************************

//计数时间为0.2s的计数器，用于让黄灯闪烁                    
always @(posedge sys_clk or negedge sys_rst_n)begin       
    if(!sys_rst_n)                                        
        cnt <= 25'b0;                          
    else if (cnt < TWINKLE_CNT - 1'b1)               
        cnt <= cnt + 1'b1;                                
    else
        cnt <= 25'b0;
end
//在交通灯的四个状态里，使相应的led灯发光                   
always @(posedge sys_clk or negedge sys_rst_n)begin       
    if(!sys_rst_n)
        led <= 6'b100100;                                 
    else begin                                            
        case(state)                              
            2'b00:led<=6'b100010;                   //led寄存器从高到低分别驱动：东西向       
                                                    //红绿黄灯，南北向红绿黄灯              
            2'b01: begin                                     
                    led[5:1]<=5'b10000;                   
                    if(cnt == TWINKLE_CNT - 1'b1)   //计数满0.2秒让黄灯的亮灭状况切换一次
                        led[0] <= ~led[0];          //产生闪烁的效果                     
                    else                                
                    led[0] <= led[0];                 
            end                                       
            2'b10:led <= 6'b010100;                   
            2'b11: begin                              
                    led[5:4] <= 2'b00;                
                    led[2:0] <= 3'b100;               
                    if(cnt == TWINKLE_CNT - 1'b1)     
                        led[3] <= ~led[3];            
                    else                              
                        led[3] <= led[3];             
            end                                       
            default : led <= 6'b100100;               
        endcase                                       
    end                                               
end                                                   
endmodule                
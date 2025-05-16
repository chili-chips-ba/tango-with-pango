//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           rw_result_led
// Created by:          正点原子
// Created date:        2023年5月17日14:17:02
// Version:             V1.0
// Descriptions:        LED0灯常亮表示读写测试正确，LED0闪烁表示读写测试错误
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module rw_result_led 
    #(parameter L_TIME = 17'd125_000
    )
    (
    input        clk       ,  //时钟信号
    input        rst_n     ,  //复位信号
                 
    input        rw_done   ,  //错误标志
    input        rw_result ,  //E2PROM读写测试完成
    output  reg  led          //E2PROM读写测试结果 0:失败 1:成功
);

//reg define
reg          rw_done_flag;    //读写测试完成标志
reg  [16:0]  led_cnt     ;    //led计数

//*****************************************************
//**                    main code
//*****************************************************

//读写测试完成标志
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rw_done_flag <= 1'b0;
    else if(rw_done)
        rw_done_flag <= 1'b1;
end        

//错误标志为1时LED0闪烁，否则LED0常亮
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        led_cnt <= 17'd0;
        led <= 1'b0;
    end
    else begin
        if(rw_done_flag) begin
            if(rw_result)                          //读写测试正确
                led <= 1'b1;                       //led灯常亮
            else begin                             //读写测试错误
                led_cnt <= led_cnt + 17'd1;
                if(led_cnt == (L_TIME - 17'b1)) begin
                    led_cnt <= 17'd0;
                    led <= ~led;                   //led灯闪烁
                end
                else
                    led <= led;
            end
        end
        else
            led <= 1'b0;                           //读写测试完成之前,led灯熄灭
    end    
end

endmodule

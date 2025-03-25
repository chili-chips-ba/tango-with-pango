//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           key_debounce
// Created by:          正点原子
// Created date:        2023年2月16日14:20:02
// Version:             V1.0
// Descriptions:        按键消抖模块
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module key_debounce(
    input        sys_clk   ,
    input        sys_rst_n ,

    input        key       ,   //外部输入的按键值
    output  reg  key_filter    //按键消抖后的值
);

//parameter define
parameter  CNT_MAX = 20'd100_0000;    //消抖时间20ms

//reg define
reg [19:0] cnt ;
reg        key_d0;            //将按键信号延迟一个时钟周期
reg        key_d1;            //将按键信号延迟两个时钟周期

//*****************************************************
//**                    main code
//*****************************************************

//对按键端口的数据延迟两个时钟周期
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        key_d0 <= 1'b1;
        key_d1 <= 1'b1;
    end
    else begin
        key_d0 <= key;
        key_d1 <= key_d0;
    end 
end

//按键值消抖
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) 
        cnt <= 20'd0;
    else begin
        if(key_d1 != key_d0)    //检测到按键状态发生变化
            cnt <= CNT_MAX;     //则将计数器置为20'd100_0000，
                                //即延时100_0000 * 20ns(1s/50MHz) = 20ms
        else begin              //如果当前按键值和前一个按键值一样，即按键没有发生变化
            if(cnt > 20'd0)     //则计数器递减到0
                cnt <= cnt - 1'b1;  
            else
                cnt <= 20'd0;
        end
    end
end

//将消抖后的最终的按键值送出去
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        key_filter <= 1'b1;
	//在计数器递减到1时送出按键值
    else if(cnt == 20'd1) 
		key_filter <= key_d1;
    else
		key_filter <= key_filter;
end

endmodule


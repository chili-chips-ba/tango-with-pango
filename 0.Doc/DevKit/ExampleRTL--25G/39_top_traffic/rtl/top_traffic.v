//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           top_traffic
// Created by:          正点原子
// Created date:        2023年2月3日14:17:02
// Version:             V1.0
// Descriptions:        top_traffic
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module top_traffic( 
    input                  sys_clk   ,    //系统时钟信号
    input                  sys_rst_n ,    //系统复位信号
    output       [3:0]     sel       ,    //数码管位选信号
    output       [7:0]     seg_led   ,    //数码管段选信号
    output       [5:0]     led            //LED使能信号,红绿黄灯
);
//paramater difine
parameter  TWINKLE_CNT   = 10000000;      //黄灯闪烁的时间计数
parameter  TIME_LED_Y    = 3;             //黄灯发光的时间
parameter  TIME_LED_R    = 30;            //红灯发光的时间
parameter  TIME_LED_G    = 27;            //绿灯发光的时间
parameter  WIDTH_CNT     = 25000000;      //产生频率为1hz的时钟
parameter  WIDTH         = 50000;         //计数1ms的计数深度
//wire define    
wire   [5:0]    ew_time;                    //东西方向状态剩余时间数据
wire   [5:0]    sn_time;                    //南北方向状态剩余时间数据 
wire   [1:0]    state  ;                    //交通灯的状态，用于控制LED灯的点亮
wire   [7:0]    ew_bcd_time;
wire   [7:0]    sn_bcd_time;

//*****************************************************
//**                    main code                      
//*****************************************************

//交通灯控制模块    
traffic_light_ctrl 
#(
    .TIME_LED_Y     (TIME_LED_Y ),
    .TIME_LED_R     (TIME_LED_R ),
    .TIME_LED_G     (TIME_LED_G ),
    .WIDTH_CNT      (WIDTH_CNT  )
)
u_traffic_light_ctrl(
    .sys_clk        (sys_clk   ),
    .sys_rst_n      (sys_rst_n ),
    .state          (state     ),
    .ew_time        (ew_time   ),
    .sn_time        (sn_time   )
);

//二进制转BCD
binary2bcd u_binary2bcd_ew(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .data           (ew_time),
    
    .bcd_data       (ew_bcd_time)
    
);

//二进制转BCD
binary2bcd u_binary2bcd_sn(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .data           (sn_time),
    
    .bcd_data       (sn_bcd_time)
    
);

//数码管显示模块   
seg_led 
#(
    .WIDTH (WIDTH )
)
u_seg_led(
    .sys_clk        (sys_clk   ),
    .sys_rst_n      (sys_rst_n ),
    .ew_time        (ew_bcd_time),
    .sn_time        (sn_bcd_time),
    .sel            (sel       ),
    .seg_led        (seg_led   )
);

//led灯控制模块
led_ctrl 
#(
    .TWINKLE_CNT (TWINKLE_CNT )
)
u_led_ctrl(
    .sys_clk       (sys_clk   ),
    .sys_rst_n     (sys_rst_n ),
    .state         (state     ),
    .led           (led       )
);

endmodule        
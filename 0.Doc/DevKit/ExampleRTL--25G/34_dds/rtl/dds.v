//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           dds
// Created by:          正点原子
// Created date:        2023年5月31日14:17:02
// Version:             V1.0
// Descriptions:        DDS顶层模块
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module dds(
    input                 sys_clk     ,  //系统时钟
    input                 sys_rst_n   ,  //系统复位，低电平有效
    input                 key_wave    ,  //波形控制按键
    input                 key_freq    ,  //频率控制按键
    //DA芯片接口
    output                da_clk      ,  //DAC驱动时钟
    output    [7:0]       da_data     ,  //输出给DA的数据
    //AD芯片接口
    input     [7:0]       ad_data     /* synthesis PAP_MARK_DEBUG="true" */,  //AD输入数据
    //模拟输入电压超出量程标志(本次试验未用到)
    input                 ad_otr      /* synthesis PAP_MARK_DEBUG="true" */,  //0:在量程范围 1:超出量程
    output                ad_clk        //ADC驱动时钟
);

//parameter define
parameter  CNT_MAX = 20'd200_0000;      //100MHz时钟下计数20ms

//wire define 
wire             rst_n          ;  // 复位，低有效
wire             pll_lock       ;  //PLL时钟锁定信号
wire             clk_100m       ;  //100MHz时钟
wire             clk_25m/* synthesis PAP_MARK_DEBUG="<0/c0/0>" */;  //25MHz时钟
wire    [8:0]    rd_addr        ;  //ROM读地址
wire    [7:0]    rd_data        ;  //ROM读出的数据
wire             key_wave_filter;  //波形控制按键消抖后的按键值
wire             key_freq_filter;  //频率控制按键消抖后的按键值

//*****************************************************
//**                    main code
//*****************************************************

//通过系统复位信号和PLL时钟锁定信号来产生一个新的复位信号
assign   rst_n = sys_rst_n & pll_lock;
assign   ad_clk = clk_25m;

//PLL IP核
pll_clk u_pll_clk (
  .clkin1         (sys_clk),        
  .pll_lock       (pll_lock),   
  .clkout0        (clk_100m),    
  .clkout1        (clk_25m)       
);

//ROM存储波形
rom_400x8b u_rom_400x8b(
  .addr           (rd_addr),       
  .clk            (clk_100m),          
  .rst            (~rst_n),      
  .rd_data        (rd_data) 
);

//例化按键消抖模块
key_debounce #(
    .CNT_MAX     (CNT_MAX        ))
u_key_wave_debounce(
    .sys_clk     (clk_100m       ),
    .sys_rst_n   (rst_n          ),
    .key         (key_wave       ),
    .key_filter  (key_wave_filter)
    );
    
//例化按键消抖模块
key_debounce #(
    .CNT_MAX     (CNT_MAX        ))
u_key_freq_debounce(
    .sys_clk     (clk_100m       ),
    .sys_rst_n   (rst_n          ),
    .key         (key_freq       ),
    .key_filter  (key_freq_filter)
    );

//DA数据发送
da_wave_send u_da_wave_send(
    .clk              (clk_100m       ),
    .rst_n            (rst_n          ),
    .key_wave_filter  (key_wave_filter),
    .key_freq_filter  (key_freq_filter),
    .rd_data          (rd_data        ),
    .rd_addr          (rd_addr        ),
    .da_clk           (da_clk         ),
    .da_data          (da_data        )
    );

endmodule
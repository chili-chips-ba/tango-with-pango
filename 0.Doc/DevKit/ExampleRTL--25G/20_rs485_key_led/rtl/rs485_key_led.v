//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           rs485_key_led
// Created by:          正点原子
// Created date:        2023年5月31日14:17:02
// Version:             V1.0
// Descriptions:        一块开发板上的按键信息通过RS485接口传递给另一块开发板，并控制另一块开发板上的led灯
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module rs485_key_led(
    input           sys_clk       ,    //外部50M时钟
    input           sys_rst_n     ,    //外部复位信号，低有效
    
    input  [1:0]    key           ,    //按键
    output [1:0]    led           ,    //led灯
    
    //uart接口
    input           rs485_uart_rxd,    //rs485串口接收端口
    output          rs485_uart_txd     //rs485串口发送端口
    );
    
//parameter define
parameter  CLK_FREQ = 50000000;    //定义系统时钟频率
parameter  UART_BPS = 115200  ;    //定义串口波特率
    
//wire define   
wire       uart_tx_en    ;    //UART发送使能
wire       uart_rx_done  ;    //UART接收完毕信号
wire [7:0] uart_tx_data  ;    //UART发送数据
wire [7:0] uart_rx_data  ;    //UART接收数据
wire [1:0] key_data      ;    //按键数据  

//*****************************************************
//**                    main code
//*****************************************************   

//将2位按键数据编码为8位的串口数据
assign   uart_tx_data = {6'b0 , key_data};

//串口接收模块
uart_rx #(
    .CLK_FREQ       (CLK_FREQ),        //设置系统时钟频率
    .UART_BPS       (UART_BPS))        //设置串口接收波特率
u_uart_rx(                 
    .clk            (sys_clk       ), 
    .rst_n          (sys_rst_n     ),
    
    .uart_rxd       (rs485_uart_rxd),
    .uart_rx_done   (uart_rx_done  ),
    .uart_rx_data   (uart_rx_data  )
    );

//led控制模块   
led_ctrl u_led_ctrl(
    .clk            (sys_clk          ),
    .rst_n          (sys_rst_n        ),

    .led_en         (uart_rx_done     ),  //led控制使能
    .led_data       (uart_rx_data[1:0]),  //led控制数据
    .led            (led              )
);

//按键触发模块
key_trig u_key_trig(
    .clk            (sys_clk    ), 
    .rst_n          (sys_rst_n  ),
    
    .key            (key        ),
    .key_data_valid (uart_tx_en ),     //按键有效通知信号
    .key_data       (key_data   )      //按键数据
    );

//串口发送模块   
uart_tx #(
    .CLK_FREQ       (CLK_FREQ),        //设置系统时钟频率
    .UART_BPS       (UART_BPS))        //设置串口发送波特率
u_uart_tx(                 
    .clk            (sys_clk       ),
    .rst_n          (sys_rst_n     ),
     
    .uart_tx_en     (uart_tx_en    ),
    .uart_tx_data   (uart_tx_data  ),
    .uart_txd       (rs485_uart_txd)
    );

endmodule 
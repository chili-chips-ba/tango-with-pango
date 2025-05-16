//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           eth_arp_test
// Last modified Date:  2022/7/13 9:20:14
// Last Version:        V1.0
// Descriptions:        以太网ARP测试实验
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2022/7/13 9:20:14
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module eth_arp_test(
    input              sys_clk   , //系统时钟
    input              sys_rst_n , //系统复位信号，低电平有效 
    input              touch_key , //触摸按键,用于触发开发板发出ARP请求

    //PL以太网RGMII接口   
    input              eth_rxc   , //RGMII接收数据时钟
    input              eth_rx_ctl, //RGMII输入数据有效信号
    input       [3:0]  eth_rxd   , //RGMII输入数据
    output             eth_txc   , //RGMII发送数据时钟    
    output             eth_tx_ctl, //RGMII输出数据有效信号
    output      [3:0]  eth_txd   , //RGMII输出数据          
    output             eth_rst_n   //以太网芯片复位信号，低电平有效   
    );

//parameter define
//开发板MAC地址 00-11-22-33-44-55
parameter  BOARD_MAC = 48'h00_11_22_33_44_55;
//开发板IP地址 192.168.1.10     
parameter  BOARD_IP  = {8'd192,8'd168,8'd1,8'd10};
//目的MAC地址 ff_ff_ff_ff_ff_ff
parameter  DES_MAC   = 48'hff_ff_ff_ff_ff_ff;
//目的IP地址 192.168.1.102
parameter  DES_IP    = {8'd192,8'd168,8'd1,8'd102};

//wire define
wire  [7:0]   gmii_txd    ; //GMII发送数据
wire          gmii_tx_en  ; //GMII发送数据使能信号
wire          gmii_tx_clk ; //GMII发送时钟
wire  [7:0]   gmii_rxd    ; //GMII接收数据 
wire          gmii_rx_dv  ; //GMII接收数据有效信号
wire          gmii_rx_clk ; //GMII接收时钟

wire          arp_rx_done ; //ARP接收完成信号
wire          arp_rx_type ; //ARP接收类型 0:请求  1:应答
wire  [47:0]  src_mac     ; //接收到目的MAC地址
wire  [31:0]  src_ip      ; //接收到目的IP地址    
wire          arp_tx_en   ; //ARP发送使能信号
wire          arp_tx_type ; //ARP发送类型 0:请求  1:应答
wire          tx_done     ; //ARP发送完成信号 
wire  [47:0]  des_mac     ; //发送的目标IP地址
wire  [31:0]  des_ip      ; //以太网发送完成信号
//*****************************************************
//**                    main code
//*****************************************************
assign des_mac = src_mac;
assign des_ip = src_ip;



//输出网口复位信号
reset_dly delay_u0(
    .clk           (sys_clk  ),
    .rst_n         (sys_rst_n),
    .rst_n_dly     (eth_rst_n)
);

gmii_to_rgmii u_gmii_to_rgmii(
	.rgmii_txd              (eth_txd   ),
	.rgmii_tx_ctl           (eth_tx_ctl),
	.rgmii_txc              (eth_txc   ),
	.rgmii_rxd              (eth_rxd   ),
	.rgmii_rx_ctl           (eth_rx_ctl),
    .rgmii_rxc              (eth_rxc   ),

	.gmii_rx_clk            (gmii_rx_clk),
	.gmii_txd               (gmii_txd   ),
	.gmii_tx_en             (gmii_tx_en ),
	.gmii_tx_clk            (gmii_tx_clk),
	.gmii_rxd               (gmii_rxd   ),
	.gmii_rx_dv             (gmii_rx_dv )
	);

//ARP通信
arp                                             
   #(
    .BOARD_MAC     (BOARD_MAC),      //参数例化
    .BOARD_IP      (BOARD_IP ),
    .DES_MAC       (DES_MAC  ),
    .DES_IP        (DES_IP   )
    )
   u_arp(
    .rst_n         (sys_rst_n  ),
                    
    .gmii_rx_clk   (gmii_rx_clk),
    .gmii_rx_dv    (gmii_rx_dv ),
    .gmii_rxd      (gmii_rxd   ),
    .gmii_tx_clk   (gmii_tx_clk),
    .gmii_tx_en    (gmii_tx_en ),
    .gmii_txd      (gmii_txd   ),
                    
    .arp_rx_done   (arp_rx_done),
    .arp_rx_type   (arp_rx_type),
    .src_mac       (src_mac    ),
    .src_ip        (src_ip     ),
    .arp_tx_en     (arp_tx_en  ),
    .arp_tx_type   (arp_tx_type),
    .des_mac       (des_mac    ),
    .des_ip        (des_ip     ),
    .tx_done       (tx_done    )
    );

//ARP控制
arp_ctrl u_arp_ctrl(
    .clk           (gmii_rx_clk),
    .rst_n         (sys_rst_n  ),
 
    .touch_key     (touch_key  ),
    .arp_rx_done   (arp_rx_done),
    .arp_rx_type   (arp_rx_type),
    .arp_tx_en     (arp_tx_en  ),
    .arp_tx_type   (arp_tx_type)
    );

endmodule
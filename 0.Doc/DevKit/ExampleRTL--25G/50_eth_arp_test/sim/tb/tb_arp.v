//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           tb_arp
// Last modified Date:  2021/2/19 17:54:24
// Last Version:        V1.0
// Descriptions:        
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2021/2/19 17:54:24
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

`timescale  1ns/1ns                     //定义仿真时间单位1ns和仿真时间精度为1ns

module  tb_arp;

//parameter  define
parameter  T = 8;                       //时钟周期为8ns
parameter  OP_CYCLE = 100;              //操作周期

//开发板MAC地址 00-11-22-33-44-55
parameter  BOARD_MAC = 48'h00_11_22_33_44_55;     
//开发板IP地址 192.168.1.10     
parameter  BOARD_IP  = {8'd192,8'd168,8'd1,8'd10};
//目的MAC地址 ff_ff_ff_ff_ff_ff
parameter  DES_MAC   = 48'hff_ff_ff_ff_ff_ff;
//目的IP地址 192.168.1.10
parameter  DES_IP    = {8'd192,8'd168,8'd1,8'd10};

//reg define
reg           gmii_clk;    //时钟信号
reg           sys_rst_n;   //复位信号

reg           arp_tx_en  ; //ARP发送使能信号
reg           arp_tx_type; //ARP发送类型 0:请求  1:应答
reg   [3:0]   flow_cnt   ;
reg   [13:0]  delay_cnt  ;

wire          gmii_rx_clk; //GMII接收时钟
wire          gmii_rx_dv ; //GMII接收数据有效信号
wire  [7:0]   gmii_rxd   ; //GMII接收数据
wire          gmii_tx_clk; //GMII发送时钟
wire          gmii_tx_en ; //GMII发送数据使能信号
wire  [7:0]   gmii_txd   ; //GMII发送数据
              
wire          arp_rx_done; //ARP接收完成信号
wire          arp_rx_type; //ARP接收类型 0:请求  1:应答
wire  [47:0]  src_mac    ; //接收到目的MAC地址
wire  [31:0]  src_ip     ; //接收到目的IP地址    
wire  [47:0]  des_mac    ; //发送的目标MAC地址
wire  [31:0]  des_ip     ; //发送的目标IP地址
wire          tx_done    ; //以太网发送完成信号 

//*****************************************************
//**                    main code
//*****************************************************

assign gmii_rx_clk = gmii_clk   ;
assign gmii_tx_clk = gmii_clk   ;
assign gmii_rx_dv  = gmii_tx_en ;
assign gmii_rxd    = gmii_txd   ;

assign des_mac = src_mac;
assign des_ip  = src_ip;

//给输入信号初始值
initial begin
    gmii_clk           = 1'b0;
    sys_rst_n          = 1'b0;     //复位
    #(T+1)  sys_rst_n  = 1'b1;     //在第(T+1)ns的时候复位信号信号拉高
end

//125Mhz的时钟，周期则为1/125Mhz=8ns,所以每4ns，电平取反一次
always #(T/2) gmii_clk = ~gmii_clk;

always @(posedge gmii_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        arp_tx_en <= 1'b0;
        arp_tx_type <= 1'b0;
        delay_cnt <= 1'b0;
        flow_cnt <= 1'b0;
    end
    else begin
        case(flow_cnt)
            'd0 : flow_cnt <= flow_cnt + 1'b1;
            'd1 : begin
                arp_tx_en <= 1'b1;
                arp_tx_type <= 1'b0;  //发送ARP请求
                flow_cnt <= flow_cnt + 1'b1;
            end
            'd2 : begin 
                arp_tx_en <= 1'b0;
                flow_cnt <= flow_cnt + 1'b1;
            end    
            'd3 : begin
                if(tx_done)
                    flow_cnt <= flow_cnt + 1'b1;
            end
            'd4 : begin
                delay_cnt <= delay_cnt + 1'b1;
                if(delay_cnt == OP_CYCLE - 1'b1)
                    flow_cnt <= flow_cnt + 1'b1;
            end
            'd5 : begin
                arp_tx_en <= 1'b1;
                arp_tx_type <= 1'b1;  //发送ARP应答   
                flow_cnt <= flow_cnt + 1'b1;                
            end
            'd6 : begin 
                arp_tx_en <= 1'b0;
                flow_cnt <= flow_cnt + 1'b1;
            end 
            'd7 : begin
                if(tx_done)
                    flow_cnt <= flow_cnt + 1'b1;
            end
            default:;
        endcase    
    end
end

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

endmodule

//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           tb_udp
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

module  tb_udp;

//parameter  define
parameter  T = 8;                       //时钟周期为8ns
parameter  OP_CYCLE = 100;              //操作周期(发送周期间隔)

//开发板MAC地址 00-11-22-33-44-55
parameter  BOARD_MAC = 48'h00_11_22_33_44_55;     
//开发板IP地址 192.168.1.10     
parameter  BOARD_IP  = {8'd192,8'd168,8'd1,8'd10};
//目的MAC地址 ff_ff_ff_ff_ff_ff
parameter  DES_MAC   = 48'hff_ff_ff_ff_ff_ff;
//目的IP地址 192.168.1.102
parameter  DES_IP    = {8'd192,8'd168,8'd1,8'd10};

//reg define
reg           gmii_clk;    //时钟信号
reg           sys_rst_n;   //复位信号

reg           tx_start_en;
reg   [7:0]   tx_data    ;
reg   [15:0]  tx_byte_num;
reg   [47:0]  des_mac    ;
reg   [31:0]  des_ip     ;

reg   [3:0]   flow_cnt   ;
reg   [13:0]  delay_cnt  ;

wire          gmii_rx_clk; //GMII接收时钟
wire          gmii_rx_dv ; //GMII接收数据有效信号
wire  [7:0]   gmii_rxd   ; //GMII接收数据
wire          gmii_tx_clk; //GMII发送时钟
wire          gmii_tx_en ; //GMII发送数据使能信号
wire  [7:0]   gmii_txd   ; //GMII发送数据
              
wire          tx_done    ; 
wire          tx_req     ;

//*****************************************************
//**                    main code
//*****************************************************

assign gmii_rx_clk = gmii_clk   ;
assign gmii_tx_clk = gmii_clk   ;
assign gmii_rx_dv  = gmii_tx_en ;
assign gmii_rxd    = gmii_txd   ;

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
        tx_start_en <= 1'b0;
        tx_data <= 8'h33;
        tx_byte_num <= 1'b0;
        des_mac <= 1'b0;
        des_ip <= 1'b0;
        delay_cnt <= 1'b0;
        flow_cnt <= 1'b0;
    end
    else begin
        case(flow_cnt)
            'd0 : flow_cnt <= flow_cnt + 1'b1;
            'd1 : begin
                tx_start_en <= 1'b1;  //拉高开始发送使能信号
                tx_byte_num <= 16'd10;//设置发送的字节数
                flow_cnt <= flow_cnt + 1'b1;
            end
            'd2 : begin 
                tx_start_en <= 1'b0;
                flow_cnt <= flow_cnt + 1'b1;
            end    
            'd3 : begin
                if(tx_req)
                    tx_data <= tx_data + 8'h11;
                if(tx_done) begin
                    flow_cnt <= flow_cnt + 1'b1;
                    tx_data <= 8'h33;
                end    
            end
            'd4 : begin
                delay_cnt <= delay_cnt + 1'b1;
                if(delay_cnt == OP_CYCLE - 1'b1)
                    flow_cnt <= flow_cnt + 1'b1;
            end
            'd5 : begin
                tx_start_en <= 1'b1;  //拉高开始发送使能信号
                tx_byte_num <= 16'd30;//设置发送的字节数
                flow_cnt <= flow_cnt + 1'b1;               
            end
            'd6 : begin 
                tx_start_en <= 1'b0;
                flow_cnt <= flow_cnt + 1'b1;
            end 
            'd7 : begin
                if(tx_req)
                    tx_data <= tx_data + 8'h11;
                if(tx_done) begin
                    flow_cnt <= flow_cnt + 1'b1;
                    tx_data <= 8'h33;
                end  
            end
            default:;
        endcase    
    end
end

//例化UDP模块
udp                                             
   #(
    .BOARD_MAC     (BOARD_MAC),      //参数例化
    .BOARD_IP      (BOARD_IP ),
    .DES_MAC       (DES_MAC  ),
    .DES_IP        (DES_IP   )
    )
   u_udp(
    .rst_n         (sys_rst_n   ),  
    
    .gmii_rx_clk   (gmii_rx_clk ),           
    .gmii_rx_dv    (gmii_rx_dv  ),         
    .gmii_rxd      (gmii_rxd    ),                   
    .gmii_tx_clk   (gmii_tx_clk ), 
    .gmii_tx_en    (gmii_tx_en),         
    .gmii_txd      (gmii_txd),  

    .rec_pkt_done  (),    
    .rec_en        (),     
    .rec_data      (),         
    .rec_byte_num  (),      
    .tx_start_en   (tx_start_en),        
    .tx_data       (tx_data    ),         
    .tx_byte_num   (tx_byte_num),  
    .des_mac       (des_mac    ),
    .des_ip        (des_ip     ),    
    .tx_done       (tx_done    ),        
    .tx_req        (tx_req)           
    ); 

endmodule
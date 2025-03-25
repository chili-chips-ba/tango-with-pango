//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com 
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           eth_ctrl
// Last modified Date:  2020/2/18 9:20:14
// Last Version:        V1.0
// Descriptions:        ��̫������ģ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2020/2/18 9:20:14
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module eth_ctrl(
    input              clk       ,      //ʱ��
    input              rst_n     ,      //ϵͳ��λ�źţ��͵�ƽ��Ч 
    //ARP��ض˿��ź�                                    
    input              arp_rx_done,     //ARP��������ź�
    input              arp_rx_type,     //ARP�������� 0:����  1:Ӧ��
    output  reg        arp_tx_en,       //ARP����ʹ���ź�
    output             arp_tx_type,     //ARP�������� 0:����  1:Ӧ��
    input              arp_tx_done,     //ARP��������ź�
    input              arp_gmii_tx_en,  //ARP GMII���������Ч�ź� 
    input     [7:0]    arp_gmii_txd,    //ARP GMII�������
    //ICMP��ض˿��ź�
    input              icmp_tx_start_en,//ICMP��ʼ�����ź�
    input              icmp_tx_done,    //ICMP��������ź�
    input              icmp_gmii_tx_en, //ICMP GMII���������Ч�ź�  
    input     [7:0]    icmp_gmii_txd,   //ICMP GMII�������   
    //GMII��������                     
    output             gmii_tx_en,      //GMII���������Ч�ź� 
    output    [7:0]    gmii_txd         //GMII������� 
    );

//reg define
reg        protocol_sw; //Э���л��ź�
reg        icmp_tx_busy; //ICMP���ڷ������ݱ�־�ź�
reg        arp_rx_flag; //���յ�ARP�����źŵı�־

//*****************************************************
//**                    main code
//*****************************************************

assign arp_tx_type = 1'b1;   //ARP�������͹̶�ΪARPӦ��                                   
assign gmii_tx_en = protocol_sw ? icmp_gmii_tx_en : arp_gmii_tx_en;
assign gmii_txd = protocol_sw ? icmp_gmii_txd : arp_gmii_txd;

//����ICMP����æ�ź�
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        icmp_tx_busy <= 1'b0;
    else if(icmp_tx_start_en)   
        icmp_tx_busy <= 1'b1;
    else if(icmp_tx_done)
        icmp_tx_busy <= 1'b0;
end

//���ƽ��յ�ARP�����źŵı�־
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        arp_rx_flag <= 1'b0;
    else if(arp_rx_done && (arp_rx_type == 1'b0))   
        arp_rx_flag <= 1'b1;
    else 
        arp_rx_flag <= 1'b0;
end

//����protocol_sw��arp_tx_en�ź�
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        protocol_sw <= 1'b0;
        arp_tx_en <= 1'b0;
    end
    else begin
        arp_tx_en <= 1'b0;
        if(icmp_tx_start_en)
            protocol_sw <= 1'b1;
        else if(arp_rx_flag && (icmp_tx_busy == 1'b0)) begin
            protocol_sw <= 1'b0;
            arp_tx_en <= 1'b1;
        end    
    end        
end

endmodule
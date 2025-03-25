//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           rs485_key_led
// Created by:          ����ԭ��
// Created date:        2023��5��31��14:17:02
// Version:             V1.0
// Descriptions:        һ�鿪�����ϵİ�����Ϣͨ��RS485�ӿڴ��ݸ���һ�鿪���壬��������һ�鿪�����ϵ�led��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module rs485_key_led(
    input           sys_clk       ,    //�ⲿ50Mʱ��
    input           sys_rst_n     ,    //�ⲿ��λ�źţ�����Ч
    
    input  [1:0]    key           ,    //����
    output [1:0]    led           ,    //led��
    
    //uart�ӿ�
    input           rs485_uart_rxd,    //rs485���ڽ��ն˿�
    output          rs485_uart_txd     //rs485���ڷ��Ͷ˿�
    );
    
//parameter define
parameter  CLK_FREQ = 50000000;    //����ϵͳʱ��Ƶ��
parameter  UART_BPS = 115200  ;    //���崮�ڲ�����
    
//wire define   
wire       uart_tx_en    ;    //UART����ʹ��
wire       uart_rx_done  ;    //UART��������ź�
wire [7:0] uart_tx_data  ;    //UART��������
wire [7:0] uart_rx_data  ;    //UART��������
wire [1:0] key_data      ;    //��������  

//*****************************************************
//**                    main code
//*****************************************************   

//��2λ�������ݱ���Ϊ8λ�Ĵ�������
assign   uart_tx_data = {6'b0 , key_data};

//���ڽ���ģ��
uart_rx #(
    .CLK_FREQ       (CLK_FREQ),        //����ϵͳʱ��Ƶ��
    .UART_BPS       (UART_BPS))        //���ô��ڽ��ղ�����
u_uart_rx(                 
    .clk            (sys_clk       ), 
    .rst_n          (sys_rst_n     ),
    
    .uart_rxd       (rs485_uart_rxd),
    .uart_rx_done   (uart_rx_done  ),
    .uart_rx_data   (uart_rx_data  )
    );

//led����ģ��   
led_ctrl u_led_ctrl(
    .clk            (sys_clk          ),
    .rst_n          (sys_rst_n        ),

    .led_en         (uart_rx_done     ),  //led����ʹ��
    .led_data       (uart_rx_data[1:0]),  //led��������
    .led            (led              )
);

//��������ģ��
key_trig u_key_trig(
    .clk            (sys_clk    ), 
    .rst_n          (sys_rst_n  ),
    
    .key            (key        ),
    .key_data_valid (uart_tx_en ),     //������Ч֪ͨ�ź�
    .key_data       (key_data   )      //��������
    );

//���ڷ���ģ��   
uart_tx #(
    .CLK_FREQ       (CLK_FREQ),        //����ϵͳʱ��Ƶ��
    .UART_BPS       (UART_BPS))        //���ô��ڷ��Ͳ�����
u_uart_tx(                 
    .clk            (sys_clk       ),
    .rst_n          (sys_rst_n     ),
     
    .uart_tx_en     (uart_tx_en    ),
    .uart_tx_data   (uart_tx_data  ),
    .uart_txd       (rs485_uart_txd)
    );

endmodule 
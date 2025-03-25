//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ov7725_dri
// Created by:          ����ԭ��
// Created date:        2023��9��14��19:26:07
// Version:             V1.0
// Descriptions:        ov7725_dri
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ov7725_dri(
    input                 clk      ,  //ʱ��
    input                 rst_n    ,  //ϵͳ��λ���͵�ƽ��Ч
    
    output                init_done,  //��ʼ������ź�
    output                cam_scl  ,  //cmos SCCB_SCL��
    inout                 cam_sda     //cmos SCCB_SDA��  
    );
        
//parameter define                     
parameter  SLAVE_ADDR = 7'h21          ;  //OV7725��������ַ7'h21
parameter  BIT_CTRL   = 1'b0           ;  //OV7725���ֽڵ�ַΪ8λ  0:8λ 1:16λ
parameter  CLK_FREQ   = 26'd50_000_000 ; //i2c_driģ�������ʱ��Ƶ�� 50.0MHz
parameter  I2C_FREQ   = 18'd250_000    ;  //I2C��SCLʱ��Ƶ��,������400KHz

//wire define								    
wire         i2c_exec                  ;  //I2C����ִ���ź�
wire  [15:0] i2c_data                  ;  //I2CҪ���õĵ�ַ������(��8λ��ַ,��8λ����)          
wire         cam_init_done             ;  //����ͷ��ʼ�����
wire         i2c_done                  ;  //I2C�Ĵ�����������ź�
wire         i2c_dri_clk               ;  //I2C����ʱ��	

//*****************************************************
//**                    main code
//*****************************************************

//I2C����ģ��    
i2c_ov7725_rgb565_cfg u_i2c_cfg(
    .clk                    (i2c_dri_clk),
    .rst_n                  (rst_n),
    .i2c_done               (i2c_done),
    .i2c_exec               (i2c_exec),
    .i2c_data               (i2c_data),
    .init_done              (init_done)
    );

//I2C����ģ��
i2c_dri 
   #(
    .SLAVE_ADDR             (SLAVE_ADDR),           //��������
    .CLK_FREQ               (CLK_FREQ  ),           
    .I2C_FREQ               (I2C_FREQ  )            
    )                      
   u_i2c_dri(               
    .clk                    (clk ),   
    .rst_n                  (rst_n     ),   
    //i2c interface         
    .i2c_exec               (i2c_exec  ),   
    .bit_ctrl               (BIT_CTRL  ),   
    .i2c_rh_wl              (1'b0),                 //�̶�Ϊ0��ֻ�õ���IIC������д����   
    .i2c_addr               (i2c_data[15:8]),   
    .i2c_data_w             (i2c_data[7:0]),   
    .i2c_data_r             (),   
    .i2c_done               (i2c_done  ), 
    .i2c_ack                (),    
    .scl                    (cam_scl   ),   
    .sda                    (cam_sda   ),   
    //user interface        
    .dri_clk                (i2c_dri_clk)           //I2C����ʱ��
);
        
endmodule

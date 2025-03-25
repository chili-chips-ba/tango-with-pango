//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ov7725_dri
// Created by:          正点原子
// Created date:        2023年9月14日19:26:07
// Version:             V1.0
// Descriptions:        ov7725_dri
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ov7725_dri(
    input                 clk      ,  //时钟
    input                 rst_n    ,  //系统复位，低电平有效
    
    output                init_done,  //初始化完成信号
    output                cam_scl  ,  //cmos SCCB_SCL线
    inout                 cam_sda     //cmos SCCB_SDA线  
    );
        
//parameter define                     
parameter  SLAVE_ADDR = 7'h21          ;  //OV7725的器件地址7'h21
parameter  BIT_CTRL   = 1'b0           ;  //OV7725的字节地址为8位  0:8位 1:16位
parameter  CLK_FREQ   = 26'd50_000_000 ; //i2c_dri模块的驱动时钟频率 50.0MHz
parameter  I2C_FREQ   = 18'd250_000    ;  //I2C的SCL时钟频率,不超过400KHz

//wire define								    
wire         i2c_exec                  ;  //I2C触发执行信号
wire  [15:0] i2c_data                  ;  //I2C要配置的地址与数据(高8位地址,低8位数据)          
wire         cam_init_done             ;  //摄像头初始化完成
wire         i2c_done                  ;  //I2C寄存器配置完成信号
wire         i2c_dri_clk               ;  //I2C操作时钟	

//*****************************************************
//**                    main code
//*****************************************************

//I2C配置模块    
i2c_ov7725_rgb565_cfg u_i2c_cfg(
    .clk                    (i2c_dri_clk),
    .rst_n                  (rst_n),
    .i2c_done               (i2c_done),
    .i2c_exec               (i2c_exec),
    .i2c_data               (i2c_data),
    .init_done              (init_done)
    );

//I2C驱动模块
i2c_dri 
   #(
    .SLAVE_ADDR             (SLAVE_ADDR),           //参数传递
    .CLK_FREQ               (CLK_FREQ  ),           
    .I2C_FREQ               (I2C_FREQ  )            
    )                      
   u_i2c_dri(               
    .clk                    (clk ),   
    .rst_n                  (rst_n     ),   
    //i2c interface         
    .i2c_exec               (i2c_exec  ),   
    .bit_ctrl               (BIT_CTRL  ),   
    .i2c_rh_wl              (1'b0),                 //固定为0，只用到了IIC驱动的写操作   
    .i2c_addr               (i2c_data[15:8]),   
    .i2c_data_w             (i2c_data[7:0]),   
    .i2c_data_r             (),   
    .i2c_done               (i2c_done  ), 
    .i2c_ack                (),    
    .scl                    (cam_scl   ),   
    .sda                    (cam_sda   ),   
    //user interface        
    .dri_clk                (i2c_dri_clk)           //I2C操作时钟
);
        
endmodule

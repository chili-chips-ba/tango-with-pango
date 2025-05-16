//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           cmos_data_top
// Created by:          正点原子
// Created date:        2023年9月14日19:26:07
// Version:             V1.0
// Descriptions:        cmos_data_top
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module cmos_data_top(
    input                 rst_n            ,  //复位信号
    input       [15:0]    lcd_id           ,  //LCD屏的ID号
    input       [10:0]    h_disp           ,  //LCD屏水平分辨率
    input       [10:0]    v_disp           ,  //LCD屏垂直分辨率      
    //摄像头接口                           
    input                 cam_pclk         ,  //cmos 数据像素时钟
    input                 cam_vsync        ,  //cmos 场同步信号
    input                 cam_href         ,  //cmos 行同步信号
    input       [7:0]     cam_data         ,                      
    //用户接口 
    output      [10:0]    h_pixel          ,  //存入ddr3的水平分辨率
    output      [10:0]    v_pixel          ,  //存入ddr3的垂直分辨率    
    output      [27:0]    ddr3_addr_max    ,  //存入DDR3的最大读写地址 
    output                cmos_frame_vsync ,  //帧有效信号    
    output                cmos_frame_href  ,  //行有效信号
    output                cmos_frame_valid ,  //数据有效使能信号
    output       [15:0]   cmos_frame_data     //有效数据       
    );

//wire define       
wire         data_valid;         //经过裁剪的摄像头数据 
wire  [15:0] wr_data;            //没有经过裁剪的摄像头数据 

//*****************************************************
//**                    main code
//*****************************************************   

//摄像头数据裁剪模块
cmos_tailor  u_cmos_tailor(
    .rst_n                 (rst_n),  
    .lcd_id                (lcd_id),
    .cam_pclk              (cam_pclk),
    .cam_vsync             (cmos_frame_vsync),
    .cam_href              (cmos_frame_href),
    .cam_data              (wr_data), 
    .cam_data_valid        (data_valid),
    .h_disp                (h_disp),
    .v_disp                (v_disp),  
    .h_pixel               (h_pixel),
    .v_pixel               (v_pixel), 
    .ddr3_addr_max         (ddr3_addr_max),
    .cmos_frame_valid      (cmos_frame_valid),     
    .cmos_frame_data       (cmos_frame_data)                

);

//摄像头数据采集模块
cmos_capture_data u_cmos_capture_data(

    .rst_n                 (rst_n),
    .cam_pclk              (cam_pclk),   
    .cam_vsync             (cam_vsync),
    .cam_href              (cam_href),
    .cam_data              (cam_data),           
    .cmos_frame_vsync      (cmos_frame_vsync),
    .cmos_frame_href       (cmos_frame_href),
    .cmos_frame_valid      (data_valid),     
    .cmos_frame_data       (wr_data)             
    );
       
endmodule
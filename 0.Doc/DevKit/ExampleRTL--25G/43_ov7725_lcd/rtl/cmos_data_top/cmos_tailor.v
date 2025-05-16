//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           cmos_tailor
// Created by:          正点原子
// Created date:        2023年9月14日19:26:07
// Version:             V1.0
// Descriptions:        cmos_tailor
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module cmos_tailor(
    input                 rst_n            ,  //复位信号                    
    input       [15:0]    lcd_id           ,  //LCD屏的ID号
    input       [10:0]    h_disp           ,  //LCD屏水平分辨率
    input       [10:0]    v_disp           ,  //LCD屏垂直分辨率  
    output reg  [10:0]    h_pixel          ,  //存入ddr3的水平分辨率
    output reg  [10:0]    v_pixel          ,  //存入ddr3的屏垂直分辨率  
    output      [27:0]    ddr3_addr_max    ,  //存入ddr3的最大读写地址    
    //摄像头接口                           
    input                 cam_pclk         ,  //cmos 数据像素时钟
    input                 cam_vsync        ,  //cmos 场同步信号
    input                 cam_href         ,  //cmos 行同步信号
    input        [15:0]   cam_data         , 
    input                 cam_data_valid   ,    
    //用户接口                              
    output                cmos_frame_valid ,  //数据有效使能信号
    output      [15:0]    cmos_frame_data     //有效数据        
    );

//reg define                     
reg             cam_vsync_d0     ;
reg             cam_vsync_d1     ;
reg             cam_href_d0      ;
reg             cam_href_d1      ;
reg    [10:0]   h_cnt            ;            //对行计数       
reg    [10:0]   v_cnt            ;            //对场计数
reg    [10:0]   h_disp_a         ;            //LCD屏水平分辨率
reg    [10:0]   v_disp_a         ;            //LCD屏垂直分辨率 
reg             data_valid_tailor;   
reg    [15:0]   wr_data_tailor   ;
reg    [15:0]   lcd_id_a         ;            //时钟同步后的LCD屏的ID号  

//wire define                    
wire            pos_vsync        ;            //采输入场同步信号的上升沿
wire            neg_hsync        ;            //采输入行同步信号的下降沿
wire   [10:0]   cmos_h_pixel     ;            //CMOS水平方向像素个数
wire   [10:0]   cmos_v_pixel     ;            //CMOS垂直方向像素个数							      
wire   [10:0]   cam_border_pos_l ;            //左侧边界的横坐标
wire   [10:0]   cam_border_pos_r ;            //右侧边界的横坐标
wire   [10:0]   cam_border_pos_t ;            //上端边界的纵坐标
wire   [10:0]   cam_border_pos_b ;            //下端边界的纵坐标

//*****************************************************
//**                    main code
//*****************************************************

assign cmos_frame_valid = (lcd_id_a == 16'h4342) ? data_valid_tailor : cam_data_valid ;    
assign cmos_frame_data = (lcd_id_a == 16'h4342) ? wr_data_tailor : cam_data ;

assign  ddr3_addr_max = h_pixel * v_pixel;   //存入ddr3的最大读写地址

assign  cmos_h_pixel = 11'd640 ;  //CMOS水平方向像素个数
assign  cmos_v_pixel = 11'd480 ;  //CMOS垂直方向像素个数 

//采输入场同步信号的上升沿
assign pos_vsync = (~cam_vsync_d1) & cam_vsync_d0; 

//采输入行同步信号的下降沿
assign neg_hsync = (~cam_href_d0) & cam_href_d1;

//左侧边界的横坐标计算 
assign cam_border_pos_l  = (cmos_h_pixel - h_disp_a)/2-1;

//右侧边界的横坐标计算 
assign cam_border_pos_r = h_disp + (cmos_h_pixel - h_disp_a)/2-1;

//上端边界的纵坐标计算 
assign cam_border_pos_t  = (cmos_v_pixel - v_disp_a)/2;

//下端边界的纵坐标计算
assign cam_border_pos_b = v_disp_a + (cmos_v_pixel - v_disp_a)/2;

always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        cam_vsync_d0 <= 1'b0;
        cam_vsync_d1 <= 1'b0;
        cam_href_d0 <= 1'b0;
        cam_href_d1 <= 1'b0;
        lcd_id_a <= 0;
        v_disp_a <= 0;
        h_disp_a <= 0;        
    end
    else begin
        cam_vsync_d0 <= cam_vsync;
        cam_vsync_d1 <= cam_vsync_d0;
        cam_href_d0 <= cam_href;
        cam_href_d1 <= cam_href_d0;
        lcd_id_a <= lcd_id;
        v_disp_a <= v_disp;     
        h_disp_a <= h_disp;               
    end
end

//计算存入ddr3的分辨率
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        h_pixel <= 11'b0;
        v_pixel <= 11'b0;
    end
    else begin
        if(lcd_id_a == 16'h4342)begin
            h_pixel <= h_disp_a;
            v_pixel <= v_disp_a;      
      end
      else begin
          h_pixel <= cmos_h_pixel;
          v_pixel <= cmos_v_pixel;           
      end        
    end
end

//对行计数
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) 
        h_cnt <= 11'b0;
    else begin
        if(pos_vsync||neg_hsync)
            h_cnt <= 11'b0;      
        else if(cam_data_valid)
            h_cnt <= h_cnt + 1'b1;           
        else if (cam_href_d0)
            h_cnt <= h_cnt; 
        else		
            h_cnt <= h_cnt; 	  
    end
end

//对场计数
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) 
        v_cnt <= 11'b0;
    else begin
        if(pos_vsync)
            v_cnt <= 11'b0;      
        else if(neg_hsync)
            v_cnt <= v_cnt + 1'b1;           
        else
            v_cnt <= v_cnt; 	  
    end
end

//产生输出数据有效信号(data_valid_tailor)
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        data_valid_tailor <= 1'b0;
    else if(h_cnt[10:0]>=cam_border_pos_l && h_cnt[10:0]<cam_border_pos_r&&
		    v_cnt[10:0]>=cam_border_pos_t && v_cnt[10:0]<cam_border_pos_b)
            data_valid_tailor <= cam_data_valid;
    else
            data_valid_tailor <= 1'b0;

end 

always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        wr_data_tailor <= 15'b0;
    else if(h_cnt[10:0]>=cam_border_pos_l && h_cnt[10:0]<cam_border_pos_r&&
		    v_cnt[10:0]>=cam_border_pos_t && v_cnt[10:0]<cam_border_pos_b)
            wr_data_tailor <= cam_data;
    else
            wr_data_tailor <= 15'b0;

end 
      
endmodule
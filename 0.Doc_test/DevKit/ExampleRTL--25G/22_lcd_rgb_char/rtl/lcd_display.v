//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           lcd_display
// Last modified Date:  2019/8/07 10:41:06
// Last Version:        V1.1
// Descriptions:        RGB LCD字符和显示
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/8/07 10:41:06
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module lcd_display(
    input             lcd_pclk,     //时钟
    input             rst_n,        //复位，低电平有效
                                    
    input      [10:0] pixel_xpos,   //像素点横坐标
    input      [10:0] pixel_ypos,   //像素点纵坐标    
    output reg [23:0] pixel_data    //像素点数据,
);                                   
                                     
//parameter define                   
localparam PIC_X_START = 11'd10;     //图片起始点横坐标
localparam PIC_Y_START = 11'd10;     //图片起始点纵坐标
localparam PIC_WIDTH   = 11'd100;    //图片宽度
localparam PIC_HEIGHT  = 11'd100;    //图片高度
                       
localparam CHAR_X_START= 11'd10;     //字符起始点横坐标
localparam CHAR_Y_START= 11'd120;    //字符起始点纵坐标
localparam CHAR_WIDTH  = 11'd128;    //字符宽度,4个字符:32*4
localparam CHAR_HEIGHT = 11'd32;     //字符高度
                       
localparam BACK_COLOR  = 24'hE0FFFF; //背景色，浅蓝色
localparam CHAR_COLOR  = 24'hff0000; //字符颜色，红色

//reg define
reg   [127:0] char[31:0];  //字符数组
reg   [13:0]  rom_addr  ;  //ROM地址

//wire define   
wire  [10:0]  x_cnt;       //横坐标计数器
wire  [10:0]  y_cnt;       //纵坐标计数器
wire          rom_rd_en ;  //ROM读使能信号
wire  [23:0]  rom_rd_data ;//ROM数据

//*****************************************************
//**                    main code
//*****************************************************

assign  x_cnt = pixel_xpos + 1'b1  - CHAR_X_START; //像素点相对于字符区域起始点水平坐标
assign  y_cnt = pixel_ypos - CHAR_Y_START; //像素点相对于字符区域起始点垂直坐标
assign  rom_rd_en = 1'b1;                  //读使能拉高，即一直读ROM数据

//给字符数组赋值，显示汉字“正点原子”，每个汉字大小为32*32
always @(posedge lcd_pclk) begin
    char[0 ]  <= 128'h00000000000000000000000000000000;
    char[1 ]  <= 128'h00000000000000000000000000000000;
    char[2 ]  <= 128'h00000000000100000000002000000000;
    char[3 ]  <= 128'h000000100001800002000070000000C0;
    char[4 ]  <= 128'h000000380001800003FFFFF803FFFFE0;
    char[5 ]  <= 128'h07FFFFFC0001800003006000000001E0;
    char[6 ]  <= 128'h0000C000000180600300600000000300;
    char[7 ]  <= 128'h0000C0000001FFF00300C00000000600;
    char[8 ]  <= 128'h0000C000000180000310804000001800;
    char[9 ]  <= 128'h0000C00000018000031FFFE000003000;
    char[10]  <= 128'h0000C00000018000031800400001C000;
    char[11]  <= 128'h0000C00000018000031800400001C000;
    char[12]  <= 128'h00C0C000018181800318004000018000;
    char[13]  <= 128'h00C0C00001FFFFC0031FFFC000018010;
    char[14]  <= 128'h00C0C060018001800318004000018038;
    char[15]  <= 128'h00C0FFF001800180031800403FFFFFFC;
    char[16]  <= 128'h00C0C000018001800318004000018000;
    char[17]  <= 128'h00C0C000018001800218004000018000;
    char[18]  <= 128'h00C0C00001800180021FFFC000018000;
    char[19]  <= 128'h00C0C000018001800210304000018000;
    char[20]  <= 128'h00C0C00001FFFF800200300000018000;
    char[21]  <= 128'h00C0C000018001800606300000018000;
    char[22]  <= 128'h00C0C000018001000607370000018000;
    char[23]  <= 128'h00C0C00000000000060E31C000018000;
    char[24]  <= 128'h00C0C000001000400418307000018000;
    char[25]  <= 128'h00C0C000020830600430303800018000;
    char[26]  <= 128'h00C0C010020C18300860301800018000;
    char[27]  <= 128'h00C0C038060E18180883700800018000;
    char[28]  <= 128'h3FFFFFFC0C0618181100F008003F8000;
    char[29]  <= 128'h000000001C0408182000600000070000;
    char[30]  <= 128'h00000000000000000000000000020000;
    char[31]  <= 128'h00000000000000000000000000000000;
end

//为LCD不同显示区域绘制图片、字符和背景色
always @(posedge lcd_pclk or negedge rst_n) begin
    if (!rst_n)
        pixel_data <= BACK_COLOR;
    else if( (pixel_xpos >= PIC_X_START - 1'b1) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 1'b1) 
          && (pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT) )
        pixel_data <= rom_rd_data ;  //显示图片
    else if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
         && (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT)) begin
        if(char[y_cnt][CHAR_WIDTH -1'b1 - x_cnt])
            pixel_data <= CHAR_COLOR;    //显示字符
        else
            pixel_data <= BACK_COLOR;    //显示字符区域的背景色
    end
    else
        pixel_data <= BACK_COLOR;        //屏幕背景色
end

//根据当前扫描点的横纵坐标为ROM地址赋值
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n)
        rom_addr <= 14'd0;
    //当横纵坐标位于图片显示区域时,累加ROM地址    
    else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT) 
        && (pixel_xpos >= PIC_X_START - 2'd2) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 2'd2)) 
        rom_addr <= rom_addr + 1'b1;
    //当横纵坐标位于图片区域最后一个像素点时,ROM地址清零    
    else if((pixel_ypos >= PIC_Y_START + PIC_HEIGHT))
        rom_addr <= 14'd0;
end

//ROM：存储图片
blk_mem_gen_0 blk_mem_gen_0 (
  .addr        (rom_addr),          // input [13:0]
  .clk        (lcd_pclk),            // input
  .rst        (1'b0),            // input
  .rd_data    (rom_rd_data)     // output [23:0]
);
endmodule 
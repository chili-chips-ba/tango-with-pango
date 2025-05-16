//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           lcd_display
// Created by:          正点原子
// Created date:        2023年5月18日14:17:02
// Version:             V1.0
// Descriptions:        RGB LCD显示模块
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module lcd_display(
    input                lcd_pclk , //LCD像素时钟
    input                rst_n    , //系统复位
    
    //日历数据
    input         [7:0]  sec,        //秒
    input         [7:0]  min,        //分
    input         [7:0]  hour,       //时
    input         [7:0]  day,        //日
    input         [7:0]  mon,        //月
    input         [7:0]  year,       //年
    
    //LCD数据接口
    input        [10:0]  pixel_xpos, //像素点横坐标
    input        [10:0]  pixel_ypos, //像素点纵坐标
    output  reg  [23:0]  pixel_data  
 //像素点数据
);

//parameter define
localparam CHAR_POS_X_1  = 11'd1;  //第1行字符区域起始点横坐标
localparam CHAR_POS_Y_1  = 11'd1;  //第1行字符区域起始点纵坐标
localparam CHAR_POS_X_2  = 11'd17; //第2行字符区域起始点横坐标
localparam CHAR_POS_Y_2  = 11'd17; //第2行字符区域起始点纵坐标
localparam CHAR_WIDTH_1  = 11'd80; //第1行字符区域的宽度，第1行共10个字符(加空格)
localparam CHAR_WIDTH_2  = 11'd64; //第2行字符区域的宽度，第2行共8个字符(加空格)
localparam CHAR_HEIGHT   = 11'd16; //单个字符的高度
localparam WHITE  = 24'hffffff;    //背景色,白色
localparam BLACK  = 24'h000000;    //字符颜色,黑色

//reg define
reg  [127:0]  char  [9:0] ;        //字符数组

//*****************************************************
//**                    main code
//*****************************************************

//字符数组初始值,用于存储字模数据(由取模软件生成,单个数字字体大小:16*8)
always @(posedge lcd_pclk ) begin
    char[0] <= 128'h00000018244242424242424224180000 ;  // "0"
    char[1] <= 128'h000000107010101010101010107C0000 ;  // "1"
    char[2] <= 128'h0000003C4242420404081020427E0000 ;  // "2"
    char[3] <= 128'h0000003C424204180402024244380000 ;  // "3"
    char[4] <= 128'h000000040C14242444447E04041E0000 ;  // "4"
    char[5] <= 128'h0000007E404040586402024244380000 ;  // "5"
    char[6] <= 128'h0000001C244040586442424224180000 ;  // "6"
    char[7] <= 128'h0000007E444408081010101010100000 ;  // "7"
    char[8] <= 128'h0000003C4242422418244242423C0000 ;  // "8"
    char[9] <= 128'h0000001824424242261A020224380000 ;  // "9"
end

//不同的区域绘制不同的像素数据
always @(posedge lcd_pclk or negedge rst_n ) begin
    if (!rst_n)  begin
        pixel_data <= BLACK;
    end
    
    //在第一行显示年的千位 固定值"2"
    else if((pixel_xpos >= CHAR_POS_X_1 - 1'b1) 
         && (pixel_xpos <  CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 1 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_1) 
         && (pixel_ypos <  CHAR_POS_Y_1 + CHAR_HEIGHT)) begin
        if(char[2][(CHAR_HEIGHT+CHAR_POS_Y_1 - pixel_ypos) * 8
                        - ((pixel_xpos - (CHAR_POS_X_1-1'b1)) % 8) - 11'd1])
            pixel_data <= BLACK;        //显示字符为黑色
        else
            pixel_data <= WHITE;        //显示字符区域背景为白色
    end
    
    //在第一行显示年的百位 固定值"0"
    else if((pixel_xpos >= CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 *1 - 1'b1) 
         && (pixel_xpos <  CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 *2 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_1) 
         && (pixel_ypos <  CHAR_POS_Y_1 + CHAR_HEIGHT)) begin
        if(char[0][(CHAR_HEIGHT + CHAR_POS_Y_1 - pixel_ypos) * 8
                        - ((pixel_xpos - (CHAR_POS_X_1-1'b1)) % 8) - 11'd1])
            pixel_data <= BLACK;
        else
            pixel_data <= WHITE;
    end
    
    //在第一行显示年的十位
    else if((pixel_xpos >= CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 2 - 1'b1) 
         && (pixel_xpos <  CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 3 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_1) 
         && (pixel_ypos <  CHAR_POS_Y_1 + CHAR_HEIGHT)) begin
        if(char[year[7:4]][(CHAR_HEIGHT + CHAR_POS_Y_1 - pixel_ypos) * 8
                        - ((pixel_xpos - (CHAR_POS_X_1-1'b1)) % 8) - 11'd1])
            pixel_data <= BLACK;
        else
            pixel_data <= WHITE;
    end
    
    //在第一行显示年的个位
    else if((pixel_xpos >= CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 3 - 1'b1)
         && (pixel_xpos <  CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 4 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_1)
         && (pixel_ypos <  CHAR_POS_Y_1 + CHAR_HEIGHT)) begin
        if(char[year[3:0]][(CHAR_HEIGHT + CHAR_POS_Y_1 - pixel_ypos) * 8
                        - ((pixel_xpos - (CHAR_POS_X_1-1'b1)) % 8) - 11'd1])
            pixel_data <= BLACK;
        else
            pixel_data <= WHITE;
    end
    
    //在第一行显示空格
    else if((pixel_xpos >= CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 4 - 1'b1)
         && (pixel_xpos <  CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 5 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_1)
         && (pixel_ypos <  CHAR_POS_Y_1 + CHAR_HEIGHT))
        pixel_data <= WHITE;
    
    //在第一行显示月的十位
    else if((pixel_xpos >= CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 5 - 1'b1)
         && (pixel_xpos <  CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 6 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_1)
         && (pixel_ypos <  CHAR_POS_Y_1 + CHAR_HEIGHT)) begin
        if(char[mon[7:4]][(CHAR_HEIGHT + CHAR_POS_Y_1 - pixel_ypos) * 8
                        - ((pixel_xpos - (CHAR_POS_X_1-1'b1)) % 8) -11'd1])
            pixel_data <= BLACK;
        else
            pixel_data <= WHITE;
    end
    
    //在第一行显示月的个位
    else if((pixel_xpos >= CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 6 - 1'b1)
         && (pixel_xpos <  CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 7 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_1)
         && (pixel_ypos <  CHAR_POS_Y_1 + CHAR_HEIGHT)) begin
        if(char[mon[3:0]][(CHAR_HEIGHT + CHAR_POS_Y_1 - pixel_ypos) * 8
                        - ((pixel_xpos - (CHAR_POS_X_1-1'b1)) % 8) - 11'd1])
            pixel_data <= BLACK;
        else
            pixel_data <= WHITE;
    end
    
    //在第一行显示空格
    else if((pixel_xpos >= CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 7 - 1'b1)
         && (pixel_xpos <  CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 8 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_1)
         && (pixel_ypos <  CHAR_POS_Y_1 + CHAR_HEIGHT))
        pixel_data <= WHITE;

    
    //在第一行显示日的十位
    else if((pixel_xpos >= CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 8 - 1'b1)
              && (pixel_xpos <  CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 9 - 1'b1)
              && (pixel_ypos >= CHAR_POS_Y_1)
              && (pixel_ypos <  CHAR_POS_Y_1 + CHAR_HEIGHT)  ) begin
        if(char[day[7:4]][(CHAR_HEIGHT + CHAR_POS_Y_1 - pixel_ypos) * 8
                        - ((pixel_xpos - (CHAR_POS_X_1-1'b1)) % 8) -11'd1])
            pixel_data <= BLACK;
        else
            pixel_data <= WHITE;
    end
    
    //在第一行显示日的个位
    else if((pixel_xpos >= CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 9 - 1'b1)
         && (pixel_xpos <  CHAR_POS_X_1 + CHAR_WIDTH_1 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_1)
         && (pixel_ypos <  CHAR_POS_Y_1 + CHAR_HEIGHT)) begin
        if(char[day[3:0]][(CHAR_HEIGHT + CHAR_POS_Y_1 - pixel_ypos) * 8
                        - ((pixel_xpos - (CHAR_POS_X_1-1'b1)) % 8) -11'd1])
            pixel_data <= BLACK;
        else
            pixel_data <= WHITE;
    end
    
    //在第二行显示时的十位
    else if((pixel_xpos >= CHAR_POS_X_2 - 1'b1)
         && (pixel_xpos <  CHAR_POS_X_2 + CHAR_WIDTH_2 / 8 * 1 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_2)
         && (pixel_ypos <  CHAR_POS_Y_2 + CHAR_HEIGHT)) begin
        if(char[hour[7:4]][(CHAR_HEIGHT + CHAR_POS_Y_2 - pixel_ypos) * 8
                        - ((pixel_xpos - (CHAR_POS_X_2-1'b1)) % 8) -11'd1])
            pixel_data <= BLACK;
        else
            pixel_data <= WHITE;
    end
    
    //在第二行显示时的个位
    else if((pixel_xpos >= CHAR_POS_X_2 + CHAR_WIDTH_2 / 8 * 1 - 1'b1)
         && (pixel_xpos <  CHAR_POS_X_2 + CHAR_WIDTH_2 / 8 * 2 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_2)
         && (pixel_ypos <  CHAR_POS_Y_2 + CHAR_HEIGHT)) begin
        if(char[hour[3:0]][(CHAR_HEIGHT + CHAR_POS_Y_2 - pixel_ypos) * 8
                        - ((pixel_xpos - (CHAR_POS_X_2-1'b1)) % 8) -11'd1])
            pixel_data <= BLACK;
        else
            pixel_data <= WHITE;
    end
    
    //在第二行显示空格
    else if((pixel_xpos >= CHAR_POS_X_2 + CHAR_WIDTH_2 / 8 * 2 - 1'b1)
         && (pixel_xpos <  CHAR_POS_X_2 + CHAR_WIDTH_2 / 8 * 3 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_2)
         && (pixel_ypos <  CHAR_POS_Y_2 + CHAR_HEIGHT))
        pixel_data <= WHITE;
    
    //在第二行显示分的十位
    else if((pixel_xpos >= CHAR_POS_X_2 + CHAR_WIDTH_2 / 8 * 3 - 1'b1)
         && (pixel_xpos <  CHAR_POS_X_2 + CHAR_WIDTH_2 / 8 * 4 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_2)                  
         && (pixel_ypos <  CHAR_POS_Y_2 + CHAR_HEIGHT)) begin
        if(char[min[7:4]][(CHAR_HEIGHT + CHAR_POS_Y_2 - pixel_ypos) * 8
                        - ((pixel_xpos - (CHAR_POS_X_2-1'b1)) % 8) - 11'd1])
            pixel_data <= BLACK;
        else
            pixel_data <= WHITE;
    end
    
    //在第二行显示分的个位
    else if((pixel_xpos >= CHAR_POS_X_2 + CHAR_WIDTH_2 / 8 * 4 - 1'b1)
         && (pixel_xpos <  CHAR_POS_X_2 + CHAR_WIDTH_2 / 8 * 5 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_2)
         && (pixel_ypos <  CHAR_POS_Y_2 + CHAR_HEIGHT)) begin
        if(char[min[3:0]][(CHAR_HEIGHT + CHAR_POS_Y_2 - pixel_ypos) * 8
                        - ((pixel_xpos - (CHAR_POS_X_2-1'b1)) % 8) -11'd1])
            pixel_data <= BLACK;
        else
            pixel_data <= WHITE;
    end
    
    //在第二行显示空格
    else if((pixel_xpos >= CHAR_POS_X_2 + CHAR_WIDTH_2 / 8 * 5 - 1'b1)
         && (pixel_xpos <  CHAR_POS_X_2 + CHAR_WIDTH_2 / 8 * 6 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_2)
         && (pixel_ypos <  CHAR_POS_Y_2 + CHAR_HEIGHT))
        pixel_data <= WHITE;
    
    //在第二行显示秒的十位
    else if((pixel_xpos >= CHAR_POS_X_2 + CHAR_WIDTH_2 / 8 * 6 - 1'b1)
         && (pixel_xpos <  CHAR_POS_X_2 + CHAR_WIDTH_2 / 8 * 7 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_2)
         && (pixel_ypos <  CHAR_POS_Y_2 + CHAR_HEIGHT)) begin
        if(char[sec[7:4]][(CHAR_HEIGHT + CHAR_POS_Y_2 - pixel_ypos) * 8
                        - ((pixel_xpos - (CHAR_POS_X_2-1'b1))%8) - 11'd1])
            pixel_data <= BLACK;
        else
            pixel_data <= WHITE;
    end
    
    //在第二行显示秒的个位    
    else if((pixel_xpos >= CHAR_POS_X_2 + CHAR_WIDTH_2 / 8 * 7 - 1'b1)
         && (pixel_xpos <  CHAR_POS_X_2 + CHAR_WIDTH_2 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_2)
         && (pixel_ypos <  CHAR_POS_Y_2 + CHAR_HEIGHT)) begin
        if(char[sec[3:0]][(CHAR_HEIGHT + CHAR_POS_Y_2 - pixel_ypos) * 8
                        - ((pixel_xpos - (CHAR_POS_X_2-1'b1)) % 8) -11'd1])
            pixel_data <= BLACK;
        else
            pixel_data <= WHITE;
    end
    else
        pixel_data <= WHITE;    //屏幕背景为白色
end

endmodule 
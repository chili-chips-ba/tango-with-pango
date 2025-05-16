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
// Last modified Date:  2019/1/30 11:12:36
// Last Version:        V1.1
// Descriptions:        RGB LCD显示模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/5/29 10:55:56
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
// Modified by:         正点原子
// Modified date:       2019/5/30 11:12:36
// Version:             V1.1
// Descriptions:        
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module lcd_display(
    input                lcd_pclk           ,
    input                rst_n              ,
    //日历数据
    input                data_symbol        , //电压值符号位，负电压最高位显示负号 ,正值显示空格                 
    input        [7:0]   data_percentiles   , //电压值小数点后第二位                                
    input        [7:0]   data_decile        , //电压值小数点后第一位                                
    input        [7:0]   data_units         , //电压值的个位数                                   
    input        [7:0]   data_tens          , //电压值的十位数  
    //LCD数据接口                           
    input        [10:0]  pixel_xpos         , //像素点横坐标
    input        [10:0]  pixel_ypos         , //像素点纵坐标
    output  reg  [23:0]  pixel_data           //像素点数据
);

//parameter define
localparam CHAR_POS_X_1  = 11'd1;  //第1行字符区域起始点横坐标
localparam CHAR_POS_Y_1  = 11'd1;  //第1行字符区域起始点纵坐标
localparam CHAR_POS_X_2  = 11'd17; //第2行字符区域起始点横坐标
localparam CHAR_POS_Y_2  = 11'd17; //第2行字符区域起始点纵坐标
localparam CHAR_WIDTH_1  = 11'd56; //一共7个字符总宽度为56
localparam CHAR_HEIGHT   = 11'd16; //单个字符的高度
localparam WHITE  = 24'hffffff;    //背景色,白色
localparam BLACK  = 24'h000000;    //字符颜色,黑色

//reg define
reg  [127:0]  char  [12:0] ;        //字符数组

//*****************************************************
//**                    main code
//*****************************************************

//字符数组初始值,用于存储字模数据(由取模软件生成,单个数字字体大小:8*16)
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
    char[10] <=128'h00000000000000000000000C0C000000 ;/*".",0*/
    char[11] <=128'h000000000000007E7E00000000000000 ;/*"-",0*/
    char[12] <=128'h00008181814242424224242424180000 ;/*"V",0*/
    
end

//不同的区域绘制不同的像素数据
always @(posedge lcd_pclk or negedge rst_n ) begin
    if (!rst_n)  begin
        pixel_data <= BLACK;
    end
    
    //显示符号位
    else if(     (pixel_xpos >= CHAR_POS_X_1 - 1'b1)                    
              && (pixel_xpos <  CHAR_POS_X_1 + CHAR_WIDTH_1/7*1 - 1'b1)
              && (pixel_ypos >= CHAR_POS_Y_1)                    
              && (pixel_ypos <  CHAR_POS_Y_1 + CHAR_HEIGHT)  ) begin
        if(!data_symbol)
            pixel_data <= WHITE;
        else begin
            if(char [11] [ (CHAR_HEIGHT + CHAR_POS_Y_1 - pixel_ypos)*8 
                    - (pixel_xpos - (CHAR_POS_X_1 - 1'b1) ) -1'b1 ]  )
            pixel_data <= BLACK;
        else
            pixel_data <= WHITE;
        end         
    end 
     
    //显示电压值的十位数
    else if(     (pixel_xpos >= CHAR_POS_X_1 + CHAR_WIDTH_1/7*1 - 1'b1) 
              && (pixel_xpos <  CHAR_POS_X_1 + CHAR_WIDTH_1/7*2 - 1'b1)
              && (pixel_ypos >= CHAR_POS_Y_1)                  
              && (pixel_ypos <  CHAR_POS_Y_1 + CHAR_HEIGHT)  ) begin
        if(char [data_tens] [ (CHAR_HEIGHT + CHAR_POS_Y_1 - pixel_ypos)*8 
                    - (pixel_xpos - (CHAR_POS_X_1 - 1'b1 + CHAR_WIDTH_1/7*1)) - 1'b1 ]  )
            pixel_data <= BLACK;
        else
            pixel_data <= WHITE;
    end
    
    //显示电压值的个位数 
    else if(     (pixel_xpos >= CHAR_POS_X_1 + CHAR_WIDTH_1/7*2 - 1'b1) 
              && (pixel_xpos <  CHAR_POS_X_1 + CHAR_WIDTH_1/7*3 - 1'b1)
              && (pixel_ypos >= CHAR_POS_Y_1)                  
              && (pixel_ypos <  CHAR_POS_Y_1 + CHAR_HEIGHT)  ) begin
        if(char [data_units] [ (CHAR_HEIGHT + CHAR_POS_Y_1 - pixel_ypos)*8 
                              - (pixel_xpos - (CHAR_POS_X_1 - 1'b1 + CHAR_WIDTH_1/7*2)) - 1'b1 ]  )
            pixel_data <= BLACK;
        else
            pixel_data <= WHITE;
    end
    
    //显示固定符号小数点
    else if(     (pixel_xpos >= CHAR_POS_X_1 + CHAR_WIDTH_1/7*3 - 1'b1) 
              && (pixel_xpos <  CHAR_POS_X_1 + CHAR_WIDTH_1/7*4 - 1'b1)
              && (pixel_ypos >= CHAR_POS_Y_1)                  
              && (pixel_ypos <  CHAR_POS_Y_1 + CHAR_HEIGHT)  ) begin
        if(char [10] [ (CHAR_HEIGHT + CHAR_POS_Y_1 - pixel_ypos)*8 
                              - (pixel_xpos - (CHAR_POS_X_1 - 1'b1 + CHAR_WIDTH_1/7*3)) - 1'b1 ]  )
            pixel_data <= BLACK;
        else
            pixel_data <= WHITE;
    end
    
    //显示电压值小数点后第一位 
    else if(     (pixel_xpos >= CHAR_POS_X_1 + CHAR_WIDTH_1/7*4 - 1'b1) 
              && (pixel_xpos <  CHAR_POS_X_1 + CHAR_WIDTH_1/7*5 - 1'b1)
              && (pixel_ypos >= CHAR_POS_Y_1)                  
              && (pixel_ypos <  CHAR_POS_Y_1 + CHAR_HEIGHT)  ) begin
        if(char [data_decile] [ (CHAR_HEIGHT + CHAR_POS_Y_1 - pixel_ypos)*8 
                             - (pixel_xpos - (CHAR_POS_X_1 - 1'b1 + CHAR_WIDTH_1/7*4)) - 1'b1 ] )
            pixel_data <= BLACK;
        else
            pixel_data <= WHITE;
    end
    
    //显示电压值小数点后第二位 
    else if(     (pixel_xpos >= CHAR_POS_X_1 + CHAR_WIDTH_1/7*5 - 1'b1) 
              && (pixel_xpos <  CHAR_POS_X_1 + CHAR_WIDTH_1/7*6 - 1'b1)
              && (pixel_ypos >= CHAR_POS_Y_1)                  
              && (pixel_ypos <  CHAR_POS_Y_1 + CHAR_HEIGHT)) begin
        if(char [data_percentiles] [ (CHAR_HEIGHT + CHAR_POS_Y_1 - pixel_ypos)*8 
                             - (pixel_xpos - (CHAR_POS_X_1 - 1'b1 + CHAR_WIDTH_1/7*5)) - 1'b1 ] )
            pixel_data <= BLACK;
        else
            pixel_data <= WHITE;
    end
	
    else if(     (pixel_xpos >= CHAR_POS_X_1 + CHAR_WIDTH_1/7*6 - 1'b1) 
              && (pixel_xpos <  CHAR_POS_X_1 + CHAR_WIDTH_1 - 1'b1)
              && (pixel_ypos >= CHAR_POS_Y_1)                  
              && (pixel_ypos <  CHAR_POS_Y_1 + CHAR_HEIGHT)) begin
        if(char [12] [ (CHAR_HEIGHT + CHAR_POS_Y_1 - pixel_ypos)*8 
                             - (pixel_xpos - (CHAR_POS_X_1 - 1'b1 + CHAR_WIDTH_1/7*6)) - 1'b1 ] )
            pixel_data <= BLACK;
        else
            pixel_data <= WHITE;
    end
	
    else begin
        pixel_data <= WHITE;    //屏幕背景为白色
    end
end

endmodule 
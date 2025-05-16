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
// Created date:        2023年2月3日14:17:02
// Version:             V1.0
// Descriptions:        lcd_display
//
//----------------------------------------------------------------------------------------
//****************************************************************************************///

module lcd_display(
    input             lcd_pclk  ,               //lcd驱动时钟
    input             sys_rst_n ,               //复位信号
	input      [19:0] data      ,
    input             flag_mux  ,
    input      [10:0] pixel_xpos,               //像素点横坐标
    input      [10:0] pixel_ypos,               //像素点纵坐标
    input             sign      ,
    output reg [23:0] pixel_data                //像素点数据
);
//parameter define
parameter  CHAR_POS_X  = 11'd1      ;           //字符区域起始点横坐标
parameter  CHAR_POS_Y  = 11'd1      ;           //字符区域起始点纵坐标
parameter  CHAR_WIDTH  = 11'd88     ;           //字符区域宽度
parameter  CHAR_HEIGHT = 11'd16     ;           //字符区域高度
parameter  WHITE       = 24'hFFFFFF ;     		//背景色，白色
parameter  BLACK       = 24'h0      ;     	    //字符颜色，黑色 

//reg define
reg     [127:0] char        [14:0]  ;           //字符数组
reg     [383:0] char1               ;
reg     [383:0] char2               ;
wire    [383:0] char_mux            ;

assign char_mux = flag_mux ? char2:char1;

//wire define
wire [3:0]      data0    ;            // 个位数
wire [3:0]      data1    ;            // 十位数
wire [3:0]      data2    ;            // 百位数
wire [3:0]      data3    ;            // 千位数
wire [3:0]      data4    ;            // 万位数
wire [3:0]      data5    ; 
          
//*****************************************************
//**                    main code
//*****************************************************
assign  data5 = sign? 4'd10:4'd11 ; //符号位
assign  data4 = data[19:16];    // 百位数
assign  data3 = data[15:12];    // 十位数
assign  data2 = data[11:8];     // 个位数
assign  data1 = data[7:4];      // 十分位
assign  data0 = data[3:0];      // 百分位

//给字符数组赋值，用于存储字模数据
always @(posedge lcd_pclk) begin
    char[0 ]  <= 128'h00000018244242424242424224180000 ; // "0"
    char[1 ]  <= 128'h000000107010101010101010107C0000 ; // "1"
    char[2 ]  <= 128'h0000003C4242420404081020427E0000 ; // "2"
    char[3 ]  <= 128'h0000003C424204180402024244380000 ; // "3"
    char[4 ]  <= 128'h000000040C14242444447E04041E0000 ; // "4"
    char[5 ]  <= 128'h0000007E404040586402024244380000 ; // "5"
    char[6 ]  <= 128'h0000001C244040586442424224180000 ; // "6"
    char[7 ]  <= 128'h0000007E444408081010101010100000 ; // "7"
    char[8 ]  <= 128'h0000003C4242422418244242423C0000 ; // "8"
    char[9 ]  <= 128'h0000001824424242261A020224380000 ; // "9"
    char[10]  <= 128'h00000000000000007E00000000000000 ; // "-"
    char[11]  <= 128'h00000000000808087F08080800000000 ; // "+"
    char[12]  <= 128'h00000000000000000000000060600000 ; // "."
    char1     <= 256'h600091F4960C6C04080418001800180018001800180008000C04060801F00000;//"℃" 
    char2     <= 256'h000000000000FCE74242424242427C42487E4842444244424242E3E700000000;//"RH"
end 

//给不同的区域赋值不同的像素数据
always @(posedge lcd_pclk or negedge sys_rst_n) begin
    if (!sys_rst_n)  begin
        pixel_data <= WHITE;
    end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1) 
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd11 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data5][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //显示字符为黑色
            else
                pixel_data <= WHITE;          //显示字符区域背景为白色
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data4][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd2) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data3][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data2][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
                - ((pixel_xpos-(CHAR_POS_X - 1'b1))%11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd5)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[12][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd5) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd6)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data1][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd6) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd7)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data0][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd7) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd9)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char_mux[(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd16 
                - (((pixel_xpos + 8'd8)-(CHAR_POS_X - 1'b1)) % 11'd16) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else begin
		pixel_data <= WHITE;              //绘制屏幕背景为白色
	end
end

endmodule 
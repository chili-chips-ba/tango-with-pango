//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           lcd_display
// Created by:          ����ԭ��
// Created date:        2023��2��3��14:17:02
// Version:             V1.0
// Descriptions:        lcd_display
//
//----------------------------------------------------------------------------------------
//****************************************************************************************///

module lcd_display(
    input             lcd_pclk  ,               //lcd����ʱ��
    input             sys_rst_n ,               //��λ�ź�
	input      [7:0]  data      ,
    input      [10:0] pixel_xpos,               //���ص������
    input      [10:0] pixel_ypos,               //���ص�������

    output reg [23:0] pixel_data                //���ص�����
);
//parameter define
parameter  CHAR_POS_X  = 11'd1      ;           //�ַ�������ʼ�������
parameter  CHAR_POS_Y  = 11'd1      ;           //�ַ�������ʼ��������
parameter  CHAR_WIDTH  = 11'd88     ;           //�ַ�������
parameter  CHAR_HEIGHT = 11'd16    ;           //�ַ�����߶�
parameter  WHITE       = 24'hFFFFFF ;     		//����ɫ����ɫ
parameter  BLACK       = 24'h0      ;     	    //�ַ���ɫ����ɫ 

//reg define
reg     [127:0] char        [11:0]  ;           //�ַ�����
//wire define
wire [3:0]      data0    ;            // ��λ��
wire [3:0]      data1    ;            // ʮλ��
//*****************************************************
//**                    main code
//*****************************************************
assign  data1 = data[7:4];      // ʮλ��
assign  data0 = data[3:0];      // ��λ��

//���ַ����鸳ֵ�����ڴ洢��ģ����
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
end 

//����ͬ������ֵ��ͬ����������
always @(posedge lcd_pclk or negedge sys_rst_n) begin
    if (!sys_rst_n)  begin
        pixel_data <= WHITE;
    end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1) 
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd11 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data1][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
            else
                pixel_data <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data0][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
 
	else begin
		pixel_data <= WHITE;              //������Ļ����Ϊ��ɫ
	end
end

endmodule 
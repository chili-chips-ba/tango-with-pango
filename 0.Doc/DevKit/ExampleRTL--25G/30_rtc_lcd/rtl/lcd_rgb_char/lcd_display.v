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
// Created date:        2023��5��18��14:17:02
// Version:             V1.0
// Descriptions:        RGB LCD��ʾģ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module lcd_display(
    input                lcd_pclk , //LCD����ʱ��
    input                rst_n    , //ϵͳ��λ
    
    //��������
    input         [7:0]  sec,        //��
    input         [7:0]  min,        //��
    input         [7:0]  hour,       //ʱ
    input         [7:0]  day,        //��
    input         [7:0]  mon,        //��
    input         [7:0]  year,       //��
    
    //LCD���ݽӿ�
    input        [10:0]  pixel_xpos, //���ص������
    input        [10:0]  pixel_ypos, //���ص�������
    output  reg  [23:0]  pixel_data  
 //���ص�����
);

//parameter define
localparam CHAR_POS_X_1  = 11'd1;  //��1���ַ�������ʼ�������
localparam CHAR_POS_Y_1  = 11'd1;  //��1���ַ�������ʼ��������
localparam CHAR_POS_X_2  = 11'd17; //��2���ַ�������ʼ�������
localparam CHAR_POS_Y_2  = 11'd17; //��2���ַ�������ʼ��������
localparam CHAR_WIDTH_1  = 11'd80; //��1���ַ�����Ŀ�ȣ���1�й�10���ַ�(�ӿո�)
localparam CHAR_WIDTH_2  = 11'd64; //��2���ַ�����Ŀ�ȣ���2�й�8���ַ�(�ӿո�)
localparam CHAR_HEIGHT   = 11'd16; //�����ַ��ĸ߶�
localparam WHITE  = 24'hffffff;    //����ɫ,��ɫ
localparam BLACK  = 24'h000000;    //�ַ���ɫ,��ɫ

//reg define
reg  [127:0]  char  [9:0] ;        //�ַ�����

//*****************************************************
//**                    main code
//*****************************************************

//�ַ������ʼֵ,���ڴ洢��ģ����(��ȡģ�������,�������������С:16*8)
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

//��ͬ��������Ʋ�ͬ����������
always @(posedge lcd_pclk or negedge rst_n ) begin
    if (!rst_n)  begin
        pixel_data <= BLACK;
    end
    
    //�ڵ�һ����ʾ���ǧλ �̶�ֵ"2"
    else if((pixel_xpos >= CHAR_POS_X_1 - 1'b1) 
         && (pixel_xpos <  CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 1 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_1) 
         && (pixel_ypos <  CHAR_POS_Y_1 + CHAR_HEIGHT)) begin
        if(char[2][(CHAR_HEIGHT+CHAR_POS_Y_1 - pixel_ypos) * 8
                        - ((pixel_xpos - (CHAR_POS_X_1-1'b1)) % 8) - 11'd1])
            pixel_data <= BLACK;        //��ʾ�ַ�Ϊ��ɫ
        else
            pixel_data <= WHITE;        //��ʾ�ַ����򱳾�Ϊ��ɫ
    end
    
    //�ڵ�һ����ʾ��İ�λ �̶�ֵ"0"
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
    
    //�ڵ�һ����ʾ���ʮλ
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
    
    //�ڵ�һ����ʾ��ĸ�λ
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
    
    //�ڵ�һ����ʾ�ո�
    else if((pixel_xpos >= CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 4 - 1'b1)
         && (pixel_xpos <  CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 5 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_1)
         && (pixel_ypos <  CHAR_POS_Y_1 + CHAR_HEIGHT))
        pixel_data <= WHITE;
    
    //�ڵ�һ����ʾ�µ�ʮλ
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
    
    //�ڵ�һ����ʾ�µĸ�λ
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
    
    //�ڵ�һ����ʾ�ո�
    else if((pixel_xpos >= CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 7 - 1'b1)
         && (pixel_xpos <  CHAR_POS_X_1 + CHAR_WIDTH_1 / 10 * 8 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_1)
         && (pixel_ypos <  CHAR_POS_Y_1 + CHAR_HEIGHT))
        pixel_data <= WHITE;

    
    //�ڵ�һ����ʾ�յ�ʮλ
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
    
    //�ڵ�һ����ʾ�յĸ�λ
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
    
    //�ڵڶ�����ʾʱ��ʮλ
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
    
    //�ڵڶ�����ʾʱ�ĸ�λ
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
    
    //�ڵڶ�����ʾ�ո�
    else if((pixel_xpos >= CHAR_POS_X_2 + CHAR_WIDTH_2 / 8 * 2 - 1'b1)
         && (pixel_xpos <  CHAR_POS_X_2 + CHAR_WIDTH_2 / 8 * 3 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_2)
         && (pixel_ypos <  CHAR_POS_Y_2 + CHAR_HEIGHT))
        pixel_data <= WHITE;
    
    //�ڵڶ�����ʾ�ֵ�ʮλ
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
    
    //�ڵڶ�����ʾ�ֵĸ�λ
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
    
    //�ڵڶ�����ʾ�ո�
    else if((pixel_xpos >= CHAR_POS_X_2 + CHAR_WIDTH_2 / 8 * 5 - 1'b1)
         && (pixel_xpos <  CHAR_POS_X_2 + CHAR_WIDTH_2 / 8 * 6 - 1'b1)
         && (pixel_ypos >= CHAR_POS_Y_2)
         && (pixel_ypos <  CHAR_POS_Y_2 + CHAR_HEIGHT))
        pixel_data <= WHITE;
    
    //�ڵڶ�����ʾ���ʮλ
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
    
    //�ڵڶ�����ʾ��ĸ�λ    
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
        pixel_data <= WHITE;    //��Ļ����Ϊ��ɫ
end

endmodule 
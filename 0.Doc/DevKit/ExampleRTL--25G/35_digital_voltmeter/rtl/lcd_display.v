//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com 
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           lcd_display
// Last modified Date:  2019/1/30 11:12:36
// Last Version:        V1.1
// Descriptions:        RGB LCD��ʾģ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/5/29 10:55:56
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
// Modified by:         ����ԭ��
// Modified date:       2019/5/30 11:12:36
// Version:             V1.1
// Descriptions:        
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module lcd_display(
    input                lcd_pclk           ,
    input                rst_n              ,
    //��������
    input                data_symbol        , //��ѹֵ����λ������ѹ���λ��ʾ���� ,��ֵ��ʾ�ո�                 
    input        [7:0]   data_percentiles   , //��ѹֵС�����ڶ�λ                                
    input        [7:0]   data_decile        , //��ѹֵС������һλ                                
    input        [7:0]   data_units         , //��ѹֵ�ĸ�λ��                                   
    input        [7:0]   data_tens          , //��ѹֵ��ʮλ��  
    //LCD���ݽӿ�                           
    input        [10:0]  pixel_xpos         , //���ص������
    input        [10:0]  pixel_ypos         , //���ص�������
    output  reg  [23:0]  pixel_data           //���ص�����
);

//parameter define
localparam CHAR_POS_X_1  = 11'd1;  //��1���ַ�������ʼ�������
localparam CHAR_POS_Y_1  = 11'd1;  //��1���ַ�������ʼ��������
localparam CHAR_POS_X_2  = 11'd17; //��2���ַ�������ʼ�������
localparam CHAR_POS_Y_2  = 11'd17; //��2���ַ�������ʼ��������
localparam CHAR_WIDTH_1  = 11'd56; //һ��7���ַ��ܿ��Ϊ56
localparam CHAR_HEIGHT   = 11'd16; //�����ַ��ĸ߶�
localparam WHITE  = 24'hffffff;    //����ɫ,��ɫ
localparam BLACK  = 24'h000000;    //�ַ���ɫ,��ɫ

//reg define
reg  [127:0]  char  [12:0] ;        //�ַ�����

//*****************************************************
//**                    main code
//*****************************************************

//�ַ������ʼֵ,���ڴ洢��ģ����(��ȡģ�������,�������������С:8*16)
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

//��ͬ��������Ʋ�ͬ����������
always @(posedge lcd_pclk or negedge rst_n ) begin
    if (!rst_n)  begin
        pixel_data <= BLACK;
    end
    
    //��ʾ����λ
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
     
    //��ʾ��ѹֵ��ʮλ��
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
    
    //��ʾ��ѹֵ�ĸ�λ�� 
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
    
    //��ʾ�̶�����С����
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
    
    //��ʾ��ѹֵС������һλ 
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
    
    //��ʾ��ѹֵС�����ڶ�λ 
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
        pixel_data <= WHITE;    //��Ļ����Ϊ��ɫ
    end
end

endmodule 
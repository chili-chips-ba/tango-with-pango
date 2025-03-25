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
// Last modified Date:  2019/8/07 10:41:06
// Last Version:        V1.1
// Descriptions:        RGB LCD�ַ�����ʾ
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/8/07 10:41:06
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module lcd_display(
    input             lcd_pclk,     //ʱ��
    input             rst_n,        //��λ���͵�ƽ��Ч
                                    
    input      [10:0] pixel_xpos,   //���ص������
    input      [10:0] pixel_ypos,   //���ص�������    
    output reg [23:0] pixel_data    //���ص�����,
);                                   
                                     
//parameter define                   
localparam PIC_X_START = 11'd10;     //ͼƬ��ʼ�������
localparam PIC_Y_START = 11'd10;     //ͼƬ��ʼ��������
localparam PIC_WIDTH   = 11'd100;    //ͼƬ���
localparam PIC_HEIGHT  = 11'd100;    //ͼƬ�߶�
                       
localparam CHAR_X_START= 11'd10;     //�ַ���ʼ�������
localparam CHAR_Y_START= 11'd120;    //�ַ���ʼ��������
localparam CHAR_WIDTH  = 11'd128;    //�ַ����,4���ַ�:32*4
localparam CHAR_HEIGHT = 11'd32;     //�ַ��߶�
                       
localparam BACK_COLOR  = 24'hE0FFFF; //����ɫ��ǳ��ɫ
localparam CHAR_COLOR  = 24'hff0000; //�ַ���ɫ����ɫ

//reg define
reg   [127:0] char[31:0];  //�ַ�����
reg   [13:0]  rom_addr  ;  //ROM��ַ

//wire define   
wire  [10:0]  x_cnt;       //�����������
wire  [10:0]  y_cnt;       //�����������
wire          rom_rd_en ;  //ROM��ʹ���ź�
wire  [23:0]  rom_rd_data ;//ROM����

//*****************************************************
//**                    main code
//*****************************************************

assign  x_cnt = pixel_xpos + 1'b1  - CHAR_X_START; //���ص�������ַ�������ʼ��ˮƽ����
assign  y_cnt = pixel_ypos - CHAR_Y_START; //���ص�������ַ�������ʼ�㴹ֱ����
assign  rom_rd_en = 1'b1;                  //��ʹ�����ߣ���һֱ��ROM����

//���ַ����鸳ֵ����ʾ���֡�����ԭ�ӡ���ÿ�����ִ�СΪ32*32
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

//ΪLCD��ͬ��ʾ�������ͼƬ���ַ��ͱ���ɫ
always @(posedge lcd_pclk or negedge rst_n) begin
    if (!rst_n)
        pixel_data <= BACK_COLOR;
    else if( (pixel_xpos >= PIC_X_START - 1'b1) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 1'b1) 
          && (pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT) )
        pixel_data <= rom_rd_data ;  //��ʾͼƬ
    else if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
         && (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT)) begin
        if(char[y_cnt][CHAR_WIDTH -1'b1 - x_cnt])
            pixel_data <= CHAR_COLOR;    //��ʾ�ַ�
        else
            pixel_data <= BACK_COLOR;    //��ʾ�ַ�����ı���ɫ
    end
    else
        pixel_data <= BACK_COLOR;        //��Ļ����ɫ
end

//���ݵ�ǰɨ���ĺ�������ΪROM��ַ��ֵ
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n)
        rom_addr <= 14'd0;
    //����������λ��ͼƬ��ʾ����ʱ,�ۼ�ROM��ַ    
    else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT) 
        && (pixel_xpos >= PIC_X_START - 2'd2) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 2'd2)) 
        rom_addr <= rom_addr + 1'b1;
    //����������λ��ͼƬ�������һ�����ص�ʱ,ROM��ַ����    
    else if((pixel_ypos >= PIC_Y_START + PIC_HEIGHT))
        rom_addr <= 14'd0;
end

//ROM���洢ͼƬ
blk_mem_gen_0 blk_mem_gen_0 (
  .addr        (rom_addr),          // input [13:0]
  .clk        (lcd_pclk),            // input
  .rst        (1'b0),            // input
  .rd_data    (rom_rd_data)     // output [23:0]
);
endmodule 
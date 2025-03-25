//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com 
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved	                               
//----------------------------------------------------------------------------------------
// File name:           vga_display
// Last modified Date:  2018/1/30 11:12:36
// Last Version:        V1.1
// Descriptions:        vga�����ƶ���ʾģ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2018/1/29 10:55:56
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
// Modified by:		    ����ԭ��
// Modified date:	    2018/1/30 11:12:36
// Version:			    V1.1
// Descriptions:	    ��ʾһ����������Ļ���ƶ��������߿������ԳƷ�������ƶ�
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module  video_display(
    input             pixel_clk,                //VGA����ʱ��
    input             sys_rst_n,                //��λ�ź�
    
    input      [10:0] pixel_xpos,               //���ص������
    input      [10:0] pixel_ypos,               //���ص�������    
    output reg [23:0] pixel_data                //���ص�����
    );    

//parameter define    
parameter  H_DISP  = 11'd1280;                  //�ֱ���--��
parameter  V_DISP  = 11'd720;                   //�ֱ���--��
parameter  DIV_CNT = 22'd750000;				//��Ƶ������

localparam SIDE_W  = 11'd40;                    //��Ļ�߿���
localparam BLOCK_W = 11'd40;                    //������
localparam BLUE    = 24'h0000ff;    			//��Ļ�߿���ɫ ��ɫ
localparam WHITE   = 24'hffffff;    			//������ɫ ��ɫ
localparam BLACK   = 24'h000000;    			//������ɫ ��ɫ


//reg define
reg [10:0] block_x = SIDE_W ;                   //�������ϽǺ�����
reg [10:0] block_y = SIDE_W ;                   //�������Ͻ�������
reg [21:0] div_cnt;                             //ʱ�ӷ�Ƶ������
reg        h_direct;                            //����ˮƽ�ƶ�����1�����ƣ�0������
reg        v_direct;                            //������ֱ�ƶ�����1�����£�0������

//wire define   
wire move_en;                                   //�����ƶ�ʹ���źţ�Ƶ��Ϊ100hz

//*****************************************************
//**                    main code
//*****************************************************
assign move_en = (div_cnt == DIV_CNT) ? 1'b1 : 1'b0;

//ͨ����div����ʱ�Ӽ�����ʵ��ʱ�ӷ�Ƶ
always @(posedge pixel_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n)
        div_cnt <= 22'd0;
    else begin
        if(div_cnt < DIV_CNT) 
            div_cnt <= div_cnt + 1'b1;
        else
            div_cnt <= 22'd0;                   //������10ms������
    end
end

//�������ƶ����߽�ʱ���ı��ƶ�����
always @(posedge pixel_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) begin
        h_direct <= 1'b1;                       //�����ʼˮƽ�����ƶ�
        v_direct <= 1'b1;                       //�����ʼ��ֱ�����ƶ�
    end
    else begin
        if(block_x == SIDE_W + 1'b1)            //������߽�ʱ��ˮƽ����
            h_direct <= 1'b1;               
        else                                    //�����ұ߽�ʱ��ˮƽ����
        if(block_x == H_DISP - SIDE_W - BLOCK_W + 1'b1)
            h_direct <= 1'b0;               
        else
            h_direct <= h_direct;
            
        if(block_y == SIDE_W + 1'b1)            //�����ϱ߽�ʱ����ֱ����
            v_direct <= 1'b1;                
        else                                    //�����±߽�ʱ����ֱ����
        if(block_y == V_DISP - SIDE_W - BLOCK_W + 1'b1)
            v_direct <= 1'b0;               
        else
            v_direct <= v_direct;
    end
end

//���ݷ����ƶ����򣬸ı����ݺ�����
always @(posedge pixel_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) begin
        block_x <= SIDE_W + 1'b1;                     //�����ʼλ�ú�����
        block_y <= SIDE_W + 1'b1;                     //�����ʼλ��������
    end
    else if(move_en) begin
        if(h_direct) 
            block_x <= block_x + 1'b1;          //���������ƶ�
        else
            block_x <= block_x - 1'b1;          //���������ƶ�
            
        if(v_direct) 
            block_y <= block_y + 1'b1;          //���������ƶ�
        else
            block_y <= block_y - 1'b1;          //���������ƶ�
    end
    else begin
        block_x <= block_x;
        block_y <= block_y;
    end
end

//����ͬ��������Ʋ�ͬ����ɫ
always @(posedge pixel_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) 
        pixel_data <= BLACK;
    else begin
        if(  (pixel_xpos < SIDE_W) || (pixel_xpos >= H_DISP - SIDE_W)
          || (pixel_ypos <= SIDE_W) || (pixel_ypos > V_DISP - SIDE_W))
            pixel_data <= BLUE;                 //������Ļ�߿�Ϊ��ɫ
        else
        if(  (pixel_xpos >= block_x - 1'b1) && (pixel_xpos < block_x + BLOCK_W - 1'b1)
          && (pixel_ypos >= block_y) && (pixel_ypos < block_y + BLOCK_W))
            pixel_data <= BLACK;                //���Ʒ���Ϊ��ɫ
        else
            pixel_data <= WHITE;                //���Ʊ���Ϊ��ɫ
    end
end

endmodule 
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
// Last modified Date:  2020/05/04 9:19:08
// Last Version:        V1.0
// Descriptions:        lcd��ʾģ��
//                      
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/05/04 9:19:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module video_display(
    input             pixel_clk,                //����ʱ��
    input             sys_rst_n,                //��λ�ź�
 
    input      [10:0] pixel_xpos,               //���ص������
    input      [10:0] pixel_ypos,               //���ص�������   
    input      [15:0] cmos_data,                //CMOS���������ص�����
    input      [10:0] h_disp,                   //LCD��ˮƽ�ֱ���
    input      [10:0] v_disp,                   //LCD����ֱ�ֱ���   
    
    output     [15:0] pixel_data,               //���ص�����
    output            data_req                  //�������ص���ɫ��������
    );    

//parameter define  
parameter  V_CMOS_DISP = 11'd480;                //CMOS�ֱ��ʡ�����
parameter  H_CMOS_DISP = 11'd640;                //CMOS�ֱ��ʡ�����

localparam BLACK  = 16'b00000_000000_00000;      //RGB565 ��ɫ

//reg define   
reg             data_val            ;            //������Ч�ź�

//wire define
wire    [10:0]  display_border_pos_l;            //���߽�ĺ�����
wire    [10:0]  display_border_pos_r;            //�Ҳ�߽�ĺ�����
wire    [10:0]  display_border_pos_t;            //�϶˱߽��������
wire    [10:0]  display_border_pos_b;            //�¶˱߽��������

//*****************************************************
//**                    main code
//*****************************************************

//���߽�ĺ�������� 
assign display_border_pos_l  = (h_disp - H_CMOS_DISP)/2-1;

//�Ҳ�߽�ĺ�������� 
assign display_border_pos_r = H_CMOS_DISP + (h_disp - H_CMOS_DISP)/2-1;

//�϶˱߽����������� 
assign display_border_pos_t  = (v_disp - V_CMOS_DISP)/2;

//�¶˱߽�����������
assign display_border_pos_b = V_CMOS_DISP + (v_disp - V_CMOS_DISP)/2;

//�������ص���ɫ�������� ��Χ:79~718����640��ʱ������
assign data_req = ((pixel_xpos >= display_border_pos_l) &&
                  (pixel_xpos < display_border_pos_r) &&
                  (pixel_ypos > display_border_pos_t) &&
                  (pixel_ypos <= display_border_pos_b)
                  ) ? 1'b1 : 1'b0;

//��������Ч��Χ�ڣ�������ͷ�ɼ������ݸ�ֵ��LCD���ص�����
assign pixel_data = data_val ? cmos_data : BLACK;

//��Ч�����ͺ��������ź�һ��ʱ������,����������Ч�ź��ڴ���ʱһ��
always @(posedge pixel_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        data_val <= 1'b0;
    else
        data_val <= data_req;    
end    

endmodule
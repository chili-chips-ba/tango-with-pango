//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           binary2bcd
// Created by:          ����ԭ��
// Created date:        2023��2��3��14:17:02
// Version:             V1.0
// Descriptions:        binary2bcd
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module binary2bcd(
    input   wire             sys_clk,
    input   wire             sys_rst_n,
    input   wire    [7:0]    data,
    
    output  reg     [7:0]    bcd_data       //ʮ��������ֵ
);
//parameter define
parameter   CNT_SHIFT_NUM = 7'd8;  //��data��λ�����
//reg define
reg [6:0]       cnt_shift;         //��λ�жϼ�������ֵ��data��λ��
reg [15:0]      data_shift;        //��λ�ж����ݼĴ�������data��bcddata��λ��֮�;�����
reg             shift_flag;        //��λ�жϱ�־�ź�

//*****************************************************
//**                    main code                      
//*****************************************************

//cnt_shift����
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)
        cnt_shift <= 7'd0;
    else if((cnt_shift == CNT_SHIFT_NUM + 1) && (shift_flag))
        cnt_shift <= 7'd0;
    else if(shift_flag)
        cnt_shift <= cnt_shift + 1'b1;
    else
        cnt_shift <= cnt_shift;
end

//data_shift ������Ϊ0ʱ����ֵ��������Ϊ1~CNT_SHIFT_NUMʱ������λ����
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)
        data_shift <= 16'd0;
    else if(cnt_shift == 7'd0)
        data_shift <= {8'b0,data};
    else if((cnt_shift <= CNT_SHIFT_NUM)&&(!shift_flag))begin
        data_shift[11:8] <= (data_shift[11:8] > 4) ? (data_shift[11:8] + 2'd3):(data_shift[11:8]);
        data_shift[15:12] <= (data_shift[15:12] > 4) ? (data_shift[15:12] + 2'd3):(data_shift[15:12]);
        end
    else if((cnt_shift <= CNT_SHIFT_NUM)&&(shift_flag))
        data_shift <= data_shift << 1;
    else
        data_shift <= data_shift;
end

//shift_flag ��λ�жϱ�־�źţ����ڿ�����λ�жϵ��Ⱥ�˳��
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)
        shift_flag <= 1'b0;
    else
        shift_flag <= ~shift_flag;
end

//������������CNT_SHIFT_NUMʱ����λ�жϲ�����ɣ��������
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)
        bcd_data <= 16'd0;
    else if(cnt_shift == CNT_SHIFT_NUM + 1)
        bcd_data <= data_shift[15:8];
    else
        bcd_data <= bcd_data;
end

endmodule

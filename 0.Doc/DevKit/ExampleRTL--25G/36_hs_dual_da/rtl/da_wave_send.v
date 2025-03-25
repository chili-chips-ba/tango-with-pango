//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           da_wave_send
// Last modified Date:  2019/07/31 17:04:35
// Last Version:        V1.0
// Descriptions:        DA�������ݷ���ģ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/07/31 17:04:35
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module da_wave_send(
    input                 clk         ,  //ʱ��
    input                 rst_n       ,  //��λ�źţ��͵�ƽ��Ч
    
    input        [9:0]    rd_data     ,  //ROM����������
    output  reg  [9:0]    rd_addr     ,  //��ROM��ַ
    //DAоƬ�ӿ�
    output                da_clk      ,  //DAC����ʱ��
    output       [9:0]    da_data        //�����DA������  
    );

//parameter
//Ƶ�ʵ��ڿ���
parameter  FREQ_ADJ = 8'd5;  //Ƶ�ʵ���,FREQ_ADJ��Խ��,���������Ƶ��Խ��,��Χ0~255

//reg define
reg    [7:0]    freq_cnt  ;  //Ƶ�ʵ��ڼ�����

//*****************************************************
//**                    main code
//*****************************************************

//����rd_data����clk�������ظ��µģ�����DAоƬ��clk���½��������������ȶ���ʱ��
//��DAʵ������da_clk����������������,����ʱ��ȡ��,����clk���½����൱��da_clk��������
assign  da_clk = ~clk;        
assign  da_data = rd_data;    //��������ROM���ݸ�ֵ��DA���ݶ˿�

//Ƶ�ʵ��ڼ�����
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)
        freq_cnt <= 8'd0;
    else if(freq_cnt == FREQ_ADJ)
        freq_cnt <= 8'd0;
    else         
        freq_cnt <= freq_cnt + 8'd1;
end

//��ROM��ַ
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)
        rd_addr <= 10'd0;
    else begin
        if((freq_cnt == FREQ_ADJ) && (rd_addr < 10'd1023))
            rd_addr <= rd_addr + 10'd1;
        else if((freq_cnt == FREQ_ADJ) && (rd_addr == 10'd1023))
            rd_addr <= 10'd0;
        else
            rd_addr <= rd_addr;
    end            
end

endmodule
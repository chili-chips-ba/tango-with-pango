//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           da_wave_send
// Created by:          ����ԭ��
// Created date:        2023��5��31��14:17:02
// Version:             V1.0
// Descriptions:        DA�������ݷ���ģ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module da_wave_send(
    input                 clk            ,
    input                 rst_n          , //��λ�źţ��͵�ƽ��Ч
   //������İ���ֵ
    input                 key_wave_filter, //���ο��ư���������İ���ֵ
    input                 key_freq_filter, //Ƶ�ʿ��ư���������İ���ֵ
   //��rom
    input        [7:0]    rd_data        , //ROM����������
    output  reg  [8:0]    rd_addr        , //��ROM��ַ
    //DAоƬ�ӿ�                        
    output                da_clk         , //DAC����ʱ��
    output       [7:0]    da_data          //�����DA������  
    );

//parameter
//���ε��ڿ���
parameter  sine_wave_addr     = 9'd0  ; // ���Ҳ���ʼλ�� 
parameter  square_wave_addr   = 9'd100; // ������ʼλ��  
parameter  triangle_wave_addr = 9'd200; // ���ǲ���ʼλ��
parameter  sawtooth_wave_addr = 9'd300; // ��ݲ���ʼλ�� 

//Ƶ�ʵ��ڿ��ƣ�FREQ_ADJ��Խ��,���������Ƶ��Խ��,��Χ0~255
parameter  FREQ_ADJ0 = 8'd0;            //100MHzʱ���£�����0��Ӧ���1MHz����Ƶ��
parameter  FREQ_ADJ1 = 8'd1;            //100MHzʱ���£�����1��Ӧ���500KHz����Ƶ��
parameter  FREQ_ADJ2 = 8'd3;            //100MHzʱ���£�����3��Ӧ���250KHz����Ƶ��
parameter  FREQ_ADJ3 = 8'd7;            //100MHzʱ���£�����7��Ӧ���125KHz����Ƶ��

//reg define
reg              key_wave_filter_d0 ;
reg              key_wave_filter_d1 ;
reg              key_freq_filter_d0 ;
reg              key_freq_filter_d1 ;
reg    [7:0]     freq_adj           ;   //Ƶ�ʵ��ڲ����Ĵ���
reg    [7:0]     freq_cnt           ;   //Ƶ�ʵ��ڼ�����
reg    [1:0]     wave_select        /* synthesis PAP_MARK_DEBUG="true" */;   //����ѡ��Ĵ���
reg    [1:0]     freq_select        /* synthesis PAP_MARK_DEBUG="true" */;   //Ƶ��ѡ��Ĵ���

//wire define
wire             key_wave_filter_neg;   //���ο��ư����½���
wire             key_freq_filter_neg;   //Ƶ�ʿ��ư����½���
//*****************************************************
//**                    main code
//*****************************************************

//����rd_data����clk�������ظ��µģ�����DAоƬ��clk���½��������������ȶ���ʱ��
//��DAʵ������da_clk����������������,����ʱ��ȡ��,����clk���½����൱��da_clk��������
assign  da_clk  = ~clk   ;
assign  da_data = rd_data;  //��������ROM���ݸ�ֵ��DA���ݶ˿�
//ץȡ�������½���
assign  key_wave_filter_neg = (~key_wave_filter_d0) & key_wave_filter_d1;
assign  key_freq_filter_neg = (~key_freq_filter_d0) & key_freq_filter_d1;

//Ϊ��ץȡ�������½��أ��԰����źŴ�����
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        key_wave_filter_d0 <= 1'b1;
        key_wave_filter_d1 <= 1'b1;
        key_freq_filter_d0 <= 1'b1;
        key_freq_filter_d1 <= 1'b1;
    end
    else begin 
        key_wave_filter_d0 <= key_wave_filter;
        key_wave_filter_d1 <= key_wave_filter_d0;
        key_freq_filter_d0 <= key_freq_filter;
        key_freq_filter_d1 <= key_freq_filter_d0;
    end
end

//�л�����ѡ��Ĵ�����ֵ
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        wave_select <= 2'd0;
    //ȷ�����ο��ư���ȷʵ����Ч����
    else if(key_wave_filter_neg == 1) begin
        if(wave_select < 2'd3)
            wave_select <= wave_select+1'd1;
        else
            wave_select <= 0;
    end
    else 
        wave_select <= wave_select;
end

//�л�Ƶ��ѡ��Ĵ�����ֵ
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)
        freq_select <= 2'd0;
    //ȷ��Ƶ�ʿ��ư���ȷʵ����Ч����
    else if(key_freq_filter_neg == 1) begin
        if(freq_select < 2'd3)
            freq_select <= freq_select+1'd1;
        else  
            freq_select <= 0;
    end
    else 
        freq_select <= freq_select;
end

//ͨ��Ƶ��ѡ��Ĵ�����ֵ��ѡ����Ӧ��Ƶ�ʵ��ڲ���
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)
      freq_adj <= 8'd0;
    else begin
        case(freq_select)
            2'd0:freq_adj <= FREQ_ADJ0;    //1MHz����Ƶ��
            2'd1:freq_adj <= FREQ_ADJ1;    //500KHz����Ƶ��
            2'd2:freq_adj <= FREQ_ADJ2;    //250KHz����Ƶ��
            2'd3:freq_adj <= FREQ_ADJ3;    //125KHz����Ƶ��
            default:freq_adj <= FREQ_ADJ0; //1MHz����Ƶ��
        endcase
    end
end

//Ƶ�ʵ��ڼ�����
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)
        freq_cnt <= 8'd0;
    else if(freq_cnt >= freq_adj)
        freq_cnt <= 8'd0;
    else
        freq_cnt <= freq_cnt + 8'd1;
end

//��ROM��ַ
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)
        rd_addr <= 9'd0;
    else if(freq_cnt == freq_adj) begin
        case(wave_select)
            2'd0: begin//��ȡ���Ҳ�
                if((rd_addr >= sine_wave_addr) && (rd_addr <= sine_wave_addr+9'd99)) begin
                    if(rd_addr == sine_wave_addr+9'd99)  
                        rd_addr <= sine_wave_addr;
                    else 
                        rd_addr <= rd_addr+9'd1; 
                end
                else 
                    rd_addr <= sine_wave_addr;
            end
            2'd1: begin//��ȡ����
                if((rd_addr >= square_wave_addr) && (rd_addr <= square_wave_addr+9'd99)) begin
                    if(rd_addr == square_wave_addr+9'd99) 
                        rd_addr <= square_wave_addr;
                    else  
                        rd_addr <= rd_addr+9'd1;
                end
                else 
                    rd_addr <= square_wave_addr; 
            end
            2'd2: begin//��ȡ���ǲ�
                if((rd_addr >= triangle_wave_addr) && (rd_addr <= triangle_wave_addr+9'd99)) begin
                    if(rd_addr == triangle_wave_addr+9'd99) 
                        rd_addr <= triangle_wave_addr; 
                    else 
                        rd_addr <= rd_addr+9'd1;  
                end
                else  
                    rd_addr <= triangle_wave_addr;
            end
            2'd3: begin//��ȡ��ݲ�
                if((rd_addr >= sawtooth_wave_addr) && (rd_addr <= sawtooth_wave_addr+9'd99)) begin
                    if(rd_addr == sawtooth_wave_addr+9'd99)
                        rd_addr <= sawtooth_wave_addr;
                    else 
                        rd_addr <= rd_addr+9'd1;
                end
                else  
                    rd_addr <= sawtooth_wave_addr;
            end
            default: begin
                if((rd_addr >= sine_wave_addr) && (rd_addr <= sine_wave_addr+9'd99)) begin
                    if(rd_addr == sine_wave_addr+9'd99)
                        rd_addr <= sine_wave_addr;
                    else 
                        rd_addr <= rd_addr+9'd1; 
                end
                else 
                    rd_addr <= sine_wave_addr;
            end
        endcase
    end
         else
            rd_addr <= rd_addr;
end
endmodule

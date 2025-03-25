//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com 
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           img_data_pkt
// Last modified Date:  2020/2/18 9:20:14
// Last Version:        V1.0
// Descriptions:        ͼ���װģ��(���֡ͷ)    
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2020/2/18 9:20:14
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module img_data_pkt(
    input                 rst_n          ,   //��λ�źţ��͵�ƽ��Ч
    //ͼ������ź�
    input                 cam_pclk       ,   //����ʱ��
    input                 img_vsync      ,   //֡ͬ���ź�
    input                 img_data_en    ,   //������Чʹ���ź�
    input        [7 :0]   img_data       ,   //��Ч���� 
    
    input                 transfer_flag  ,   //ͼ��ʼ�����־,1:��ʼ���� 0:ֹͣ����
    //��̫������ź� 
    input                 eth_tx_clk     ,   //��̫������ʱ��
    input                 udp_tx_req     ,   //udp�������������ź�
    input                 udp_tx_done    ,   //udp������������ź�                               
    output  reg           udp_tx_start_en,   //udp��ʼ�����ź�
    output       [7 :0]   udp_tx_data    ,   //udp���͵�����
    output  reg  [15:0]   udp_tx_byte_num    //udp�������͵���Ч�ֽ���
    );    
    
//parameter define
parameter  CMOS_H_PIXEL = 16'd640;  //ͼ��ˮƽ����ֱ���
parameter  CMOS_V_PIXEL = 16'd480;  //ͼ��ֱ����ֱ���
//ͼ��֡ͷ,���ڱ�־һ֡���ݵĿ�ʼ
parameter  IMG_FRAME_HEAD = {32'hf0_5a_a5_0f};

reg             img_vsync_d0    ;  //֡��Ч�źŴ���
reg             img_vsync_d1    ;  //֡��Ч�źŴ���
reg             img_vsync_d2    ;  //֡��Ч�źŴ���

reg             img_data_en_d0  ;  //������Чʹ���ź�
reg    [7 :0]   img_data_d0     ;  //��Чͼ�����ݴ���
reg	   [3 :0]	head_cnt		;  //֡ͷ������	
reg				head_flag		;  //֡ͷ��־λ
reg             wr_fifo_en      ;  //дfifoʹ��
reg    [7 :0]   wr_fifo_data    ;  //дfifo����

reg             img_vsync_txc_d0;  //��̫������ʱ������,֡��Ч�źŴ���
reg             img_vsync_txc_d1;  //��̫������ʱ������,֡��Ч�źŴ���
reg             img_vsync_txc_d2;  //��̫������ʱ������,֡��Ч�źŴ���
reg             tx_busy_flag    ;  //����æ�źű�־
reg		[1:0]	bit_sel			;                                

//wire define                   
wire            pos_vsync       ;  //֡��Ч�ź�������
wire            neg_vsync       ;  //֡��Ч�ź��½���
wire            neg_vsynt_txc   ;  //��̫������ʱ������,֡��Ч�ź��½���
wire   [10:0]   fifo_rdusedw    ;  //��ǰFIFO����ĸ���

//*****************************************************
//**                    main code
//*****************************************************

//�źŲ���
assign neg_vsync = img_vsync_d2 & (~img_vsync_d1);
assign pos_vsync = ~img_vsync_d2 & img_vsync_d1;
assign neg_vsynt_txc = ~img_vsync_txc_d2 & img_vsync_txc_d1;

//��img_vsync�ź���ʱ����ʱ������,���ڲ���
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        img_vsync_d0 <= 1'b0;
        img_vsync_d1 <= 1'b0;
		img_vsync_d2 <= 1'b0;
    end
    else begin
        img_vsync_d0 <= img_vsync;
        img_vsync_d1 <= img_vsync_d0;
		img_vsync_d2 <= img_vsync_d1;
    end
end

//֡ͷ������
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
		head_cnt <= 4'd0;
	else if(neg_vsync)
		head_cnt <= 4'd0;
	else if(head_cnt == 4'd8)begin
		head_cnt <= head_cnt;
	end
	else
		head_cnt <= head_cnt + 4'd1;
end
		
//֡ͷ��־λ		
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
		head_flag <= 1'd0;
	else if(neg_vsync)
		head_flag <= 1'd1;
	else if(head_cnt == 4'd7)
		head_flag <= 1'd0;
	else ;
end
		
//ͬ��������Ч�źź���Ч����
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
		img_data_en_d0 <= 1'd0;
		img_data_d0 <= 8'd0;
	end
	else begin
		img_data_en_d0 <= img_data_en;
		img_data_d0 <= img_data;
	end
end	


//��֡ͷ��ͼ������д��FIFO
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        wr_fifo_en <= 1'b0;
        wr_fifo_data <= 8'd0;
    end
    else begin
		wr_fifo_en <= 1'b1;
        if(head_flag) begin
            wr_fifo_en <= 1'b1;
			if(head_cnt == 4'd0)
				wr_fifo_data <= IMG_FRAME_HEAD[31:24];               //֡ͷ
			else if(head_cnt == 4'd1)
				wr_fifo_data <= IMG_FRAME_HEAD[23:16];               //֡ͷ
			else if(head_cnt == 4'd2)
				wr_fifo_data <= IMG_FRAME_HEAD[15: 8];               //֡ͷ
			else if(head_cnt == 4'd3)
				wr_fifo_data <= IMG_FRAME_HEAD[ 7: 0];               //֡ͷ
			else if(head_cnt == 4'd4)
				wr_fifo_data <= CMOS_H_PIXEL[15: 8];               	 //ˮƽ����ֱ���
			else if(head_cnt == 4'd5)
				wr_fifo_data <= CMOS_H_PIXEL[ 7: 0];               	 //ˮƽ����ֱ���
			else if(head_cnt == 4'd6)
				wr_fifo_data <= CMOS_V_PIXEL[15: 8];               	 //��ֱ����ֱ���
			else if(head_cnt == 4'd7)
				wr_fifo_data <= CMOS_V_PIXEL[ 7: 0];               	 //��ֱ����ֱ���
			else ;	
        end
        else if(img_data_en_d0) begin
            wr_fifo_en <= 1'b1;
			wr_fifo_data <= img_data_d0;
        end
        else begin
            wr_fifo_en <= 1'b0;
            wr_fifo_data <= 8'd0;       
        end
    end
end

//��̫������ʱ������,��img_vsync�ź���ʱ����ʱ������,���ڲ���
always @(posedge eth_tx_clk or negedge rst_n) begin
    if(!rst_n) begin
        img_vsync_txc_d0 <= 1'b0;
        img_vsync_txc_d1 <= 1'b0;
		img_vsync_txc_d2 <= 1'b0;
    end
    else begin
        img_vsync_txc_d0 <= img_vsync;
        img_vsync_txc_d1 <= img_vsync_txc_d0;
		img_vsync_txc_d2 <= img_vsync_txc_d1;
    end
end

//������̫�����͵��ֽ���
always @(posedge eth_tx_clk or negedge rst_n) begin
    if(!rst_n)
        udp_tx_byte_num <= 1'b0;
    else if(neg_vsynt_txc)
        udp_tx_byte_num <= {CMOS_H_PIXEL,1'b0} + 16'd8;
    else if(udp_tx_done)    
        udp_tx_byte_num <= {CMOS_H_PIXEL,1'b0};
end

//������̫�����Ϳ�ʼ�ź�
always @(posedge eth_tx_clk or negedge rst_n) begin
    if(!rst_n) begin
        udp_tx_start_en <= 1'b0;
        tx_busy_flag <= 1'b0;
    end
    //��λ��δ����"��ʼ"����ʱ,��̫��������ͼ������
    else if(transfer_flag == 1'b0) begin
        udp_tx_start_en <= 1'b0;
        tx_busy_flag <= 1'b0;        
    end
    else begin
        udp_tx_start_en <= 1'b0;
        //��FIFO�еĸ���������Ҫ���͵��ֽ���ʱ
        if(tx_busy_flag == 1'b0 && fifo_rdusedw >= udp_tx_byte_num[15:0]) begin
            udp_tx_start_en <= 1'b1;                     //��ʼ���Ʒ���һ������
            tx_busy_flag <= 1'b1;
        end
        else if(udp_tx_done || neg_vsynt_txc) 
            tx_busy_flag <= 1'b0;
    end
end
  

async_fifo_2048x8b async_fifo_2048x8b_inst (
  .wr_clk        (cam_pclk),        // input
  .wr_rst        (pos_vsync | (~transfer_flag)),          // input
  .wr_en         (wr_fifo_en),      // input
  .wr_data       (wr_fifo_data),    // input [31:0]
  .wr_full       (),                // output
  .almost_full   (),                // output
  .rd_clk        (eth_tx_clk),      // input
  .rd_rst        (pos_vsync | (~transfer_flag)),          // input
  .rd_en         (udp_tx_req),      // input
  .rd_data       (udp_tx_data),     // output [31:0]
  .rd_empty      (),                // output
  .rd_water_level(fifo_rdusedw),    // output [10:0]
  .almost_empty  ()                 // output
);

endmodule
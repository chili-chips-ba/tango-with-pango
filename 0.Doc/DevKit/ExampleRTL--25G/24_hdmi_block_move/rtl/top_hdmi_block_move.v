//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com 
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           hdmi_block_move_top
// Last modified Date:  2018/1/30 11:12:36
// Last Version:        V1.1
// Descriptions:        HDMI�����ƶ�����ģ��
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
// Descriptions:	    ���ݵ�ǰ���ص�����ָ����ǰ���ص���ɫ������ʾ������ʾ����
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module  top_hdmi_block_move(
    input          sys_clk,
	input          sys_rst_n,
	output         tmds_clk_n,
    output         tmds_clk_p,
    output  [2:0]  tmds_data_n,
    output  [2:0]  tmds_data_p
);

//*****************************************************
//**                    main code
//*****************************************************

//wire define
wire          pixel_clk;
wire          pixel_clk_5x;
wire  [10:0]  pixel_xpos_w;
wire  [10:0]  pixel_ypos_w;
wire  [23:0]  pixel_data_w;
wire          video_hs;
wire          video_vs;
wire          video_de;
wire  [23:0]  video_rgb;

//����MMCM/PLL IP��
clk_wiz_0 clk_wiz_0 (
  .pll_rst(~sys_rst_n),      // input
  .clkin1(sys_clk),        // input
  .pll_lock( ),    // output
  .clkout0(pixel_clk),      // output pixel_clk_74_25m
  .clkout1(pixel_clk_5x)       // output pixel_clk_x5_371_25m
);

//����RGB��������ģ��
video_driver  u_video_driver(
    .pixel_clk      ( pixel_clk ),
    .sys_rst_n      ( sys_rst_n ),

    .video_hs       ( video_hs ),
    .video_vs       ( video_vs ),
    .video_de       ( video_de ),
    .video_rgb      ( video_rgb ),
	.data_req		(),

    .pixel_xpos     ( pixel_xpos_w ),
    .pixel_ypos     ( pixel_ypos_w ),
	.pixel_data     ( pixel_data_w )
);

//����RGB������ʾģ��
video_display  u_video_display(
    .pixel_clk      ( pixel_clk ),
    .sys_rst_n      ( sys_rst_n ),

    .pixel_xpos     ( pixel_xpos_w ),
    .pixel_ypos     ( pixel_ypos_w ),
    .pixel_data     ( pixel_data_w )
);

//����HDMI����ģ��
dvi_transmitter_top u_rgb2dvi_0(
    .pclk           (pixel_clk),
    .pclk_x5        (pixel_clk_5x),
    .reset_n        (sys_rst_n ),
                
    .video_din      (video_rgb),
    .video_hsync    (video_hs), 
    .video_vsync    (video_vs),
    .video_de       (video_de),
                
    .tmds_clk_p     (tmds_clk_p),
    .tmds_clk_n     (tmds_clk_n),
    .tmds_data_p    (tmds_data_p),
    .tmds_data_n    (tmds_data_n)                  
    );

endmodule
//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           sd_bmp_hdmi
// Last modified Date:  2020/11/22 15:16:38
// Last Version:        V1.0
// Descriptions:        SD����BMPͼƬHDMI��ʾ
//                      
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2020/11/22 15:16:38
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module sd_bmp_hdmi(    
    input                 sys_clk      ,  //ϵͳʱ��
    input                 sys_rst_n    ,  //ϵͳ��λ���͵�ƽ��Ч
    //SD���ӿ�
    input                 sd_miso      ,  //SD��SPI�������������ź�
    output                sd_clk       ,  //SD��SPIʱ���ź�
    output                sd_cs        ,  //SD��SPIƬѡ�ź�
    output                sd_mosi      ,  //SD��SPI������������ź�
    //DDR�������ӿ�
    output                  mem_rst_n       ,                       
    output                  mem_ck          ,
    output                  mem_ck_n        ,
    output                  mem_cke         ,
    output                  mem_ras_n       ,
    output                  mem_cas_n       ,
    output                  mem_we_n        , 
    output                  mem_odt         ,
    output                  mem_cs_n        ,
    output 	    [14:0]      mem_a           ,   
    output 	    [2:0]       mem_ba          ,   
    inout 	    [1:0]       mem_dqs         ,
    inout 	    [1:0]       mem_dqs_n       ,
    inout 	    [15:0]      mem_dq          ,
    output 	    [1:0]       mem_dm          ,									                              
    //HDMI �ӿ�
    output            tmds_clk_p    ,  // TMDS ʱ��ͨ��
    output            tmds_clk_n    ,
    output [2:0]      tmds_data_p   ,  // TMDS ����ͨ��
    output [2:0]      tmds_data_n   
    );   

//parameter define 
parameter  V_CMOS_DISP = 11'd768;                  //CMOS�ֱ���--��
parameter  H_CMOS_DISP = 11'd1024;                 //CMOS�ֱ���--��	
//DDR3��д����ַ 1024 * 768 = 786432
parameter  DDR_MAX_ADDR = 786432;  
//SD������������ 1024 * 768 * 3 / 512 + 1 = 4609
parameter  SD_SEC_NUM = 4609;       
	   							   
//wire define                          
wire         clk_50m                   ;  //50mhzʱ��,�ṩ��lcd����ʱ��
wire         clk_50m_180deg            ;
wire         locked                    ;  //ʱ�������ź�
wire         rst_n                     ;  //ȫ�ָ�λ 	
wire         pixel_clk                 ;  //����ʱ��75M
wire         pixel_clk_5x              ;  //5������ʱ��375M
wire         rd_vsync                  ;


wire         sd_rd_start_en            ;  //��ʼдSD�������ź�
wire  [31:0] sd_rd_sec_addr            ;  //������������ַ    
wire         sd_rd_busy                ;  //��æ�ź�
wire         sd_rd_val_en              ;  //���ݶ�ȡ��Чʹ���ź�
wire  [15:0] sd_rd_val_data            ;  //������
wire         sd_init_done              ;  //SD����ʼ������ź�	
wire         ddr_wr_en                 ;  //DDR3������ģ��дʹ��
wire  [15:0] ddr_wr_data               ;  //DDR3������ģ��д����

wire         wr_en                     ;  //DDR3������ģ��дʹ��
wire  [15:0] wr_data                   ;  //DDR3������ģ��д����
wire         rdata_req                 ;  //DDR3������ģ���ʹ��
wire  [15:0] rd_data                   ;  //DDR3������ģ�������
wire         init_calib_complete       ;  //DDR3��ʼ�����init_calib_complete
wire         sys_init_done             ;  //ϵͳ��ʼ�����(DDR��ʼ��+����ͷ��ʼ��)


//*****************************************************
//**                    main code
//*****************************************************

//��ʱ�������������λ�����ź�
assign  rst_n = sys_rst_n & locked;

//ϵͳ��ʼ����ɣ�DDR3��ʼ����� & SD����ʼ�����
assign  sys_init_done = init_calib_complete & sd_init_done;
//DDR3������ģ��Ϊдʹ�ܺ�д���ݸ�ֵ
assign  wr_en = ddr_wr_en;
assign  wr_data = ddr_wr_data;


//ʱ��IP��         
pll_clk u_pll_clk (
  .pll_rst      (1'b0  ),      // input
  .clkin1       (sys_clk    ),        // input
  .pll_lock     (locked     ),    // output
  .clkout0      (clk_50m    ),      // output
  .clkout1      (clk_50m_180deg),     // output
  .clkout2      (pixel_clk),      // output
  .clkout3      (pixel_clk_5x)       // output
);


//��ȡSD��ͼƬ
sd_read_photo u_sd_read_photo(
    .clk                   (clk_50m),
    //ϵͳ��ʼ�����֮��,�ٿ�ʼ��SD���ж�ȡͼƬ
    .rst_n                 (rst_n & sys_init_done), 
    .ddr_max_addr          (DDR_MAX_ADDR),       
    .sd_sec_num            (SD_SEC_NUM), 
    .rd_busy               (sd_rd_busy),
    .sd_rd_val_en          (sd_rd_val_en),
    .sd_rd_val_data        (sd_rd_val_data),
    .rd_start_en           (sd_rd_start_en),
    .rd_sec_addr           (sd_rd_sec_addr),
    .ddr_wr_en             (ddr_wr_en),
    .ddr_wr_data           (ddr_wr_data)
    );     

//SD���������ģ��
sd_ctrl_top u_sd_ctrl_top(
    .clk_ref                (clk_50m),
    .clk_ref_180deg         (clk_50m_180deg),
    .rst_n                  (rst_n),
    //SD���ӿ�
    .sd_miso                (sd_miso),
    .sd_clk                 (sd_clk),
    .sd_cs                  (sd_cs),
    .sd_mosi                (sd_mosi),
    //�û�дSD���ӿ�
    .wr_start_en            (1'b0),                      //����Ҫд������,д��ӿڸ�ֵΪ0
    .wr_sec_addr            (32'b0),
    .wr_data                (16'b0),
    .wr_busy                (),
    .wr_req                 (),
    //�û���SD���ӿ�
    .rd_start_en            (sd_rd_start_en),
    .rd_sec_addr            (sd_rd_sec_addr),
    .rd_busy                (sd_rd_busy),
    .rd_val_en              (sd_rd_val_en),
    .rd_val_data            (sd_rd_val_data),    
    
    .sd_init_done           (sd_init_done)
    );  

//DDR3ģ��               
ddr3_ctrl_top u_ddr3_ctrl_top(
    .clk             (clk_50m),
    .wd_clk          (clk_50m),
    .rd_clk          (pixel_clk),
    .rst_n           (rst_n),
    // �ⲿ���ݽӿ�   
    .wd_en           (wr_en),   //дʹ��
    .wd_data         (wr_data),   //д����
    .rd_en           (rdata_req),   //��ʹ��
    .rd_data         (rd_data),   //������
    .wr_load         (1'b0),   //����Դ�����ź�
    .rd_load         (rd_vsync),   //���Դ�����ź�
    .ddr3_pingpang_en(1'b1),   //DDR3ƹ�Ҳ���
    .ddr3_read_valid (1'b1),
    // ddr��ַ���ȿ��ƽӿ�                  
    .addr_rd_min     (28'd0),
    .addr_rd_max     (DDR_MAX_ADDR),
    .rd_burst_len    (H_CMOS_DISP[12:3]),
    .addr_wd_min     (28'd0),
    .addr_wd_max     (DDR_MAX_ADDR),
    .wd_burst_len    (H_CMOS_DISP[12:3]),
    .ddr3_init_done  (init_calib_complete),   //ddr3��ʼ����ɱ�־
    //DDR�������ӿ�
    .mem_rst_n       (mem_rst_n),                       
    .mem_ck          (mem_ck   ),
    .mem_ck_n        (mem_ck_n ),
    .mem_cke         (mem_cke  ),
    .mem_ras_n       (mem_ras_n),
    .mem_cas_n       (mem_cas_n),
    .mem_we_n        (mem_we_n ), 
    .mem_odt         (mem_odt  ),
    .mem_cs_n        (mem_cs_n ),
    .mem_a           (mem_a    ),   
    .mem_ba          (mem_ba   ),   
    .mem_dqs         (mem_dqs  ),
    .mem_dqs_n       (mem_dqs_n),
    .mem_dq          (mem_dq   ),
    .mem_dm          (mem_dm   )     
);

//HDMI����ģ��
hdmi_top u_hdmi_top(
    .pixel_clk      (pixel_clk      ),
    .pixel_clk_5x   (pixel_clk_5x   ),
    .sys_rst_n      (rst_n & sys_init_done ),
    //HDMI interface
    .tmds_clk_p     (tmds_clk_p     ),
    .tmds_clk_n     (tmds_clk_n     ),
    .tmds_data_p    (tmds_data_p    ),
    .tmds_data_n    (tmds_data_n    ),
    //user interface
    .data_in        (rd_data        ),
    .data_req       (rdata_req      ),
    .video_vs       (rd_vsync       ),
    .pixel_xpos     ( ),
    .pixel_ypos     ( )
);  

endmodule
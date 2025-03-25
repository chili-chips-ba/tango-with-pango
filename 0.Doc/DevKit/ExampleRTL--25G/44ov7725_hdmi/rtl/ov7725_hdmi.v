//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           ov7725_hdmi
// Last modified Date:  2020/05/04 9:19:08
// Last Version:        V1.0
// Descriptions:        ov7725_hdmi����ģ��
//                      
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/05/04 9:19:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ov7725_hdmi(
    input                   sys_clk          ,
    input                   sys_rst_n        ,
                                       
    output                  tmds_clk_p       ,  // TMDS ʱ��ͨ��
    output                  tmds_clk_n       ,
    output         [2:0]    tmds_data_p      ,  // TMDS ����ͨ��
    output         [2:0]    tmds_data_n      ,
    //����ͷ�ӿ�                     
    input                   cam_pclk         ,  //cmos ��������ʱ��
    input                   cam_vsync        ,  //cmos ��ͬ���ź�
    input                   cam_href         ,  //cmos ��ͬ���ź�
    input          [7:0]    cam_data         ,  //cmos ����
    output                  cam_rst_n        ,  //cmos ��λ�źţ��͵�ƽ��Ч
    output                  cam_sgm_ctrl     ,  //cmos ʱ��ѡ���ź�, 1:ʹ������ͷ�Դ��ľ���
    output                  cam_scl          ,  //cmos SCCB_SCL��
    inout                   cam_sda          ,  //cmos SCCB_SDA��
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
    output        [14:0]    mem_a           ,   
    output        [2:0]     mem_ba          ,   
    inout         [1:0]     mem_dqs         ,
    inout         [1:0]     mem_dqs_n       ,
    inout         [15:0]    mem_dq          ,
    output        [1:0]     mem_dm   
   );

//parameter define
parameter  APP_ADDR_MIN = 28'd0       ; //ddr3��д��ʼ��ַ����һ��16bit������Ϊһ����λ
parameter  APP_ADDR_MAX = 28'd307200  ; //ddr3��д������ַ����һ��16bit������Ϊһ����λ
parameter  V_CMOS_DISP = 11'd480;         //CMOS�ֱ���--��
parameter  H_CMOS_DISP = 11'd640;         //CMOS�ֱ���--��

//wire define
//PLL
wire        pixel_clk       ;  //����ʱ��75M
wire        pixel_clk_5x    ;  //5������ʱ��375M
wire        clk_50m         ;  //output 50M
wire        clk_locked      ;
//OV7725
wire        i2c_dri_clk     ;  //I2C����ʱ��
wire        i2c_done        ;  //I2C�Ĵ�����������ź�
wire        i2c_exec        ;  //I2C����ִ���ź�
wire [15:0] i2c_data        ;  //I2CҪ���õĵ�ַ������(��8λ��ַ,��8λ����)
wire        cam_init_done   ;  //����ͷ��ʼ�����
wire        cmos_frame_vsync;  //֡��Ч�ź�
wire        cmos_frame_href ;  //����Ч�ź�
wire        cmos_frame_valid;  //������Чʹ���ź�
wire [15:0] wr_data         ;  //OV7725д��DDR3������ģ�������
//HDMI
wire        video_vs        ;  //��ͬ���ź�
wire [15:0] rd_data         ;  //DDR3������ģ������ݸ�HDMI
wire        rdata_req       ;  //DDR3������ģ���ʹ��
//DDR3
wire        ddr3_init_done   ; //ddr3��ʼ�����

//*****************************************************
//**                    main code
//*****************************************************

//��ʱ�����������������λ�ź�
assign rst_n = sys_rst_n & clk_locked;

//ϵͳ��ʼ����ɣ�DDR3������ͷ����ʼ�����
//��������DDR3��ʼ��������������д������
assign  sys_init_done = ddr3_init_done;
 

//��������ͷӲ����λ,�̶��ߵ�ƽ
assign  cam_rst_n    = 1'b1;

//cmos ʱ��ѡ���ź�, 1:ʹ������ͷ�Դ��ľ���
assign  cam_sgm_ctrl = 1'b1;

//����PLL IP��
pll_clk  u_pll_clk(
    .pll_rst        (~sys_rst_n  ),
    .clkin1         (sys_clk     ),
    .clkout0        (pixel_clk   ), //����ʱ��75M
    .clkout1        (pixel_clk_5x), //5������ʱ��375M
    .clkout2        (clk_50m     ), //output 50M
    .pll_lock       (clk_locked  )
);

//OV7725����ģ��    
ov7725_dri u_ov7725_dri(
    .clk              (sys_clk          ),
    .rst_n            (rst_n            ),
    
    .cam_pclk         (cam_pclk         ),
    .cam_vsync        (cam_vsync        ),
    .cam_href         (cam_href         ),
    .cam_data         (cam_data         ),
    .cam_scl          (cam_scl          ),
    .cam_sda          (cam_sda          ),
    
    .capture_start    (ddr3_init_done    ),
    .cmos_frame_vsync (cmos_frame_vsync ),
    .cmos_frame_href  (cmos_frame_href  ),
    .cmos_frame_valid (cmos_frame_valid ),
    .cmos_frame_data  (wr_data           )
);

//ddr3
ddr3_ctrl_top u_ddr3_ctrl_top(
    .clk             (clk_50m),
    .wd_clk          (cam_pclk),
    .rd_clk          (pixel_clk),
    .rst_n           (rst_n),
    .ddr3_init_done  (ddr3_init_done),       //ddr3��ʼ����ɱ�־
    // �ⲿ���ݽӿ�   
    .wd_en           (cmos_frame_valid),       //дʹ��
    .wd_data         (wr_data),       //д����
    .rd_en           (rdata_req),       //��ʹ��
    .rd_data         (rd_data),       //������
    .wr_load         (cmos_frame_vsync),       //����Դ�����ź�
    .rd_load         (video_vs),       //���Դ�����ź�
    .ddr3_pingpang_en(1'b1),       //DDR3ƹ�Ҳ���
    .ddr3_read_valid (1'b1),
    // ddr��ַ���ȿ��ƽӿ�                  
    .addr_rd_min     (APP_ADDR_MIN),
    .addr_rd_max     (APP_ADDR_MAX),
    .rd_burst_len    (H_CMOS_DISP[10:3]),
    .addr_wd_min     (APP_ADDR_MIN),
    .addr_wd_max     (APP_ADDR_MAX),
    .wd_burst_len    (H_CMOS_DISP[10:3]),
    //DDR�������ӿ�
    .mem_rst_n       (mem_rst_n ),                       
    .mem_ck          (mem_ck    ),
    .mem_ck_n        (mem_ck_n  ),
    .mem_cke         (mem_cke   ),
    .mem_ras_n       (mem_ras_n ),
    .mem_cas_n       (mem_cas_n ),
    .mem_we_n        (mem_we_n  ), 
    .mem_odt         (mem_odt   ),
    .mem_cs_n        (mem_cs_n  ),
    .mem_a           (mem_a     ),   
    .mem_ba          (mem_ba    ),   
    .mem_dqs         (mem_dqs   ),
    .mem_dqs_n       (mem_dqs_n ),
    .mem_dq          (mem_dq    ),
    .mem_dm          (mem_dm    )     
);
//HDMI����ģ��
hdmi_top u_hdmi_top(
    .hdmi_clk        (pixel_clk ),
    .hdmi_clk_5      (pixel_clk_5x),
    .sys_rst_n       (rst_n&ddr3_init_done),
    //user interface 
    .rd_data         (rd_data   ),
    .rd_en           (rdata_req ),
    .video_vs        (video_vs  ),
    .pixel_xpos      ( ),
    .pixel_ypos      ( ),
    //HDMI interface     
    .tmds_clk_p      (tmds_clk_p),
    .tmds_clk_n      (tmds_clk_n),
    .tmds_data_p     (tmds_data_p),
    .tmds_data_n     (tmds_data_n)
);

endmodule
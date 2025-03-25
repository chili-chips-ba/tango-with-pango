//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ov7725_lcd
// Created by:          ����ԭ��
// Created date:        2023��9��14��19:26:07
// Version:             V1.0
// Descriptions:        ov7725_lcd
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ov7725_lcd(    
    input                 sys_clk      ,  //ϵͳʱ��
    input                 sys_rst_n    ,  //ϵͳ��λ���͵�ƽ��Ч
    //����ͷ�ӿ�                       
    input                 cam_pclk     ,  //cmos ��������ʱ��
    input                 cam_vsync    ,  //cmos ��ͬ���ź�
    input                 cam_href     ,  //cmos ��ͬ���ź�
    input   [7:0]         cam_data     ,  //cmos ����
    output                cam_rst_n    ,  //cmos ��λ�źţ��͵�ƽ��Ч
    output                cam_sgm_ctrl ,  //cmos ʱ��ѡ���ź�, 1:ʹ������ͷ�Դ��ľ���
    output                cam_scl      ,  //cmos SCCB_SCL��
    inout                 cam_sda      ,  //cmos SCCB_SDA��                      
    // DDR3                            
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
    output 	[14:0]          mem_a           ,   
    output 	[2:0]           mem_ba          ,   
    inout 	[1:0]           mem_dqs         ,
    inout 	[1:0]           mem_dqs_n       ,
    inout 	[15:0]          mem_dq          ,
    output 	[1:0]           mem_dm          ,
    //lcd�ӿ�                           
    output                lcd_hs       ,  //LCD ��ͬ���ź�
    output                lcd_vs       ,  //LCD ��ͬ���ź�
    output                lcd_de       ,  //LCD ��������ʹ��
    inout       [23:0]    lcd_rgb      ,  //LCD ��ɫ����
    output                lcd_bl       ,  //LCD ��������ź�
    output                lcd_rst      ,  //LCD ��λ�ź�
    output                lcd_pclk        //LCD ����ʱ��								   
    );                                 									 

//wire define                          
wire         clk_50m                   ;  //50mhzʱ��,�ṩ��lcd����ʱ��
wire         locked                    ;  //ʱ�������ź�
wire         rst_n                     ;  //ȫ�ָ�λ 								            
wire         cam_init_done             ;  //����ͷ��ʼ�����							    
wire         wr_en                     ;  //DDR3������ģ��дʹ��
wire  [15:0] wrdata                    ;  //DDR3������ģ��д����
wire         rdata_req                 ;  //DDR3������ģ���ʹ��
wire  [15:0] rddata                    ;  //DDR3������ģ�������
wire         cmos_frame_valid          ;  //������Чʹ���ź�
wire         init_calib_complete       ;  //DDR3��ʼ�����init_calib_complete
wire         sys_init_done             ;  //ϵͳ��ʼ�����(DDR3��ʼ��+����ͷ��ʼ��)
wire         clk_200m                  ;  //ddr3�ο�ʱ��
wire         cmos_frame_vsync          ;  //���֡��Ч��ͬ���ź�
wire         cmos_frame_href           ;  //���֡��Ч��ͬ���ź� 
wire  [10:0] h_disp                    ;  //LCD��ˮƽ�ֱ���
wire  [10:0] v_disp                    ;  //LCD����ֱ�ֱ���     
wire  [10:0] h_pixel                   ;  //����ddr3��ˮƽ�ֱ���        
wire  [10:0] v_pixel                   ;  //����ddr3������ֱ�ֱ��� 
wire  [15:0] lcd_id                    ;  //LCD����ID��
wire  [27:0] ddr3_addr_max             ;  //����DDR3������д��ַ 

//*****************************************************
//**                    main code
//*****************************************************

//��ʱ�����������������λ�ź�
assign  rst_n = sys_rst_n;

//ϵͳ��ʼ����ɣ�DDR3������ͷ����ʼ�����
//��������DDR3��ʼ��������������д������
assign  sys_init_done = init_calib_complete &cam_init_done;
                    
//��������ͷӲ����λ,�̶��ߵ�ƽ
assign  cam_rst_n = 1'b1;

//cmos ʱ��ѡ���ź�, 1:ʹ������ͷ�Դ��ľ���
assign  cam_sgm_ctrl = 1'b1;

//OV7725����ģ��    
ov7725_dri u_ov7725_dri(
    .clk                    (sys_clk),   
    .rst_n                  (rst_n),   
    .init_done              (cam_init_done),
    .cam_scl                (cam_scl),   
    .cam_sda                (cam_sda)   
);

//ͼ��ɼ�����ģ��
cmos_data_top u_cmos_data_top(
    .rst_n                 (rst_n & sys_init_done), //ϵͳ��ʼ�����֮���ٿ�ʼ�ɼ����� 
    .cam_pclk              (cam_pclk),
    .cam_vsync             (cam_vsync),
    .cam_href              (cam_href),
    .cam_data              (cam_data),
    .lcd_id                (lcd_id),  
    .h_disp                (h_disp),
    .v_disp                (v_disp),  
    .h_pixel               (h_pixel),
    .v_pixel               (v_pixel),
    .ddr3_addr_max         (ddr3_addr_max),    
    .cmos_frame_vsync      (cmos_frame_vsync),
    .cmos_frame_href       (cmos_frame_href),
    .cmos_frame_valid      (cmos_frame_valid),      //������Чʹ���ź�
    .cmos_frame_data       (wrdata)                //��Ч���� 
    );

// ddr3����ģ��
ddr3_ctrl_top u_ddr3_ctrl_top(
    .clk            (sys_clk        ),
    .rst_n          (rst_n      ),
    .ddr3_init_done (init_calib_complete),  //ddr��ʼ������ź�
    // �û��ӿ�
    .wd_clk         (cam_pclk       ),      //дʱ��
    .rd_clk         (lcd_clk        ),      //��ʱ��
    .wd_en          (cmos_frame_valid),     //������Чʹ���ź�
    .wd_data        (wrdata         ),      //д��Ч����
    .rd_en          (rdata_req      ),      //DDR3 ��ʹ��
    .rd_data        (rddata         ),      //rfifo�������
    .addr_rd_min    (28'b0          ),      //��DDR3����ʼ��ַ
    .addr_rd_max    (ddr3_addr_max  ),      //��DDR�Ľ�����ַ
    .rd_burst_len   (h_pixel[10:3]  ),      //��DDR3�ж����ݵ�ͻ������
    .addr_wd_min    (28'b0          ),      //дDDR3����ʼ��ַ
    .addr_wd_max    (ddr3_addr_max  ),      //дDDR�Ľ�����ַ
    .wd_burst_len   (h_pixel[10:3]  ),      //д��DDR3�����ݵ�ͻ������

    .wr_load        (cmos_frame_vsync),     //����Դ�����ź�
    .rd_load        (rd_vsync       ),      //���Դ�����ź�
    .ddr3_pingpang_en(1'b1),                //DDR3 ƹ�Ҳ���
    .ddr3_read_valid (1'b1),                //������������
    //DDR3 IO�ӿ�
    .mem_rst_n      (mem_rst_n      ),
    .mem_ck         (mem_ck         ),
    .mem_ck_n       (mem_ck_n       ),
    .mem_cke        (mem_cke        ),
    .mem_ras_n      (mem_ras_n      ),
    .mem_cas_n      (mem_cas_n      ),
    .mem_we_n       (mem_we_n       ),
    .mem_odt        (mem_odt        ),
    .mem_cs_n       (mem_cs_n       ),
    .mem_a          (mem_a          ),
    .mem_ba         (mem_ba         ),
    .mem_dqs        (mem_dqs        ),
    .mem_dqs_n      (mem_dqs_n      ),
    .mem_dq         (mem_dq         ),
    .mem_dm         (mem_dm         )
);

//LCD������ʾģ��
lcd_rgb_top  u_lcd_rgb_top(
	.sys_clk               (sys_clk  ),
    .sys_rst_n             (rst_n ),
	.sys_init_done         (sys_init_done),		

    //lcd�ӿ� 				           
    .lcd_id                (lcd_id),                //LCD����ID�� 
    .lcd_hs                (lcd_hs),                //LCD ��ͬ���ź�
    .lcd_vs                (lcd_vs),                //LCD ��ͬ���ź�
    .lcd_de                (lcd_de),                //LCD ��������ʹ��
    .lcd_rgb               (lcd_rgb),               //LCD ��ɫ����
    .lcd_bl                (lcd_bl),                //LCD ��������ź�
    .lcd_rst               (lcd_rst),               //LCD ��λ�ź�
    .lcd_pclk              (lcd_pclk),              //LCD ����ʱ��
    .lcd_clk               (lcd_clk), 	            //LCD ����ʱ��
	//�û��ӿ�			           
    .out_vsync             (rd_vsync),              //lcd���ź�
    .h_disp                (h_disp),                //�зֱ���  
    .v_disp                (v_disp),                //���ֱ���
    .pixel_xpos            (),
    .pixel_ypos            (),    
    .data_in               (rddata),	            //rfifo�������
    .data_req              (rdata_req)              //������������
    );
                          
endmodule
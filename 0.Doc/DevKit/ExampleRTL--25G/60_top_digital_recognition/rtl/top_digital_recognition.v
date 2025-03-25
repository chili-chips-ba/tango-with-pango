//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           top_digital_recognition
// Created by:          ����ԭ��
// Created date:        2023��2��3��14:17:02
// Version:             V1.0
// Descriptions:        top_digital_recognition
//
//----------------------------------------------------------------------------------------
//****************************************************************************************///

module top_digital_recognition(    
    input                 sys_clk       ,  //ϵͳʱ��
    input                 sys_rst_n     ,  //ϵͳ��λ���͵�ƽ��Ч
    //����ͷ�ӿ�                       
    input                 cam_pclk      ,  //cmos ��������ʱ��
    input                 cam_vsync     ,  //cmos ��ͬ���ź�
    input                 cam_href      ,  //cmos ��ͬ���ź�
    input       [7:0]     cam_data      ,  //cmos ����
    output                cam_rst_n     ,  //cmos ��λ�źţ��͵�ƽ��Ч
    output                cam_pwdn      ,  //��Դ����ģʽѡ�� 0������ģʽ 1����Դ����ģʽ
    output                cam_scl       ,  //cmos SCCB_SCL��
    inout                 cam_sda       ,  //cmos SCCB_SDA��       
    // DDR3                            
    output                mem_rst_n     ,                       
    output                mem_ck        ,
    output                mem_ck_n      ,
    output                mem_cke       ,
    output                mem_ras_n     ,
    output                mem_cas_n     ,
    output                mem_we_n      , 
    output                mem_odt       ,
    output                mem_cs_n      ,
    output      [14:0]    mem_a         ,   
    output      [2:0]     mem_ba        ,   
    inout       [1:0]     mem_dqs       ,
    inout       [1:0]     mem_dqs_n     ,
    inout       [15:0]    mem_dq        ,
    output      [1:0]     mem_dm        ,									   
    //lcd�ӿ�                           
    output                lcd_hs        ,  //LCD ��ͬ���ź�
    output                lcd_vs        ,  //LCD ��ͬ���ź�
    output                lcd_de        ,  //LCD ��������ʹ��
    inout       [23:0]    lcd_rgb       ,  //LCD ��ɫ����
    output                lcd_bl        ,  //LCD ��������ź�
    output                lcd_rst       ,  //LCD ��λ�ź�
    output                lcd_pclk         //LCD ����ʱ��

    );                                 

//wire define                          
wire         locked               ;  //ʱ�������ź�
wire  [15:0] wrdata               ;  //DDR3������ģ��д����
wire         rdata_req            ;  //DDR3������ģ���ʹ��
wire  [15:0] rddata               ;  //DDR3������ģ�������
wire         cmos_frame_valid     ;  //������Чʹ���ź�
wire         ddr3_init_done       ;  //DDR3��ʼ�����ddr3_init_done
wire         sys_init_done        ;  //ϵͳ��ʼ�����(DDR��ʼ��+����ͷ��ʼ��)
wire         cmos_frame_vsync     ;  //���֡��Ч��ͬ���ź�
wire         cmos_frame_href      ;  //���֡��Ч��ͬ���ź� 
wire         lcd_clk              ;  //��Ƶ������LCD ����ʱ��
wire  [12:0] h_disp               ;  //LCD��ˮƽ�ֱ���
wire  [12:0] v_disp               ;  //LCD����ֱ�ֱ���     
wire  [10:0] h_pixel              ;  //����ddr3��ˮƽ�ֱ���        
wire  [10:0] v_pixel              ;  //����ddr3������ֱ�ֱ���
wire  [12:0] y_addr_st            ; 
wire  [12:0] y_addr_end           ;
wire  [15:0] lcd_id               ;  //LCD����ID��
wire  [27:0] ddr3_addr_max        ;  //����DDR3������д��ַ             
wire  [12:0] total_h_pixel        ;  //ˮƽ�����ش�С 
wire  [12:0] total_v_pixel        ;  //��ֱ�����ش�С
wire         hs_t                 ;
wire         vs_t                 ;
wire         de_t                 ;
wire  [15:0] color_rgb            ;
wire  [10:0] pixel_xpos           ;  //���ص������
wire  [10:0] pixel_ypos           ;  //���ص�������
wire  [15:0] post_rgb             ;  //������ͼ������
wire  [23:0] digit                ;  //ʶ�𵽵�����

//*****************************************************
//**                    main code
//*****************************************************

//����ͷͼ��ֱ�������ģ��
picture_size u_picture_size (
    .rst_n             (sys_rst_n   ),
    .clk               (sys_clk     ),    
    .lcd_id            (lcd_id      ),      //LCD������ID

    .cmos_h_pixel      (h_disp      ),      //����ͷˮƽ�ֱ���480
    .cmos_v_pixel      (v_disp      ),      //����ͷ��ֱ�ֱ���272  
    .total_h_pixel     (total_h_pixel),     //ˮƽ�����ش�С
    .total_v_pixel     (total_v_pixel),     //��ֱ�����ش�С
    .y_addr_st         (y_addr_st   ), 
    .y_addr_end        (y_addr_end  ),
    .ddr3_addr_max     (ddr3_addr_max)      //ddr3����д��ַ
);

//ov5640 ����
ov5640_dri u_ov5640_dri(
    .clk               (sys_clk     ),
    .rst_n             (sys_rst_n   ),

    .cam_pclk          (cam_pclk    ),
    .cam_vsync         (cam_vsync   ),
    .cam_href          (cam_href    ),
    .cam_data          (cam_data    ),
    .cam_rst_n         (cam_rst_n   ),
    .cam_pwdn          (cam_pwdn    ),
    .cam_scl           (cam_scl     ),
    .cam_sda           (cam_sda     ),
    
    .capture_start     (ddr3_init_done),
    .cmos_h_pixel      (h_disp      ),
    .cmos_v_pixel      (v_disp      ),
    .total_h_pixel     (total_h_pixel),
    .total_v_pixel     (total_v_pixel),
    .y_addr_st         (y_addr_st   ), 
    .y_addr_end        (y_addr_end),
    .cmos_frame_vsync  (cmos_frame_vsync),
    .cmos_frame_href   (),
    .cmos_frame_valid  (cmos_frame_valid),
    .cmos_frame_data   (wrdata)
);   

// ddr3����ģ��
ddr3_ctrl_top u_ddr3_ctrl_top(
    .clk            (sys_clk        ),
    .rst_n          (sys_rst_n      ),
    .ddr3_init_done (ddr3_init_done),  //ddr��ʼ������ź�
    // �û��ӿ�
    .wd_clk         (cam_pclk       ),      //дʱ��
    .rd_clk         (lcd_clk        ),      //��ʱ��
    .wd_en          (cmos_frame_valid),     //������Чʹ���ź�
    .wd_data        (wrdata         ),      //д��Ч����
    .rd_en          (rdata_req      ),      //DDR3 ��ʹ��
    .rd_data        (rddata         ),      //rfifo�������
    .addr_rd_min    (28'b0          ),      //��DDR3����ʼ��ַ
    .addr_rd_max    (ddr3_addr_max  ),      //��DDR�Ľ�����ַ
    .rd_burst_len   (h_disp[12:3]   ),      //��DDR3�ж����ݵ�ͻ������
    .addr_wd_min    (28'b0          ),      //дDDR3����ʼ��ַ
    .addr_wd_max    (ddr3_addr_max  ),      //дDDR�Ľ�����ַ
    .wd_burst_len   (h_disp[12:3]   ),      //д��DDR3�����ݵ�ͻ������

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
    .sys_rst_n             (sys_rst_n ),
	.sys_init_done         (ddr3_init_done),		
				           
    //lcd�ӿ� 				           
    .lcd_id                (lcd_id),                //LCD����ID�� 
    .lcd_hs                (hs_t),                  //LCD ��ͬ���ź�
    .lcd_vs                (vs_t),                  //LCD ��ͬ���ź�
    .lcd_de                (de_t),                  //LCD ��������ʹ��
    .lcd_rgb               (lcd_rgb),               //LCD ��ɫ����
    .lcd_bl                (lcd_bl),                //LCD ��������ź�
    .lcd_rst               (lcd_rst),               //LCD ��λ�ź�
    .lcd_pclk              (lcd_pclk),              //LCD ����ʱ��
    .lcd_clk               (lcd_clk), 	            //LCD ����ʱ��
	//�û��ӿ�			           
    .out_vsync             (rd_vsync),              //lcd���ź�
    .h_disp                (),                      //�зֱ���  
    .v_disp                (),                      //���ֱ���  
    .pixel_xpos            (pixel_xpos),
    .pixel_ypos            (pixel_ypos),   
    .pre_rgb    		   (color_rgb), 
	.post_rgb   		   (post_rgb),
	.post_de    		   (lcd_de),	    
    .data_in               (rddata),	            //rfifo�������
    .data                  (digit),
    .data_req              (rdata_req)              //������������
    );   

 //ͼ����ģ��
vip u_vip(
    //module clock
    .clk              (lcd_clk),                    // ʱ���ź�
    .rst_n            (sys_rst_n ),                     // ��λ�źţ�����Ч��
    //ͼ����ǰ�����ݽӿ�
    .pre_frame_vsync  (vs_t),
    .pre_frame_hsync  (hs_t ),
    .pre_frame_de     (de_t),
    .pre_rgb          (color_rgb),
    .xpos             (pixel_xpos),
    .ypos             (pixel_ypos),
    //ͼ���������ݽӿ�
    .h_total_pexel    (h_disp),
    .v_total_pexel    (v_disp),    
    .post_frame_vsync (lcd_vs),                     // �����ĳ��ź�
    .post_frame_hsync (lcd_hs ),                    // ���������ź�
    .post_frame_de    (lcd_de),                     // ������������Чʹ�� 
    .digit            (digit),
    .post_rgb         (post_rgb)                    // ������ͼ������

); 

endmodule
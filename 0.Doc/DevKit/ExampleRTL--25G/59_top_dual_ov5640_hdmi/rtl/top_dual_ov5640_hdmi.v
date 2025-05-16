//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           top_dual_ov5640_hdmi
// Last modified Date:  2020/05/04 9:19:08
// Last Version:        V1.0
// Descriptions:        双目ov5640摄像头HDMi显示
//                      
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/05/04 9:19:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module top_dual_ov5640_hdmi(    
    input                 sys_clk        ,  //系统时钟
    input                 sys_rst_n      ,  //系统复位，低电平有效
    //摄像头1接口                       
    input                 cam_pclk_1     ,  //cmos 数据像素时钟
    input                 cam_vsync_1    ,  //cmos 场同步信号
    input                 cam_href_1     ,  //cmos 行同步信号
    input   [7:0]         cam_data_1     ,  //cmos 数据
    output                cam_rst_n_1    ,  //cmos 复位信号，低电平有效
    output                cam_pwdn_1     ,  //电源休眠模式选择 0：正常模式 1：电源休眠模式
    output                cam_scl_1      ,  //cmos SCCB_SCL线
    inout                 cam_sda_1      ,  //cmos SCCB_SDA线
    //摄像头2接口     
    input                 cam_pclk_2     ,  //cmos 数据像素时钟
    input                 cam_vsync_2    ,  //cmos 场同步信号
    input                 cam_href_2     ,  //cmos 行同步信号
    input   [7:0]         cam_data_2     ,  //cmos 数据
    output                cam_rst_n_2    ,  //cmos 复位信号，低电平有效
    output                cam_pwdn_2     ,  //电源休眠模式选择 0：正常模式 1：电源休眠模式
    output                cam_scl_2      ,  //cmos SCCB_SCL线
    inout                 cam_sda_2      ,  //cmos SCCB_SDA线   
    // DDR3                            
    output                mem_rst_n      ,                       
    output                mem_ck         ,
    output                mem_ck_n       ,
    output                mem_cke        ,
    output                mem_ras_n      ,
    output                mem_cas_n      ,
    output                mem_we_n       , 
    output                mem_odt        ,
    output                mem_cs_n       ,
    output  [14:0]        mem_a          ,   
    output  [2:0]         mem_ba         ,   
    inout   [1:0]         mem_dqs        ,
    inout   [1:0]         mem_dqs_n      ,
    inout   [15:0]        mem_dq         ,
    output  [1:0]         mem_dm         ,									   
    //hdmi接口                            
    output                tmds_clk_p     ,  // TMDS 时钟通道
    output                tmds_clk_n     ,
    output  [2:0]         tmds_data_p    ,  // TMDS 数据通道
    output  [2:0]         tmds_data_n     
);                                 
//parameter define
parameter  V_CMOS_DISP = 11'd720        ;   //CMOS分辨率--行
parameter  H_CMOS_DISP = 11'd1280       ;   //CMOS分辨率--列	
parameter  TOTAL_H_PIXEL = 12'd2570     ; 
parameter  TOTAL_V_PIXEL = 12'd980      ;   
parameter  APP_ADDR_MAX = 28'd921600    ;   //ddr3读写结束地址(16bit为单位,V_CMOS_DISP*H_CMOS_DISP)
parameter  H_CMOS_DISP_HALF = 11'd640   ;   //CMOS分辨率--行的一半

//wire define                          
wire         clk_locked                      ;  //时钟锁定信号
wire         rst_n                       ;  //全局复位 								            
wire         cam_init_done               ;  //摄像头初始化完成							    
wire         rdata_req                   ;  //DDR3控制器模块读使能
wire  [15:0] rddata                      ;  //DDR3控制器模块读数据
wire         cmos_frame_valid_1          ;  //数据1有效使能信号
wire  [15:0] wr_data_1                   ;  //DDR3控制器模块写数据1
wire         cmos_frame_valid_2          ;  //数据2有效使能信号
wire  [15:0] wr_data_2                   ;  //DDR3控制器模块写数据2
wire         init_calib_complete         ;  //DDR3初始化完成init_calib_complete
wire         sys_init_done               ;  //系统初始化完成(DDR初始化+摄像头初始化)
wire         cmos_frame_vsync_1          ;  //输出帧1有效场同步信号
wire         cmos_frame_vsync_2          ;  //输出帧2有效场同步信号
//PLL
wire         pixel_clk                   ;  //像素时钟75M
wire         pixel_clk_5x                ;  //5倍像素时钟375M
wire         clk_50m                     ;  //output 50M
wire         clk_locked                  ;
//HDMI
wire         video_vs                    ;  //场同步信号

//*****************************************************
//**                    main code
//*****************************************************

//待时钟锁定后产生复位结束信号
assign  rst_n = sys_rst_n & clk_locked;

//系统初始化完成：DDR3初始化完成
assign  sys_init_done = init_calib_complete;

//例化PLL IP核
pll_clk  u_pll_clk(
    .pll_rst           (~sys_rst_n      ),
    .clkin1            (sys_clk         ),
    .clkout0           (pixel_clk       ), //像素时钟75M
    .clkout1           (pixel_clk_5x    ), //5倍像素时钟375M
    .clkout2           (clk_50m         ), //output 50M
    .pll_lock          (clk_locked      )
);

//ov5640 驱动
ov5640_dri u_ov5640_dri_1(
    .clk               (clk_50m         ),
    .rst_n             (rst_n           ),

    .cam_pclk          (cam_pclk_1      ),
    .cam_vsync         (cam_vsync_1     ),
    .cam_href          (cam_href_1      ),
    .cam_data          (cam_data_1      ),
    .cam_rst_n         (cam_rst_n_1     ),
    .cam_pwdn          (cam_pwdn_1      ),
    .cam_scl           (cam_scl_1       ),
    .cam_sda           (cam_sda_1       ),

    .capture_start     (init_calib_complete),
    .cmos_h_pixel      (H_CMOS_DISP_HALF),
    .cmos_v_pixel      (V_CMOS_DISP     ),
    .total_h_pixel     (TOTAL_H_PIXEL   ),
    .total_v_pixel     (TOTAL_V_PIXEL   ),
    .cmos_frame_vsync  (cmos_frame_vsync_1),
    .cmos_frame_href   (),
    .cmos_frame_valid  (cmos_frame_valid_1),
    .cmos_frame_data   (wr_data_1       )
);   

//ov5640 驱动
ov5640_dri u_ov5640_dri_2(
    .clk               (clk_50m),
    .rst_n             (rst_n),

    .cam_pclk          (cam_pclk_2      ),
    .cam_vsync         (cam_vsync_2     ),
    .cam_href          (cam_href_2      ),
    .cam_data          (cam_data_2      ),
    .cam_rst_n         (cam_rst_n_2     ),
    .cam_pwdn          (cam_pwdn_2      ),
    .cam_scl           (cam_scl_2       ),
    .cam_sda           (cam_sda_2       ),
    
    .capture_start     (init_calib_complete),
    .cmos_h_pixel      (H_CMOS_DISP_HALF),
    .cmos_v_pixel      (V_CMOS_DISP     ),
    .total_h_pixel     (TOTAL_H_PIXEL   ),
    .total_v_pixel     (TOTAL_V_PIXEL   ),
    .cmos_frame_vsync  (cmos_frame_vsync_2),
    .cmos_frame_href   (),
    .cmos_frame_valid  (cmos_frame_valid_2),
    .cmos_frame_data   (wr_data_2       )
);    

//DDR3
ddr3_ctrl_top u_ddr3_ctrl_top(
    .clk              (clk_50m          ),
    .rd_clk           (pixel_clk        ),
    .rst_n            (rst_n            ),
    .ddr3_init_done   (init_calib_complete),
    //用户接口
    .wd_en_1          (cmos_frame_valid_1),
    .wd_en_2          (cmos_frame_valid_2),
    .wd_data_1        (wr_data_1        ),
    .wd_data_2        (wr_data_2        ),
    .wd_clk_1         (cam_pclk_1        ),
    .wd_clk_2         (cam_pclk_2        ),
    .wd_load_1        (cmos_frame_vsync_1),
    .wd_load_2        (cmos_frame_vsync_2),

    .rd_en            (rdata_req        ),
    .rd_data          (rddata           ),
    .rd_load          (video_vs         ),
    .ddr3_pingpang_en (1'b1             ),
    .ddr3_read_valid  (1'b1             ),
    .h_disp           (H_CMOS_DISP      ),
    //地址接口
    .addr_rd_min      (28'b0            ),
    .addr_rd_max      (APP_ADDR_MAX     ),
    .rd_burst_len     (H_CMOS_DISP[10:3]),
    .addr_wd_min      (28'b0            ),
    .addr_wd_max      (APP_ADDR_MAX     ),
    .wd_burst_len     (H_CMOS_DISP[10:3]),

    //DDR3 IO接口
    .mem_rst_n        (mem_rst_n        ),
    .mem_ck           (mem_ck           ),
    .mem_ck_n         (mem_ck_n         ),
    .mem_cke          (mem_cke          ),
    .mem_ras_n        (mem_ras_n        ),
    .mem_cas_n        (mem_cas_n        ),
    .mem_we_n         (mem_we_n         ),
    .mem_odt          (mem_odt          ),
    .mem_cs_n         (mem_cs_n         ),
    .mem_a            (mem_a            ),
    .mem_ba           (mem_ba           ),
    .mem_dqs          (mem_dqs          ),
    .mem_dqs_n        (mem_dqs_n        ),
    .mem_dq           (mem_dq           ),
    .mem_dm           (mem_dm           )
);

//HDMI顶层模块
hdmi_top u_hdmi_top(
    .hdmi_clk         (pixel_clk        ),
    .hdmi_clk_5       (pixel_clk_5x     ),
    .sys_rst_n        (rst_n&sys_init_done),
    //HDMI interface
   .tmds_clk_p       (tmds_clk_p       ),
   .tmds_clk_n       (tmds_clk_n       ),
   .tmds_data_p      (tmds_data_p      ),
   .tmds_data_n      (tmds_data_n      ),
   //user interface
   .rd_data          (rddata           ),
   .rd_en            (rdata_req        ),
   .video_vs         (video_vs         ),
   .pixel_xpos       ( ),
   .pixel_ypos       ( )
);   

endmodule
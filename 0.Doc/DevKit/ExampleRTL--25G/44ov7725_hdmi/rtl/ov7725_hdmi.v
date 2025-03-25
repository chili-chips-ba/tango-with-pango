//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           ov7725_hdmi
// Last modified Date:  2020/05/04 9:19:08
// Last Version:        V1.0
// Descriptions:        ov7725_hdmi顶层模块
//                      
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/05/04 9:19:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ov7725_hdmi(
    input                   sys_clk          ,
    input                   sys_rst_n        ,
                                       
    output                  tmds_clk_p       ,  // TMDS 时钟通道
    output                  tmds_clk_n       ,
    output         [2:0]    tmds_data_p      ,  // TMDS 数据通道
    output         [2:0]    tmds_data_n      ,
    //摄像头接口                     
    input                   cam_pclk         ,  //cmos 数据像素时钟
    input                   cam_vsync        ,  //cmos 场同步信号
    input                   cam_href         ,  //cmos 行同步信号
    input          [7:0]    cam_data         ,  //cmos 数据
    output                  cam_rst_n        ,  //cmos 复位信号，低电平有效
    output                  cam_sgm_ctrl     ,  //cmos 时钟选择信号, 1:使用摄像头自带的晶振
    output                  cam_scl          ,  //cmos SCCB_SCL线
    inout                   cam_sda          ,  //cmos SCCB_SDA线
    //DDR控制器接口
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
parameter  APP_ADDR_MIN = 28'd0       ; //ddr3读写起始地址，以一个16bit的数据为一个单位
parameter  APP_ADDR_MAX = 28'd307200  ; //ddr3读写结束地址，以一个16bit的数据为一个单位
parameter  V_CMOS_DISP = 11'd480;         //CMOS分辨率--行
parameter  H_CMOS_DISP = 11'd640;         //CMOS分辨率--列

//wire define
//PLL
wire        pixel_clk       ;  //像素时钟75M
wire        pixel_clk_5x    ;  //5倍像素时钟375M
wire        clk_50m         ;  //output 50M
wire        clk_locked      ;
//OV7725
wire        i2c_dri_clk     ;  //I2C操作时钟
wire        i2c_done        ;  //I2C寄存器配置完成信号
wire        i2c_exec        ;  //I2C触发执行信号
wire [15:0] i2c_data        ;  //I2C要配置的地址与数据(高8位地址,低8位数据)
wire        cam_init_done   ;  //摄像头初始化完成
wire        cmos_frame_vsync;  //帧有效信号
wire        cmos_frame_href ;  //行有效信号
wire        cmos_frame_valid;  //数据有效使能信号
wire [15:0] wr_data         ;  //OV7725写入DDR3控制器模块的数据
//HDMI
wire        video_vs        ;  //场同步信号
wire [15:0] rd_data         ;  //DDR3控制器模块读数据给HDMI
wire        rdata_req       ;  //DDR3控制器模块读使能
//DDR3
wire        ddr3_init_done   ; //ddr3初始化完成

//*****************************************************
//**                    main code
//*****************************************************

//待时钟锁定后产生结束复位信号
assign rst_n = sys_rst_n & clk_locked;

//系统初始化完成：DDR3和摄像头都初始化完成
//避免了在DDR3初始化过程中向里面写入数据
assign  sys_init_done = ddr3_init_done;
 

//不对摄像头硬件复位,固定高电平
assign  cam_rst_n    = 1'b1;

//cmos 时钟选择信号, 1:使用摄像头自带的晶振
assign  cam_sgm_ctrl = 1'b1;

//例化PLL IP核
pll_clk  u_pll_clk(
    .pll_rst        (~sys_rst_n  ),
    .clkin1         (sys_clk     ),
    .clkout0        (pixel_clk   ), //像素时钟75M
    .clkout1        (pixel_clk_5x), //5倍像素时钟375M
    .clkout2        (clk_50m     ), //output 50M
    .pll_lock       (clk_locked  )
);

//OV7725配置模块    
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
    .ddr3_init_done  (ddr3_init_done),       //ddr3初始化完成标志
    // 外部数据接口   
    .wd_en           (cmos_frame_valid),       //写使能
    .wd_data         (wr_data),       //写数据
    .rd_en           (rdata_req),       //读使能
    .rd_data         (rd_data),       //读数据
    .wr_load         (cmos_frame_vsync),       //输入源更新信号
    .rd_load         (video_vs),       //输出源更新信号
    .ddr3_pingpang_en(1'b1),       //DDR3乒乓操作
    .ddr3_read_valid (1'b1),
    // ddr地址长度控制接口                  
    .addr_rd_min     (APP_ADDR_MIN),
    .addr_rd_max     (APP_ADDR_MAX),
    .rd_burst_len    (H_CMOS_DISP[10:3]),
    .addr_wd_min     (APP_ADDR_MIN),
    .addr_wd_max     (APP_ADDR_MAX),
    .wd_burst_len    (H_CMOS_DISP[10:3]),
    //DDR控制器接口
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
//HDMI顶层模块
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
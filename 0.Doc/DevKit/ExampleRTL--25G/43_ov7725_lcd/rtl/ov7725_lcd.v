//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ov7725_lcd
// Created by:          正点原子
// Created date:        2023年9月14日19:26:07
// Version:             V1.0
// Descriptions:        ov7725_lcd
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ov7725_lcd(    
    input                 sys_clk      ,  //系统时钟
    input                 sys_rst_n    ,  //系统复位，低电平有效
    //摄像头接口                       
    input                 cam_pclk     ,  //cmos 数据像素时钟
    input                 cam_vsync    ,  //cmos 场同步信号
    input                 cam_href     ,  //cmos 行同步信号
    input   [7:0]         cam_data     ,  //cmos 数据
    output                cam_rst_n    ,  //cmos 复位信号，低电平有效
    output                cam_sgm_ctrl ,  //cmos 时钟选择信号, 1:使用摄像头自带的晶振
    output                cam_scl      ,  //cmos SCCB_SCL线
    inout                 cam_sda      ,  //cmos SCCB_SDA线                      
    // DDR3                            
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
    output 	[14:0]          mem_a           ,   
    output 	[2:0]           mem_ba          ,   
    inout 	[1:0]           mem_dqs         ,
    inout 	[1:0]           mem_dqs_n       ,
    inout 	[15:0]          mem_dq          ,
    output 	[1:0]           mem_dm          ,
    //lcd接口                           
    output                lcd_hs       ,  //LCD 行同步信号
    output                lcd_vs       ,  //LCD 场同步信号
    output                lcd_de       ,  //LCD 数据输入使能
    inout       [23:0]    lcd_rgb      ,  //LCD 颜色数据
    output                lcd_bl       ,  //LCD 背光控制信号
    output                lcd_rst      ,  //LCD 复位信号
    output                lcd_pclk        //LCD 采样时钟								   
    );                                 									 

//wire define                          
wire         clk_50m                   ;  //50mhz时钟,提供给lcd驱动时钟
wire         locked                    ;  //时钟锁定信号
wire         rst_n                     ;  //全局复位 								            
wire         cam_init_done             ;  //摄像头初始化完成							    
wire         wr_en                     ;  //DDR3控制器模块写使能
wire  [15:0] wrdata                    ;  //DDR3控制器模块写数据
wire         rdata_req                 ;  //DDR3控制器模块读使能
wire  [15:0] rddata                    ;  //DDR3控制器模块读数据
wire         cmos_frame_valid          ;  //数据有效使能信号
wire         init_calib_complete       ;  //DDR3初始化完成init_calib_complete
wire         sys_init_done             ;  //系统初始化完成(DDR3初始化+摄像头初始化)
wire         clk_200m                  ;  //ddr3参考时钟
wire         cmos_frame_vsync          ;  //输出帧有效场同步信号
wire         cmos_frame_href           ;  //输出帧有效行同步信号 
wire  [10:0] h_disp                    ;  //LCD屏水平分辨率
wire  [10:0] v_disp                    ;  //LCD屏垂直分辨率     
wire  [10:0] h_pixel                   ;  //存入ddr3的水平分辨率        
wire  [10:0] v_pixel                   ;  //存入ddr3的屏垂直分辨率 
wire  [15:0] lcd_id                    ;  //LCD屏的ID号
wire  [27:0] ddr3_addr_max             ;  //存入DDR3的最大读写地址 

//*****************************************************
//**                    main code
//*****************************************************

//待时钟锁定后产生结束复位信号
assign  rst_n = sys_rst_n;

//系统初始化完成：DDR3和摄像头都初始化完成
//避免了在DDR3初始化过程中向里面写入数据
assign  sys_init_done = init_calib_complete &cam_init_done;
                    
//不对摄像头硬件复位,固定高电平
assign  cam_rst_n = 1'b1;

//cmos 时钟选择信号, 1:使用摄像头自带的晶振
assign  cam_sgm_ctrl = 1'b1;

//OV7725配置模块    
ov7725_dri u_ov7725_dri(
    .clk                    (sys_clk),   
    .rst_n                  (rst_n),   
    .init_done              (cam_init_done),
    .cam_scl                (cam_scl),   
    .cam_sda                (cam_sda)   
);

//图像采集顶层模块
cmos_data_top u_cmos_data_top(
    .rst_n                 (rst_n & sys_init_done), //系统初始化完成之后再开始采集数据 
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
    .cmos_frame_valid      (cmos_frame_valid),      //数据有效使能信号
    .cmos_frame_data       (wrdata)                //有效数据 
    );

// ddr3控制模块
ddr3_ctrl_top u_ddr3_ctrl_top(
    .clk            (sys_clk        ),
    .rst_n          (rst_n      ),
    .ddr3_init_done (init_calib_complete),  //ddr初始化完成信号
    // 用户接口
    .wd_clk         (cam_pclk       ),      //写时钟
    .rd_clk         (lcd_clk        ),      //读时钟
    .wd_en          (cmos_frame_valid),     //数据有效使能信号
    .wd_data        (wrdata         ),      //写有效数据
    .rd_en          (rdata_req      ),      //DDR3 读使能
    .rd_data        (rddata         ),      //rfifo输出数据
    .addr_rd_min    (28'b0          ),      //读DDR3的起始地址
    .addr_rd_max    (ddr3_addr_max  ),      //读DDR的结束地址
    .rd_burst_len   (h_pixel[10:3]  ),      //从DDR3中读数据的突发长度
    .addr_wd_min    (28'b0          ),      //写DDR3的起始地址
    .addr_wd_max    (ddr3_addr_max  ),      //写DDR的结束地址
    .wd_burst_len   (h_pixel[10:3]  ),      //写到DDR3中数据的突发长度

    .wr_load        (cmos_frame_vsync),     //输入源更新信号
    .rd_load        (rd_vsync       ),      //输出源更新信号
    .ddr3_pingpang_en(1'b1),                //DDR3 乒乓操作
    .ddr3_read_valid (1'b1),                //请求数据输入
    //DDR3 IO接口
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

//LCD驱动显示模块
lcd_rgb_top  u_lcd_rgb_top(
	.sys_clk               (sys_clk  ),
    .sys_rst_n             (rst_n ),
	.sys_init_done         (sys_init_done),		

    //lcd接口 				           
    .lcd_id                (lcd_id),                //LCD屏的ID号 
    .lcd_hs                (lcd_hs),                //LCD 行同步信号
    .lcd_vs                (lcd_vs),                //LCD 场同步信号
    .lcd_de                (lcd_de),                //LCD 数据输入使能
    .lcd_rgb               (lcd_rgb),               //LCD 颜色数据
    .lcd_bl                (lcd_bl),                //LCD 背光控制信号
    .lcd_rst               (lcd_rst),               //LCD 复位信号
    .lcd_pclk              (lcd_pclk),              //LCD 采样时钟
    .lcd_clk               (lcd_clk), 	            //LCD 驱动时钟
	//用户接口			           
    .out_vsync             (rd_vsync),              //lcd场信号
    .h_disp                (h_disp),                //行分辨率  
    .v_disp                (v_disp),                //场分辨率
    .pixel_xpos            (),
    .pixel_ypos            (),    
    .data_in               (rddata),	            //rfifo输出数据
    .data_req              (rdata_req)              //请求数据输入
    );
                          
endmodule
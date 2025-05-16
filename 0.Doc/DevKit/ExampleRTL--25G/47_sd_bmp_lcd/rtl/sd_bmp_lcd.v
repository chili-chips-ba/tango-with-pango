//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           sd_bmp_lcd
// Last modified Date:  2020/11/22 15:16:38
// Last Version:        V1.0
// Descriptions:        SD卡读BMP图片LCD显示
//                      
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2020/11/22 15:16:38
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module sd_bmp_lcd(    
    input                 sys_clk      ,  //系统时钟
    input                 sys_rst_n    ,  //系统复位，低电平有效
    //SD卡接口
    input                 sd_miso      ,  //SD卡SPI串行输入数据信号
    output                sd_clk       ,  //SD卡SPI时钟信号
    output                sd_cs        ,  //SD卡SPI片选信号
    output                sd_mosi      ,  //SD卡SPI串行输出数据信号

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
    output 	    [14:0]      mem_a           ,   
    output 	    [2:0]       mem_ba          ,   
    inout 	    [1:0]       mem_dqs         ,
    inout 	    [1:0]       mem_dqs_n       ,
    inout 	    [15:0]      mem_dq          ,
    output 	    [1:0]       mem_dm         ,									   
    //lcd接口                           
    output                lcd_hs       ,  //LCD 行同步信号
    output                lcd_vs       ,  //LCD 场同步信号
    output                lcd_de       ,  //LCD 数据输入使能
    inout       [23:0]    lcd_rgb      ,  //LCD 颜色数据
    output                lcd_bl       ,  //LCD 背光控制信号
    output                lcd_rst      ,  //LCD 复位信号
    output                lcd_pclk     ,   //LCD 采样时钟
    output                led
    );                                 
									   							   
//wire define                          
wire         clk_50m                   ;  //50mhz时钟,提供给lcd驱动时钟
wire         clk_50m_180deg            ;
wire         locked                    ;  //时钟锁定信号
wire         rst_n                     ;  //全局复位 	

wire  [23:0] ddr_max_addr              ;  //DDR读写最大地址
wire  [15:0] sd_sec_num                ;  //SD卡读扇区个数

wire         sd_rd_start_en            ;  //开始写SD卡数据信号
wire  [31:0] sd_rd_sec_addr            ;  //读数据扇区地址    
wire         sd_rd_busy                ;  //读忙信号
wire         sd_rd_val_en              ;  //数据读取有效使能信号
wire  [15:0] sd_rd_val_data            ;  //读数据
wire         sd_init_done              ;  //SD卡初始化完成信号	
wire         ddr_wr_en                 ;  //DDR3控制器模块写使能
wire  [15:0] ddr_wr_data               ;  //DDR3控制器模块写数据

wire         wr_en                     ;  //DDR3控制器模块写使能
wire  [15:0] wr_data                   ;  //DDR3控制器模块写数据
wire         rdata_req                 ;  //DDR3控制器模块读使能
wire  [15:0] rd_data                   ;  //DDR3控制器模块读数据
wire         init_calib_complete       ;  //DDR3初始化完成init_calib_complete
wire         sys_init_done             ;  //系统初始化完成(DDR初始化+摄像头初始化)
wire         clk_200m                  ;  //ddr3参考时钟
wire         lcd_clk                   ;  //分频产生的LCD 采样时钟
wire  [12:0] h_disp                    ;  //LCD屏水平分辨率   
wire  [15:0] lcd_id                    ;  //LCD屏的ID号

//*****************************************************
//**                    main code
//*****************************************************

//待时钟锁定后产生复位结束信号
assign  rst_n = sys_rst_n & locked;

//系统初始化完成：DDR3初始化完成 & SD卡初始化完成
assign  sys_init_done = init_calib_complete & sd_init_done;
//DDR3控制器模块为写使能和写数据赋值
assign  wr_en = ddr_wr_en;
assign  wr_data = ddr_wr_data;

assign led = sys_init_done;

//时钟IP核         
pll_clk u_pll_clk (
  .pll_rst      (1'b0  ),      // input
  .clkin1       (sys_clk    ),        // input
  .pll_lock     (locked     ),    // output
  .clkout0      (clk_50m    ),      // output
  .clkout1      (clk_50m_180deg)       // output
);

//DDR和SD卡参数计算模块
sd_ddr_size  u_sd_rd_size(
    .clk                (clk_50m  ),  
    .rst_n              (rst_n),
    .ID_lcd             (lcd_id),           //LCD的器件ID    
    
    .ddr_max_addr       (ddr_max_addr),   
    .sd_sec_num         (sd_sec_num)
    );

//读取SD卡图片
sd_read_photo u_sd_read_photo(
    .clk                   (clk_50m),
    //系统初始化完成之后,再开始从SD卡中读取图片
    .rst_n                 (rst_n & sys_init_done), 
    .ddr_max_addr          (ddr_max_addr),       
    .sd_sec_num            (sd_sec_num), 
    .rd_busy               (sd_rd_busy),
    .sd_rd_val_en          (sd_rd_val_en),
    .sd_rd_val_data        (sd_rd_val_data),
    .rd_start_en           (sd_rd_start_en),
    .rd_sec_addr           (sd_rd_sec_addr),
    .ddr_wr_en             (ddr_wr_en),
    .ddr_wr_data           (ddr_wr_data)
    );     

//SD卡顶层控制模块
sd_ctrl_top u_sd_ctrl_top(
    .clk_ref                (clk_50m),
    .clk_ref_180deg         (clk_50m_180deg),
    .rst_n                  (rst_n),
    //SD卡接口
    .sd_miso                (sd_miso),
    .sd_clk                 (sd_clk),
    .sd_cs                  (sd_cs),
    .sd_mosi                (sd_mosi),
    //用户写SD卡接口
    .wr_start_en            (1'b0),                      //不需要写入数据,写入接口赋值为0
    .wr_sec_addr            (32'b0),
    .wr_data                (16'b0),
    .wr_busy                (),
    .wr_req                 (),
    //用户读SD卡接口
    .rd_start_en            (sd_rd_start_en),
    .rd_sec_addr            (sd_rd_sec_addr),
    .rd_busy                (sd_rd_busy),
    .rd_val_en              (sd_rd_val_en),
    .rd_val_data            (sd_rd_val_data),    
    
    .sd_init_done           (sd_init_done)
    );  

//DDR3模块               
ddr3_ctrl_top u_ddr3_ctrl_top(
    .clk             (clk_50m),
    .wd_clk          (clk_50m),
    .rd_clk          (lcd_clk),
    .rst_n           (rst_n),
    // 外部数据接口   
    .wd_en           (wr_en),   //写使能
    .wd_data         (wr_data),   //写数据
    .rd_en           (rdata_req),   //读使能
    .rd_data         (rd_data),   //读数据
    .wr_load         (1'b0),   //输入源更新信号
    .rd_load         (rd_vsync),   //输出源更新信号
    .ddr3_pingpang_en(1'b1),   //DDR3乒乓操作
    .ddr3_read_valid (1'b1),
    // ddr地址长度控制接口                  
    .addr_rd_min     (28'd0),
    .addr_rd_max     (ddr_max_addr),
    .rd_burst_len    (h_disp[10:3]),
    .addr_wd_min     (28'd0),
    .addr_wd_max     (ddr_max_addr),
    .wd_burst_len    (h_disp[10:3]),
    .ddr3_init_done  (init_calib_complete),   //ddr3初始化完成标志
    //DDR控制器接口
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

//LCD驱动显示模块
lcd_rgb_top  u_lcd_rgb_top(
	.sys_clk               (clk_50m),
    .sys_rst_n             (rst_n),
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
    .data_in               (rd_data),	            //rfifo输出数据
    .data_req              (rdata_req)              //请求数据输入
    );   

endmodule
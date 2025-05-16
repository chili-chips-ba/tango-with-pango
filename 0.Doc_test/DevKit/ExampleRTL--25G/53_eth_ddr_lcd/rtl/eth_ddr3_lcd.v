//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           eth_ddr3_lcd
// Last modified Date:  2020/05/04 9:19:08
// Last Version:        V1.0
// Descriptions:        以太网图片传输LCD显示顶层
//                      
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/05/04 9:19:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//
module eth_ddr3_lcd(
    input                  sys_clk     ,  //FPGA外部时钟，50MHz
    input                  rst_n       ,  //按键复位，低电平有效
    //以太网接口                          
    input                  eth_rxc     ,  //RGMII接收数据时钟
    input                  eth_rx_ctl  ,  //RGMII输入数据有效信号
    input       [3:0]      eth_rxd     ,  //RGMII输入数据
    output                 eth_txc     ,  //RGMII发送数据时钟    
    output                 eth_tx_ctl  ,  //RGMII输出数据有效信号
    output      [3:0]      eth_txd     ,  //RGMII输出数据          
    output                 eth_rst_n   ,  //以太网芯片复位信号，低电平有效                           
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
    //lcd接口                           
    output                 lcd_hs       ,  //LCD 行同步信号
    output                 lcd_vs       ,  //LCD 场同步信号
    output                 lcd_de       ,  //LCD 数据输入使能
    inout       [23:0]     lcd_rgb      ,  //LCD 颜色数据
    output                 lcd_bl       ,  //LCD 背光控制信号
    output                 lcd_rst      ,  //LCD 复位信号
    output                 lcd_pclk        //LCD 采样时钟
    );
//parameter define
//开发板MAC地址 00-11-22-33-44-55
parameter  BOARD_MAC = 48'h00_11_22_33_44_55;     
//开发板IP地址 192.168.1.10
parameter  BOARD_IP  = {8'd192,8'd168,8'd1,8'd10};  
//目的MAC地址 ff_ff_ff_ff_ff_ff
parameter  DES_MAC   = 48'hff_ff_ff_ff_ff_ff;    
//目的IP地址 192.168.1.102     
parameter  DES_IP    = {8'd192,8'd168,8'd1,8'd102};  
				   							   
//wire define    
wire         gmii_rx_clk               ;  //以太网125M时钟            
wire         clk_50m                   ;  //50mhz时钟,提供给lcd驱动时钟
wire         locked                    ;  //时钟锁定信号           						    
wire         rdata_req                 ;  //DDR3控制器模块读使能
wire  [15:0] rd_data                   ;  //DDR3控制器模块读数据
wire         ddr3_init_done            ;  //DDR3初始化完成init_calib_complete
wire         sys_init_done             ;  //系统初始化完成(DDR初始化+摄像头初始化)
wire  [27:0] app_addr_rd_min           ;  //读DDR3的起始地址
wire  [27:0] app_addr_rd_max           ;  //读DDR3的结束地址
wire  [7:0]  rd_bust_len               ;  //从DDR3中读数据时的突发长度
wire  [27:0] app_addr_wr_min           ;  //写DDR3的起始地址
wire  [27:0] app_addr_wr_max           ;  //写DDR3的结束地址
wire  [7:0]  wr_bust_len               ;  //从DDR3中写数据时的突发长度 
wire         lcd_clk                   ;  //分频产生的LCD 采样时钟
wire  [12:0] h_disp                    ;  //LCD屏水平分辨率
wire  [12:0] v_disp                    ;  //LCD屏垂直分辨率     
wire  [10:0] h_pixel                   ;  //存入ddr3的水平分辨率        
wire  [10:0] v_pixel                   ;  //存入ddr3的屏垂直分辨率 
wire  [15:0] lcd_id                    ;  //LCD屏的ID号
wire  [27:0] ddr3_addr_max             ;  //存入DDR3的最大读写地址 
wire         i2c_rh_wl                 ;  //I2C读写控制信号             
wire  [7:0]  i2c_data_r                ;  //I2C读数据 
wire  [12:0] total_h_pixel             ;  //水平总像素大小 
wire  [12:0] total_v_pixel             ;  //垂直总像素大小
wire  [11:0] pixel_ypos;
wire  [11:0] pixel_xpos;
wire         sys_rst_n                  ;  //系统复位信号
wire  [7:0]  rec_data                   ;  //以太网接收的数据
wire  [15:0] picture_data               ;  //图片数据
wire         picture_data_vld           ;  //图片数据有效信号
wire         picture_data_vld0          ;  //非480x272屏图片像素有效信号
wire         picture_data_vld1          ;  //480x272屏图片像素有效信号
wire         data_req_big               ;  //非480x272屏的LCD请求信号
wire         data_req_small             ;  //480x272LCD屏请求信号
wire  [10:0] picture_data_cntx;
wire  [10:0] picture_data_cnty;
wire         rec_en;
//*****************************************************
//**                    main code
//*****************************************************
//待PLL输出稳定之后，停止系统复位
assign  sys_rst_n     =   rst_n & locked                     ;
//系统初始化完成：DDR3初始化完成
assign  sys_init_done =   ddr3_init_done                ;
assign  ddr3_addr_max =  (lcd_id == 16'h4342) ? 130560:384000; //存入ddr3的最大读写地址
assign  h_disp        =  (lcd_id == 16'h4342) ? 480:800      ; //存入ddr3的一行数据（突发长度）

//时钟产生模块
clk_wiz_0 u_clk_wiz_0 (
  .pll_rst(1'b0),      // input
  .clkin1(sys_clk),        // input
  .pll_lock(locked),    // output
  .clkout0(clk_50m)       // output
);


//480x272屏图片裁剪模块   
picture_tailor u_picture_tailor(
    .gmii_rx_clk           (gmii_rx_clk)          ,  //图片输入像素时钟
    .sys_rst_n             (sys_rst_n)            ,  //复位信号                        
    .picture_data_vld0     (picture_data_vld0)    , 
    //480x272屏图片像素有效信号                      
    .picture_data_vld1     (picture_data_vld1)    ,
    .picture_data_cntx     (picture_data_cntx)    ,
    .picture_data_cnty     (picture_data_cnty)    
     //非480x272屏图片像素有效信号 
    );
       
// ddr3控制模块
ddr3_ctrl_top u_ddr3_ctrl_top(
    .clk            (clk_50m        ),
    .rst_n          (sys_rst_n      ),
    .ddr3_init_done (ddr3_init_done),  //ddr初始化完成信号
    // 用户接口
    .wd_clk         (gmii_rx_clk    ),      //写时钟
    .rd_clk         (lcd_clk        ),      //读时钟
    .wd_en          (picture_data_vld),     //数据有效使能信号
    .wd_data        (picture_data   ),      //写有效数据
    .rd_en          (rdata_req      ),      //DDR3 读使能
    .rd_data        (rd_data         ),      //rfifo输出数据
    .addr_rd_min    (28'b0          ),      //读DDR3的起始地址
    .addr_rd_max    (ddr3_addr_max  ),      //读DDR的结束地址
    .rd_burst_len   (h_disp[12:3]   ),      //从DDR3中读数据的突发长度
    .addr_wd_min    (28'b0          ),      //写DDR3的起始地址
    .addr_wd_max    (ddr3_addr_max  ),      //写DDR的结束地址
    .wd_burst_len   (h_disp[12:3]   ),      //写到DDR3中数据的突发长度

    .wr_load        (1'd0),                     //输入源更新信号
    .rd_load        (rd_vsync       ),      //输出源更新信号
    .ddr3_pingpang_en(1'b0),                //DDR3 乒乓操作
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
                  
//LCD 顶层
lcd_rgb_top  u_lcd_rgb_top(
	.sys_clk               (clk_50m  ),             //时钟
    .sys_rst_n             (sys_rst_n ),            //复位
	.sys_init_done         (sys_init_done),         //初始化完成
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
    .h_disp                (),                      //行分辨率 h_disp 
    .v_disp                (),                      //场分辨率 v_disp 
    .pixel_xpos            (pixel_xpos),
    .pixel_ypos            (pixel_ypos),       
    .data_in               (rd_data),	            //rfifo输出数据
    .data_req              (rdata_req)             //请求数据输入
    );   

//以太网顶层
eth_top #(
    .BOARD_MAC          (BOARD_MAC),                //开发板MAC地址
    .BOARD_IP           (BOARD_IP),                 //开发板IP地址
    .DES_MAC            (DES_MAC),                  //目的MAC地址
    .DES_IP             (DES_IP)                    //目的IP地址
    )
u_eth_top(
    .sys_rst_n          (sys_rst_n) ,              //系统复位信号，低电平有效 
    .eth_rxc            (eth_rxc)   ,              //RGMII接收数据时钟
    .eth_rx_ctl         (eth_rx_ctl),              //RGMII输入数据有效信号
    .eth_rxd            (eth_rxd)   ,              //RGMII输入数据
    .eth_txc            (eth_txc)   ,              //RGMII发送数据时钟    
    .eth_tx_ctl         (eth_tx_ctl),              //RGMII输出数据有效信号
    .eth_txd            (eth_txd)   ,              //RGMII输出数据          
    .eth_rst_n          (eth_rst_n) ,              //以太网芯片复位信号，低电平有效 

    .udp_rec_en         (rec_en),                  //以太网8位图片数据接收完成
    .udp_rec_data       (rec_data),                //以太网8位数据
    .gmii_rx_clk        (gmii_rx_clk)              //以太网125M时钟
    ); 
    

udp_data u_udp_data(
  .clk                 (gmii_rx_clk),              //时钟信号
  .rst_n               (sys_rst_n),                //复位信号，低电平有效                                               
  .rec_en              (rec_en),                   //UDP接收的数据使能信号
  .picture_data_vld0   (picture_data_vld0),        //非480x272屏图片像素有效
  .picture_data_vld1   (picture_data_vld1),        //480x272屏图片像素有效  
  .lcd_id              (lcd_id),                   //LCD屏ID
  .picture_data_vld    (picture_data_vld),         //图片像素有效  
  .rec_data            (rec_data),   
       //以太网16位图片像素数据
  .picture_data        (picture_data)              //以太网16位图片像素数据
    );  
    
endmodule 
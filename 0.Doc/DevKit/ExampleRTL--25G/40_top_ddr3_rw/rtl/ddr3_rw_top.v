//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ddr_rw_top
// Created by:          正点原子
// Created date:        2023年2月3日14:17:02
// Version:             V1.0
// Descriptions:        ddr_rw_top
//
//----------------------------------------------------------------------------------------
//****************************************************************************************///

module ddr3_rw_top(
    input           sys_clk  ,
    input           sys_rst_n, 
    output  [1:0]   led      ,   
   //DDR控制器接口
    output          mem_rst_n,                       
    output          mem_ck   ,
    output          mem_ck_n ,
    output          mem_cke  ,
    output          mem_ras_n,
    output          mem_cas_n,
    output          mem_we_n , 
    output          mem_odt  ,
    output 	[14:0]  mem_a    ,   
    output 	[2:0]   mem_ba   ,   
    inout 	[1:0]   mem_dqs  ,
    inout 	[1:0]   mem_dqs_n,
    inout 	[15:0]  mem_dq   ,
    output          mem_cs_n ,
    output 	[1:0]   mem_dm   

);
//localparam define
localparam addr_rd_min = 28'd0;
localparam addr_rd_max = 28'd5120;
localparam addr_wd_min = 28'd0;
localparam addr_wd_max = 28'd5120;
localparam rd_burst_len = 10'd32;
localparam wd_burst_len = 10'd32;
localparam data_max     = 28'd5120;
// wire define
wire wd_en;
wire [15:0]wd_data;
wire rd_en;
wire [15:0]rd_data;
wire ddr3_init_done;

//*****************************************************
//**                    main code
//***************************************************** 

// ddr控制模块
ddr3_ctrl_top u_ddr3_ctrl_top(
    .clk            (sys_clk        ),
    .wd_clk         (sys_clk        ),
    .rd_clk         (sys_clk        ),
    .rst_n          (sys_rst_n      ),
    
    .wd_en          (wd_en          ),
    .wd_data        (wd_data        ),
    .rd_en          (rd_en          ),
    .rd_data        (rd_data        ),
    
    .addr_rd_min    (addr_rd_min    ),
    .addr_rd_max    (addr_rd_max    ),
    .rd_burst_len   (rd_burst_len   ),
    .addr_wd_min    (addr_wd_min    ),
    .addr_wd_max    (addr_wd_max    ),
    .wd_burst_len   (wd_burst_len   ),
    .ddr3_init_done (ddr3_init_done ),
    
    .mem_rst_n      (mem_rst_n      ),
    .mem_ck         (mem_ck         ),
    .mem_ck_n       (mem_ck_n       ),
    .mem_cke        (mem_cke        ),
    .mem_ras_n      (mem_ras_n      ),
    .mem_cas_n      (mem_cas_n      ),
    .mem_we_n       (mem_we_n       ),
    .mem_odt        (mem_odt        ),
    .mem_a          (mem_a          ),
    .mem_ba         (mem_ba         ),
    .mem_dqs        (mem_dqs        ),
    .mem_dqs_n      (mem_dqs_n      ),
    .mem_cs_n       (mem_cs_n       ),
    .mem_dq         (mem_dq         ),
    .mem_dm         (mem_dm         )
);

// 测试数据产生模块
ddr_test u_ddr_test(
    .clk_50m        (sys_clk        ),
    .rst_n          (sys_rst_n      ),
    .wr_en          (wd_en          ),
    .wr_data        (wd_data        ),
    .rd_en          (rd_en          ),
    .rd_data        (rd_data        ),
    .data_max       (data_max       ),
    .ddr3_init_done (ddr3_init_done ),
    .error_flag     (error_flag     )
);

// 指示灯模块
led_disp u_led_disp(
    .clk_50m             (sys_clk        ),
    .rst_n               (sys_rst_n      ),
    //DDR3初始化失败或者读写错误都认为是实验失败
    .error_flag          (error_flag     ),
    .init_calib_complete (ddr3_init_done ),
    .led                 (led            )
);

endmodule
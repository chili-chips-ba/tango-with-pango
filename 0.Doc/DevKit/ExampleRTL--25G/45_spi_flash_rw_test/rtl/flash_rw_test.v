//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           flash_rw_test
// Last modified Date:  2023/10/07 10:39:20
// Last Version:        V1.0
// Descriptions:        FLASH读写实验
//                      
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2020/12/01 10:39:20
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//
module flash_rw_test(
	input        sys_clk       ,
	input        sys_rst_n     ,
	
	//spi interface
	output       spi_cs        ,//SPI从机的片选信号，低电平有效。
	output       spi_clk       ,//主从机之间的数据同步时钟。
	output       spi_mosi      ,//数据引脚，主机输出，从机输入。
	input        spi_miso      ,//数据引脚，主机输入，从机输出。
	
	//LED
	output  led             //LED灯
);

//wire define
wire        spi_start  ;
wire [7:0 ] spi_cmd    ;
wire [23:0] spi_addr   ;
wire [7:0 ] spi_data   ;
wire        clk_100m   ;
wire        locked     ;
wire        stdone     ;
wire        idel_flag_r;
wire        w_data_req ;
wire        error_flag ;
wire[3:0 ]  cmd_cnt    ;

//*****************************************************
//**                    main code
//*****************************************************

pll_spi	u_pll_spi (
	.clkin1      ( sys_clk    ),
	.clkout0     ( clk_100m   ),
	.pll_lock    ( locked     )
	);

spi_drive u_spi_drive(
    
	.clk_100m          (clk_100m),
	.sys_rst_n		   (sys_rst_n),
	.spi_start         (spi_start),
	.spi_cmd           (spi_cmd),
	.spi_addr          (24'h000000),
	.spi_data          (spi_data),
	.idel_flag_r       (idel_flag_r),
	.w_data_req        (w_data_req),
	.error_flag        (error_flag ),
	.cmd_cnt           (cmd_cnt),
	
	.spi_cs            (spi_cs),
	.spi_clk           (spi_clk),
	.spi_mosi          (spi_mosi),
	.spi_miso          (spi_miso)
);

flash_rw u_flash_rw(

	.sys_clk           (clk_100m),
	.sys_rst_n         (sys_rst_n),
	.idel_flag_r       (idel_flag_r),
	.spi_start         (spi_start),
	.spi_cmd           (spi_cmd),
	.cmd_cnt           (cmd_cnt),
	.w_data_req        (w_data_req),
	.spi_data          (spi_data)
);

//led警示 
led_alarm #(
    .L_TIME      (25'd25_000_000)
    )  
   u_led_alarm(
    .clk            (sys_clk),
    .rst_n          (sys_rst_n&&locked),
    .led            (led),
    .error_flag     (error_flag)
    ); 

endmodule
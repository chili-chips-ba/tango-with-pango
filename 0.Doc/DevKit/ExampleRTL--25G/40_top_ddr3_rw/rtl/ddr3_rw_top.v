//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ddr_rw_top
// Created by:          ����ԭ��
// Created date:        2023��2��3��14:17:02
// Version:             V1.0
// Descriptions:        ddr_rw_top
//
//----------------------------------------------------------------------------------------
//****************************************************************************************///

module ddr3_rw_top(
    input           sys_clk  ,
    input           sys_rst_n, 
    output  [1:0]   led      ,   
   //DDR�������ӿ�
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

// ddr����ģ��
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

// �������ݲ���ģ��
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

// ָʾ��ģ��
led_disp u_led_disp(
    .clk_50m             (sys_clk        ),
    .rst_n               (sys_rst_n      ),
    //DDR3��ʼ��ʧ�ܻ��߶�д������Ϊ��ʵ��ʧ��
    .error_flag          (error_flag     ),
    .init_calib_complete (ddr3_init_done ),
    .led                 (led            )
);

endmodule
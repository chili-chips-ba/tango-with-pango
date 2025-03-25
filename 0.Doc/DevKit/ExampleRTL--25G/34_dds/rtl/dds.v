//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           dds
// Created by:          ����ԭ��
// Created date:        2023��5��31��14:17:02
// Version:             V1.0
// Descriptions:        DDS����ģ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module dds(
    input                 sys_clk     ,  //ϵͳʱ��
    input                 sys_rst_n   ,  //ϵͳ��λ���͵�ƽ��Ч
    input                 key_wave    ,  //���ο��ư���
    input                 key_freq    ,  //Ƶ�ʿ��ư���
    //DAоƬ�ӿ�
    output                da_clk      ,  //DAC����ʱ��
    output    [7:0]       da_data     ,  //�����DA������
    //ADоƬ�ӿ�
    input     [7:0]       ad_data     /* synthesis PAP_MARK_DEBUG="true" */,  //AD��������
    //ģ�������ѹ�������̱�־(��������δ�õ�)
    input                 ad_otr      /* synthesis PAP_MARK_DEBUG="true" */,  //0:�����̷�Χ 1:��������
    output                ad_clk        //ADC����ʱ��
);

//parameter define
parameter  CNT_MAX = 20'd200_0000;      //100MHzʱ���¼���20ms

//wire define 
wire             rst_n          ;  // ��λ������Ч
wire             pll_lock       ;  //PLLʱ�������ź�
wire             clk_100m       ;  //100MHzʱ��
wire             clk_25m/* synthesis PAP_MARK_DEBUG="<0/c0/0>" */;  //25MHzʱ��
wire    [8:0]    rd_addr        ;  //ROM����ַ
wire    [7:0]    rd_data        ;  //ROM����������
wire             key_wave_filter;  //���ο��ư���������İ���ֵ
wire             key_freq_filter;  //Ƶ�ʿ��ư���������İ���ֵ

//*****************************************************
//**                    main code
//*****************************************************

//ͨ��ϵͳ��λ�źź�PLLʱ�������ź�������һ���µĸ�λ�ź�
assign   rst_n = sys_rst_n & pll_lock;
assign   ad_clk = clk_25m;

//PLL IP��
pll_clk u_pll_clk (
  .clkin1         (sys_clk),        
  .pll_lock       (pll_lock),   
  .clkout0        (clk_100m),    
  .clkout1        (clk_25m)       
);

//ROM�洢����
rom_400x8b u_rom_400x8b(
  .addr           (rd_addr),       
  .clk            (clk_100m),          
  .rst            (~rst_n),      
  .rd_data        (rd_data) 
);

//������������ģ��
key_debounce #(
    .CNT_MAX     (CNT_MAX        ))
u_key_wave_debounce(
    .sys_clk     (clk_100m       ),
    .sys_rst_n   (rst_n          ),
    .key         (key_wave       ),
    .key_filter  (key_wave_filter)
    );
    
//������������ģ��
key_debounce #(
    .CNT_MAX     (CNT_MAX        ))
u_key_freq_debounce(
    .sys_clk     (clk_100m       ),
    .sys_rst_n   (rst_n          ),
    .key         (key_freq       ),
    .key_filter  (key_freq_filter)
    );

//DA���ݷ���
da_wave_send u_da_wave_send(
    .clk              (clk_100m       ),
    .rst_n            (rst_n          ),
    .key_wave_filter  (key_wave_filter),
    .key_freq_filter  (key_freq_filter),
    .rd_data          (rd_data        ),
    .rd_addr          (rd_addr        ),
    .da_clk           (da_clk         ),
    .da_data          (da_data        )
    );

endmodule
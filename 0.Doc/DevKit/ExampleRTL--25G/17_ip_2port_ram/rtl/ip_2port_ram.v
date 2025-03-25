//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ip_2port_ram
// Created by:          ����ԭ��
// Created date:        2023��9��9��14:17:02
// Version:             V1.0
// Descriptions:        IP��֮˫�˿�RAMʵ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ip_2port_ram(
    input               sys_clk        ,  //ϵͳʱ��
    input               sys_rst_n      ,  //ϵͳ��λ���͵�ƽ��Ч
    
    //�����߼���������Ϊ�˽��˿�����ȥ������û������źŵĻ��޷�����ץȡ�ź�
    //�����������
    output              ram_wr_en      ,
    output    [4:0]     ram_wr_addr    ,
    output    [7:0]     ram_wr_data    ,
    output    [4:0]     ram_rd_addr    ,
    output    [7:0]     ram_rd_data  
    );
   
//wire define
wire        rd_rst  ;   //���˿ڸ�λ(ʹ��)�ź�
wire        rd_flag ;   //��������־

//*****************************************************
//**                    main code
//*****************************************************

ram_2port u_ram_2port (
  .wr_data    (ram_wr_data),    // input [7:0]  ramд����
  .wr_addr    (ram_wr_addr),    // input [4:0]  ramд��ַ
  .wr_en      (ram_wr_en  ),    // input        
  .wr_clk     (sys_clk    ),    // input
  .wr_rst     (~sys_rst_n ),    // input
  .rd_addr    (ram_rd_addr),    // input [4:0]  ram����ַ
  .rd_data    (ram_rd_data),    // output [7:0] ram������ 
  .rd_clk     (sys_clk    ),    // input
  .rd_rst     (rd_rst     )     // input
);

//RAMдģ��
ram_wr u_ram_wr(
    .clk           (sys_clk    ),
    .rst_n         (sys_rst_n  ),
    .rd_flag       (rd_flag    ),
    .ram_wr_en     (ram_wr_en  ), //ramдʹ�� 
    .ram_wr_addr   (ram_wr_addr),
    .ram_wr_data   (ram_wr_data)
    );

//RAM��ģ��    
ram_rd u_ram_rd(
    .clk           (sys_clk    ),
    .rst_n         (sys_rst_n  ),
    .rd_rst        (rd_rst     ), //ram���˿ڸ�λ��ʹ�ܣ��ź�
    .rd_flag       (rd_flag    ),
    .ram_rd_addr   (ram_rd_addr),
    .ram_rd_data   (ram_rd_data)
    );

endmodule
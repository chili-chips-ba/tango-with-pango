//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ip_1port_ram
// Created by:          ����ԭ��
// Created date:        2023��9��8��14:17:02
// Version:             V1.0
// Descriptions:        IP��֮���˿�RAMʵ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ip_1port_ram(
    
    input          sys_clk   ,   //ϵͳʱ��
    input          sys_rst_n ,   //ϵͳ��λ���͵�ƽ��Ч

    //�����߼���������Ϊ�˽��˿�����ȥ������û������źŵĻ��޷�����ץȡ�ź�
    //�����������
    output [7:0] ram_wr_data ,   //ramд����
    output [7:0] ram_rd_data ,   //ram������
    output [4:0] ram_addr    ,   //ram��д��ַ
    output       ram_rw_en       //ram��дʹ�ܣ�0��������  1��д����
    
    );

//*****************************************************
//**                    main code
//*****************************************************

//�������˿�RAM IP��
ram_1port u_ram_1port (
  .wr_data    (ram_wr_data ),    // input [7:0]
  .addr       (ram_addr    ),    // input [4:0]
  .wr_en      (ram_rw_en   ),    // input
  .clk        (sys_clk     ),    // input
  .rst        (~sys_rst_n  ),    // input
  .rd_data    (ram_rd_data )     // output [7:0]
);

//RAM��дģ��
ram_rw u_ram_rw (
    .clk            (sys_clk     ),
    .rst_n          (sys_rst_n   ),
    .ram_rw_en      (ram_rw_en   ),
    .ram_addr       (ram_addr    ),
    .ram_wr_data    (ram_wr_data )
    );
  
endmodule
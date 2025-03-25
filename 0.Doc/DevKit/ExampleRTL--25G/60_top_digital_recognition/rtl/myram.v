//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved    
//----------------------------------------------------------------------------------------
// File name:           myram
// Last modified Date:  2023/05/04 9:19:08
// Last Version:        V1.0
// Descriptions:        �Զ���RAM
//                      
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/05/04 9:19:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module myram #(
    parameter WIDTH = 1  ,               // ���ݵ�λ��(λ��)
    parameter DEPTH = 800,               // ���ݵ����(����)
    parameter DEPBIT= 10                 // ��ַ��λ��
)(
    //module clock
    input                     clk  ,     // ʱ���ź�

    //ram interface
    input                     we   ,
    input  [DEPBIT- 1'b1:0]   waddr,
    input  [DEPBIT- 1'b1:0]   raddr,
    input  [WIDTH - 1'b1:0]   dq_i ,
    output [WIDTH - 1'b1:0]   dq_o

    //user interface
);

//reg define
reg [WIDTH - 1'b1:0] mem [DEPTH - 1'b1:0];

//*****************************************************
//**                    main code
//*****************************************************

assign dq_o = mem[raddr];

always @ (posedge clk) begin
    if(we)
        mem[waddr-1] <= dq_i;
end

endmodule





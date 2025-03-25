//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                
//----------------------------------------------------------------------------------------
// File name:           reset_dly
// Last modified Date:  2022/7/13 9:20:14
// Last Version:        V1.0
// Descriptions:        ��λģ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2022/7/13 9:20:14
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module reset_dly(
	input           clk,
	input           rst_n,
	output reg      rst_n_dly
);


reg[31:0] dly_cnt;

always@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		rst_n_dly<=1'b0;
		dly_cnt<=32'd0;
    end

	else begin
    if(dly_cnt>32'hffffff)
		rst_n_dly<=1'b1;
    else 
		dly_cnt<=dly_cnt+1'b1;
    end
end    

endmodule

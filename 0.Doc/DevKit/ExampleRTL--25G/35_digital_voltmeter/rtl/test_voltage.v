//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com 
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved                               
//----------------------------------------------------------------------------------------
// File name:           rd_id
// Last modified Date:  2019/8/07 10:41:06
// Last Version:        V1.0
// Descriptions:        �������ݲ���ģ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/8/07 10:41:06
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module test_voltage(
    input                 clk    ,  //ʱ��
    input                 rst_n  ,  //��λ�źţ��͵�ƽ��Ч
    //DAоƬ�ӿ�
    output                da_clk ,  //DAоƬ����ʱ��,���֧��125Mhzʱ��
    output  reg  [7:0]    da_data   //�����DA������  
    );

//parameter define 
parameter TIME_200MS = 25'd10_000_000;//0.2�������

//reg define
reg [24:0]cnt_time;//ʱ�������

//*****************************************************
//**                    main code
//*****************************************************
assign  da_clk = ~clk;    

//0.2�����
always @(posedge clk or negedge rst_n )begin
    if(!rst_n) 
        cnt_time <= 25'd0;
    else if(cnt_time == TIME_200MS - 1'b1)  
        cnt_time <= 25'd0;
    else
        cnt_time <= cnt_time + 1'd1;
end

//ÿ��0.2�����һ�β�������
always@(posedge clk or negedge rst_n )begin
    if(!rst_n)
        da_data <= 8'd0;
    else if(cnt_time == TIME_200MS - 1'b1)begin
        if(da_data == 8'd255)
            da_data <= 8'd0;
        else
            da_data <= da_data + 1'b1;
    end
    else;
end

endmodule
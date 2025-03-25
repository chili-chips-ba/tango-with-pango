//****************************************Copyright (c)***********************************//
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com 
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡFPGA & STM32���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           dht11_key
// Last modified Date:  2018-04-08 17:55:53
// Last Version:        V1.0
// Descriptions:        ����������ʪ����ʾģ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2018-04-08 17:55:53
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
// Modified by:         ����ԭ��
// Modified date:       
// Version:             
// Descriptions:        
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module dht11_key(
    input             sys_clk,
    input             sys_rst_n,
    
    input             key_flag,
    input             key_value,
    input      [31:0] data_valid,
    
    output     [31:0] data,
    output reg        sign,
    output            en,      
    output            flag_mux,               
    output     [ 5:0] point
);

//reg define                            
reg       flag ; // ��/ʪ�ȱ�־�ź�
reg [7:0] data0; // С������
reg [7:0] data1; // ��������

//*****************************************************
//**                    main code
//*****************************************************

//�����ʹ���ź�
assign en    = 1'b1;

//��ʾ����ֵΪ (���� + 0.1*С��)*100
assign data  = data1 * 100 + data0*10;

//С����������λ
assign point = 6'b000100;

assign flag_mux = flag;

//��⵽��������ʱ���л���/ʪ�ȱ�־�ź�
always @ (posedge sys_clk or negedge sys_rst_n) begin 
    if(!sys_rst_n)                                    
        flag <= 1'b0;
    else if (key_flag & (~key_value))
        flag <= ~flag;
end 

//flagΪ��0��ʱ��ʾ�¶ȣ�Ϊ��1��ʱ��ʾʪ��
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        data0 <= 8'd0;
        data1 <= 8'd0;
        sign  <= 1'b0;
    end
    else if(flag == 1'b0) begin
        data0 <= data_valid[6:0];  //�¶�С���������λΪ����λ
        data1 <= data_valid[15:8];
        if(data_valid[7])
            sign <= 1'b1;          //bit7Ϊ1��ʾ���¶�
        else
            sign <= 1'b0;
    end
    else begin
        data0 <= data_valid[23:16];
        data1 <= data_valid[31:24];
        sign  <= 1'b0;
    end
end

endmodule 
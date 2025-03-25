//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           key_4x4
// Created by:          ����ԭ��
// Created date:        2023��2��3��14:17:02
// Version:             V1.0
// Descriptions:        key_4x4
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module key_4x4(
    input                sys_clk  ,   //50MHZ
    input                sys_rst_n,
    input       [3:0]    key_row  ,   //��

    output reg  [3:0]    key_col  ,   //��
    output reg  [4:0]    key_value,   //��ֵ
    output reg           key_flag
);

//reg define
reg [2:0] state       ;  //״̬��־
reg [3:0] key_col_reg ;  //�Ĵ�ɨ����ֵ
reg [3:0] key_row_reg ;  //�Ĵ�ɨ����ֵ
reg [31:0]delay_cnt   ;
reg [3:0] key_reg_row ;
reg       key_flag_row;  //������ɱ�־
reg       del_en      ;  //������ʱ��־�źţ��ߵ�ƽ��Ч
reg [3:0] del_cnt     ;  //������ʱ

//*****************************************************
//**                    main code                      
//*****************************************************

//��������ģ��
always @(posedge sys_clk or negedge sys_rst_n)begin 
    if (!sys_rst_n)begin
        key_reg_row <= 4'b1;
        delay_cnt <= 32'd0;
    end
    else begin
        key_reg_row <= key_row;
            if(key_reg_row != key_row)               //�������������           
//              delay_cnt <= 32'd1000000;            //����������Ϊ20ms    
                delay_cnt <= 32'd8;                  //����ʱʹ��           
            else if(key_reg_row == key_row)begin  
                if(delay_cnt > 32'd0)
                    delay_cnt <= delay_cnt - 1'b1;
                else
                    delay_cnt <= delay_cnt;
            end           
    end   
end
//����������ɱ�־ģ��
always @(posedge sys_clk or negedge sys_rst_n)begin 
    if (!sys_rst_n)  
        key_flag_row <= 1'b0;              
    else begin
            if(delay_cnt == 32'd1)                   //��������������1   
                key_flag_row <= 1'b1;                //˵��������־���
            else if(del_en)
                key_flag_row <= 1'b0;
    end   
end
//����ɨ���ӳٴ���ģ��
always @(posedge sys_clk or negedge sys_rst_n)begin 
    if (!sys_rst_n)begin 
        del_en <= 1'b0;
        del_cnt <= 1'b0;
    end    
    else begin
        if(del_cnt == 4'd3)begin
            del_cnt <= 1'd0;
            del_en <= 1'b1;
        end
        else begin
            del_cnt <= del_cnt + 1'b1;
            del_en <= 1'b0;
        end
    end        
end
//����ɨ��ģ��
always @(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)begin
      key_col <= 4'b0;
      state <= 0;
      key_flag <= 1'b0;
      key_col_reg <= 4'b0;
      key_row_reg <= 4'b0;
    end
    else begin 
        if(del_en)begin
            case (state)
              0:
                begin
                    key_col[3:0] <= 4'b0000;
                    key_flag <= 1'b0;
                    if((key_row[3:0] != 4'b1111) && (key_flag_row))begin   
                        state <= 1;                 //�����ɨ�費���Ǹߵ�ƽ˵���а�������
                        key_col[3:0] <= 4'b1110;    //��ת��״̬ 1 �������жϵ�һ��    
                    end 
                    else 
                        state <= 0 ;
                end
              1:
                begin                               //����״̬1
                    if(key_row[3:0] != 4'b1111)     //�����ɨ����û��ȫ������
                        state <= 5;                 //˵�����ǵ�һ�У���ת��״̬ 5
                    else begin
                        state <= 2;                 //������ǵ�һ������ת״̬ 2
                        key_col[3:0] <= 4'b1101;    //�����жϵڶ���
                    end
                end  
              2:                                   
                begin                               //����״̬ 2
                    if(key_row[3:0] != 4'b1111)     //�����ɨ����û��ȫ������
                        state <= 5;                 //˵�����ǵڶ��У���ת��״̬ 5
                    else begin                 
                        state <= 3;                 //������ǵڶ�������ת״̬ 3
                        key_col[3:0] <= 4'b1011;    //�����жϵ�����
                    end  
                end
              3:
                begin                               //����״̬ 3
                    if(key_row[3:0] != 4'b1111)     //�����ɨ����û��ȫ������
                        state <= 5;                 //˵�����ǵ����У���ת��״̬ 5
                    else begin                  
                        state <= 4;                 //������ǵ���������ת״̬ 4
                        key_col[3:0] <= 4'b0111;    //�����жϵ�����
                    end  
                end
              4:
                begin                               //����״̬ 4
                    if (key_row[3:0] != 4'b1111)    //�����ɨ����û��ȫ������
                        state <= 5;                 //˵�����ǵ����У���ת��״̬ 5
                    else                        
                        state <= 0;                 //������ǵ���������ת״̬ 0
                end                                
              5:
                begin  
                    if(key_row[3:0] != 4'b1111)begin
                        key_col_reg <= key_col;     //����ɨ���ֵ��ֵ����ɨ��Ĵ���
                        key_row_reg <= key_row;     //����ɨ���ֵ��ֵ����ɨ��Ĵ���
                        state <= 5;
                        key_flag <= 1'b1;  
                    end             
                    else
                        state <= 0;
                end             
            endcase 
        end    
    end             
end
//������ֵģ��
always @ ( posedge sys_clk or negedge sys_rst_n )begin
    if(!sys_rst_n)begin
        key_value <= 5'd16;
    end
    else if(key_flag)
    begin
        case ({key_col_reg,key_row_reg})           //����ɨ��Ĵ�������ɨ��Ĵ�������λƴ��
            //��һ�а������
            8'b1110_1110 : key_value <= 5'd0;
            8'b1110_1101 : key_value <= 5'd4;
            8'b1110_1011 : key_value <= 5'd8;
            8'b1110_0111 : key_value <= 5'd12;
            //�ڶ��а������  
            8'b1101_1110 : key_value <= 5'd1;
            8'b1101_1101 : key_value <= 5'd5;
            8'b1101_1011 : key_value <= 5'd9;
            8'b1101_0111 : key_value <= 5'd13;
            //�����а������  
            8'b1011_1110 : key_value <= 5'd2;
            8'b1011_1101 : key_value <= 5'd6;
            8'b1011_1011 : key_value <= 5'd10;
            8'b1011_0111 : key_value <= 5'd14;
            //�����а������  
            8'b0111_1110 : key_value <= 5'd3;
            8'b0111_1101 : key_value <= 5'd7;
            8'b0111_1011 : key_value <= 5'd11;
            8'b0111_0111 : key_value <= 5'd15; 
        endcase 
    end   
end  
endmodule
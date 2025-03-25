//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           e2prom_rw
// Created by:          ����ԭ��
// Created date:        2023��5��17��14:17:02
// Version:             V1.0
// Descriptions:        EEPROM��д����ģ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module e2prom_rw(
    input                 clk        , //ʱ���ź�
    input                 rst_n      , //��λ�ź�

    //i2c interface
    output   reg          i2c_rh_wl  , //I2C��д�����ź�
    output   reg          i2c_exec   , //I2C����ִ���ź�
    output   reg  [15:0]  i2c_addr   , //I2C�����ڵ�ַ
    output   reg  [ 7:0]  i2c_data_w , //I2CҪд������
    input         [ 7:0]  i2c_data_r , //I2C����������
    input                 i2c_done   , //I2Cһ�β������
    input                 i2c_ack    , //I2CӦ���־

    //user interface
    output   reg          rw_done    , //E2PROM��д�������
    output   reg          rw_result    //E2PROM��д���Խ�� 0:ʧ�� 1:�ɹ�
);

//parameter define
//EEPROMд������Ҫ��Ӽ��ʱ��,����������Ҫ
parameter      WR_WAIT_TIME = 14'd5000; //д����ʱ��
parameter      MAX_BYTE     = 16'd256 ; //��д���Ե��ֽڸ���

//reg define
reg   [1:0]    flow_cnt  ; //״̬������
reg   [13:0]   wait_cnt  ; //��ʱ������

//*****************************************************
//**                    main code
//*****************************************************

//EEPROM��д����,��д��������Ƚ϶�����ֵ��д���ֵ�Ƿ�һ��
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        flow_cnt   <= 2'b0;
        i2c_rh_wl  <= 1'b0;
        i2c_exec   <= 1'b0;
        i2c_addr   <= 16'b0;
        i2c_data_w <= 8'b0;
        wait_cnt   <= 14'b0;
        rw_done    <= 1'b0;
        rw_result  <= 1'b0;        
    end
    else begin
        i2c_exec <= 1'b0;
        rw_done  <= 1'b0;
        case(flow_cnt)
            2'd0 : begin                                  
                wait_cnt <= wait_cnt + 14'b1;               //��ʱ����
                if(wait_cnt == (WR_WAIT_TIME - 14'b1)) begin  //EEPROMд������ʱ���
                    wait_cnt <= 14'b0;
                    if(i2c_addr == MAX_BYTE) begin         //256���ֽ�д�����
                        i2c_addr  <= 16'b0;
                        i2c_rh_wl <= 1'b1;
                        flow_cnt  <= 2'd2;
                    end
                    else begin
                        flow_cnt <= flow_cnt + 2'b1;
                        i2c_exec <= 1'b1;
                    end
                end
            end
            2'd1 : begin
                if(i2c_done == 1'b1) begin                  //EEPROM����д�����
                    flow_cnt   <= 2'd0;
                    i2c_addr   <= i2c_addr + 16'b1;           //��ַ0~255�ֱ�д��
                    i2c_data_w <= i2c_data_w + 8'b1;         //����0~255
                end    
            end
            2'd2 : begin                                   
                flow_cnt <= flow_cnt + 2'b1;
                i2c_exec <= 1'b1;
            end    
            2'd3 : begin
                if(i2c_done == 1'b1) begin                 //EEPROM���ζ������
                    //������ֵ�������I2CδӦ��,��д����ʧ��
                    if((i2c_addr[7:0] != i2c_data_r) || (i2c_ack == 1'b1)) begin
                        rw_done <= 1'b1;
                        rw_result <= 1'b0;
                    end
                    else if(i2c_addr == (MAX_BYTE - 16'b1))begin //��д���Գɹ�
                        rw_done   <= 1'b1;
                        rw_result <= 1'b1;
                    end    
                    else begin
                        flow_cnt <= 2'd2;
                        i2c_addr <= i2c_addr + 16'b1;
                    end
                end                 
            end
            default : ;
        endcase    
    end
end    

endmodule

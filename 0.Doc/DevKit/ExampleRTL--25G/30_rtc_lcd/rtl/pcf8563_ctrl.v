//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           pcf8563_ctrl
// Created by:          ����ԭ��
// Created date:        2023��5��18��14:17:02
// Version:             V1.0
// Descriptions:        ʵʱʱ�ӿ���ģ��
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module pcf8563_ctrl #(
    // ��ʼʱ�����ã��Ӹߵ���Ϊ�굽�룬��ռ8bit
    parameter  TIME_INIT = 48'h19_01_01_09_30_00)(
    input                 clk       , //ʱ���ź�
    input                 rst_n     , //��λ�ź�

    //i2c interface
    output   reg          i2c_rh_wl , //I2C��д�����ź�
    output   reg          i2c_exec  , //I2C����ִ���ź�
    output   reg  [15:0]  i2c_addr  , //I2C�����ڵ�ַ
    output   reg  [7:0]   i2c_data_w, //I2CҪд������
    input         [7:0]   i2c_data_r, //I2C����������
    input                 i2c_done  , //I2Cһ�β������

    //PCF8563T���롢�֡�ʱ���ա��¡�������
    output   reg   [7:0]  sec,        //��
    output   reg   [7:0]  min,        //��
    output   reg   [7:0]  hour,       //ʱ
    output   reg   [7:0]  day,        //��
    output   reg   [7:0]  mon,        //��
    output   reg   [7:0]  year        //��
);

//parameter define
localparam  WAIT_TIME = 13'd8_000;

//reg define
reg   [3:0]     flow_cnt  ;            // ת̬������
reg   [12:0]    wait_cnt  ;            // �����ȴ�

//*****************************************************
//**                    main code
//*****************************************************

//����PCF8563��д���ʼ�����ں�ʱ�䣬�ٴ��ж������ں�ʱ��
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sec        <= 8'h0;
        min        <= 8'h0;
        hour       <= 8'h0;
        day        <= 8'h0;
        mon        <= 8'h0;
        year       <= 8'h0;
        i2c_exec   <= 1'b0;
        i2c_rh_wl  <= 1'b0;
        i2c_addr   <= 8'd0;
        i2c_data_w <= 8'd0;
        flow_cnt   <= 4'd0;
        wait_cnt   <= 13'd0;
    end
    else begin
        i2c_exec <= 1'b0;
        case(flow_cnt)
            //�ϵ��ʼ��
            4'd0: begin
                if(wait_cnt == (WAIT_TIME - 13'd1)) begin
                    wait_cnt<= 13'd0;
                    flow_cnt<= flow_cnt + 4'b1;
                end
                else
                    wait_cnt<= wait_cnt + 13'b1;
            end
            //д����
            4'd1: begin
                i2c_exec  <= 1'b1;
                i2c_addr  <= 8'h02;
                flow_cnt  <= flow_cnt + 4'b1;
                i2c_data_w<= TIME_INIT[7:0];
            end
            4'd2: begin
                if(i2c_done == 1'b1) begin
                    sec     <= i2c_data_r[6:0];
                    flow_cnt<= flow_cnt + 4'b1;
                end
            end
            //д����
            4'd3: begin
                i2c_exec  <= 1'b1;
                i2c_addr  <= 8'h03;
                flow_cnt  <= flow_cnt + 4'b1;
                i2c_data_w<= TIME_INIT[15:8];
            end
            4'd4: begin
                if(i2c_done == 1'b1) begin
                    min     <= i2c_data_r[6:0];
                    flow_cnt<= flow_cnt + 4'b1;
                end
            end
            //д��ʱ
            4'd5: begin
                i2c_exec  <= 1'b1;
                i2c_addr  <= 8'h04;
                flow_cnt  <= flow_cnt + 4'b1;
                i2c_data_w<= TIME_INIT[23:16];
            end
            4'd6: begin
                if(i2c_done == 1'b1) begin
                    hour    <= i2c_data_r[5:0];
                    flow_cnt<= flow_cnt + 4'b1;
                end
            end
            //д����
            4'd7: begin
                i2c_exec  <= 1'b1;
                i2c_addr  <= 8'h05;
                flow_cnt  <= flow_cnt + 4'b1;
                i2c_data_w<= TIME_INIT[31:24];
            end
            4'd8: begin
                if(i2c_done == 1'b1) begin
                    day     <= i2c_data_r[5:0];
                    flow_cnt<= flow_cnt + 4'b1;
                end
            end
            //д����
            4'd9: begin
                i2c_exec  <= 1'b1;
                i2c_addr  <= 8'h07;
                flow_cnt  <= flow_cnt + 4'b1;
                i2c_data_w<= TIME_INIT[39:32];
            end
            4'd10: begin
                if(i2c_done == 1'b1) begin
                    mon     <= i2c_data_r[4:0];
                    flow_cnt<= flow_cnt + 4'b1;
                end
            end
            //д����
            4'd11: begin
                i2c_exec  <= 1'b1;
                i2c_addr  <= 8'h08;
                flow_cnt  <= flow_cnt + 4'b1;
                i2c_data_w<= TIME_INIT[47:40];
            end
            4'd12: begin
                if(i2c_done == 1'b1) begin
                    year     <= i2c_data_r;
                    i2c_rh_wl<= 1'b1;
                    flow_cnt <= 4'd1;
                end
            end
            default: flow_cnt <= 4'd0;
        endcase
    end
end

endmodule
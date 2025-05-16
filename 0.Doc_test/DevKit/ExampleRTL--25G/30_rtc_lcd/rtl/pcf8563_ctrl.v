//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           pcf8563_ctrl
// Created by:          正点原子
// Created date:        2023年5月18日14:17:02
// Version:             V1.0
// Descriptions:        实时时钟控制模块
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module pcf8563_ctrl #(
    // 初始时间设置，从高到低为年到秒，各占8bit
    parameter  TIME_INIT = 48'h19_01_01_09_30_00)(
    input                 clk       , //时钟信号
    input                 rst_n     , //复位信号

    //i2c interface
    output   reg          i2c_rh_wl , //I2C读写控制信号
    output   reg          i2c_exec  , //I2C触发执行信号
    output   reg  [15:0]  i2c_addr  , //I2C器件内地址
    output   reg  [7:0]   i2c_data_w, //I2C要写的数据
    input         [7:0]   i2c_data_r, //I2C读出的数据
    input                 i2c_done  , //I2C一次操作完成

    //PCF8563T的秒、分、时、日、月、年数据
    output   reg   [7:0]  sec,        //秒
    output   reg   [7:0]  min,        //分
    output   reg   [7:0]  hour,       //时
    output   reg   [7:0]  day,        //日
    output   reg   [7:0]  mon,        //月
    output   reg   [7:0]  year        //年
);

//parameter define
localparam  WAIT_TIME = 13'd8_000;

//reg define
reg   [3:0]     flow_cnt  ;            // 转态流控制
reg   [12:0]    wait_cnt  ;            // 计数等待

//*****************************************************
//**                    main code
//*****************************************************

//先向PCF8563中写入初始化日期和时间，再从中读出日期和时间
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
            //上电初始化
            4'd0: begin
                if(wait_cnt == (WAIT_TIME - 13'd1)) begin
                    wait_cnt<= 13'd0;
                    flow_cnt<= flow_cnt + 4'b1;
                end
                else
                    wait_cnt<= wait_cnt + 13'b1;
            end
            //写读秒
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
            //写读分
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
            //写读时
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
            //写读天
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
            //写读月
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
            //写读年
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
//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           e2prom_rw
// Created by:          正点原子
// Created date:        2023年5月17日14:17:02
// Version:             V1.0
// Descriptions:        EEPROM读写控制模块
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module e2prom_rw(
    input                 clk        , //时钟信号
    input                 rst_n      , //复位信号

    //i2c interface
    output   reg          i2c_rh_wl  , //I2C读写控制信号
    output   reg          i2c_exec   , //I2C触发执行信号
    output   reg  [15:0]  i2c_addr   , //I2C器件内地址
    output   reg  [ 7:0]  i2c_data_w , //I2C要写的数据
    input         [ 7:0]  i2c_data_r , //I2C读出的数据
    input                 i2c_done   , //I2C一次操作完成
    input                 i2c_ack    , //I2C应答标志

    //user interface
    output   reg          rw_done    , //E2PROM读写测试完成
    output   reg          rw_result    //E2PROM读写测试结果 0:失败 1:成功
);

//parameter define
//EEPROM写数据需要添加间隔时间,读数据则不需要
parameter      WR_WAIT_TIME = 14'd5000; //写入间隔时间
parameter      MAX_BYTE     = 16'd256 ; //读写测试的字节个数

//reg define
reg   [1:0]    flow_cnt  ; //状态流控制
reg   [13:0]   wait_cnt  ; //延时计数器

//*****************************************************
//**                    main code
//*****************************************************

//EEPROM读写测试,先写后读，并比较读出的值与写入的值是否一致
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
                wait_cnt <= wait_cnt + 14'b1;               //延时计数
                if(wait_cnt == (WR_WAIT_TIME - 14'b1)) begin  //EEPROM写操作延时完成
                    wait_cnt <= 14'b0;
                    if(i2c_addr == MAX_BYTE) begin         //256个字节写入完成
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
                if(i2c_done == 1'b1) begin                  //EEPROM单次写入完成
                    flow_cnt   <= 2'd0;
                    i2c_addr   <= i2c_addr + 16'b1;           //地址0~255分别写入
                    i2c_data_w <= i2c_data_w + 8'b1;         //数据0~255
                end    
            end
            2'd2 : begin                                   
                flow_cnt <= flow_cnt + 2'b1;
                i2c_exec <= 1'b1;
            end    
            2'd3 : begin
                if(i2c_done == 1'b1) begin                 //EEPROM单次读出完成
                    //读出的值错误或者I2C未应答,读写测试失败
                    if((i2c_addr[7:0] != i2c_data_r) || (i2c_ack == 1'b1)) begin
                        rw_done <= 1'b1;
                        rw_result <= 1'b0;
                    end
                    else if(i2c_addr == (MAX_BYTE - 16'b1))begin //读写测试成功
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

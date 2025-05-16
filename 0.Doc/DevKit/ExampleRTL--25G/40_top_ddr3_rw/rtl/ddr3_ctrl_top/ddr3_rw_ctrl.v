//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ddr3_rw_ctrl
// Created by:          正点原子
// Created date:        2023年2月3日14:17:02
// Version:             V1.0
// Descriptions:        ddr3_rw_ctrl
//
//----------------------------------------------------------------------------------------
//****************************************************************************************///

module ddr3_rw_ctrl(
    input                   rst_n,
    input                   clk,
    input [27:0]            addr_rd_min ,   //读 ddr3 的起始地址
    input [27:0]            addr_rd_max ,   //读 ddr3 的结束地址
    input [9:0]             rd_burst_len ,  //从 ddr3 中读数据时的突发长度
    input [27:0]            addr_wd_min ,   //写 ddr3 的起始地址
    input [27:0]            addr_wd_max ,   //写 ddr3 的结束地址
    input [9:0]             wd_burst_len ,  //从 ddr3 中读数据时的突发长度
    //与fifo交互信号    
    input    [10:0]         rfifo_wcount,   //读fifo的写入数据量clk
    input    [10:0]         wfifo_rcount,   //写fifo的写入数据量
    // ddr3交互信号
    input                   ddr3_init_done,
    input                   wd_finish,
    output   reg            wd_req,         //写请求信号 
    output   reg [27:0]     wd_addr,        //写地址信号
    output   reg [9:0]      wd_len,         //写突发次数
    input                   rd_finish,   
    output  reg             rd_req,
    output  reg [27:0]      rd_addr,
    output  reg  [9:0]      rd_len
);
//localparam define
localparam IDLE      = 4'd0;
localparam DDR3_DONE = 4'd1;
localparam WRITE     = 4'd2;
localparam READ      = 4'd3;
//reg define
reg [3:0]   state_cnt;
reg [27:0]  addr_rd_min_d0;
reg [27:0]  addr_rd_max_d0;
reg [27:0]  addr_wd_min_d0;
reg [27:0]  addr_wd_max_d0;
reg [9:0]   rd_burst_len_d0;
reg [9:0]   wd_burst_len_d0;

//*****************************************************
//**                    main code
//*****************************************************

//对异步信号进行打拍处理
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        addr_rd_min_d0 <= 28'b0; 
        addr_rd_max_d0 <= 28'b0;
        rd_burst_len_d0 <= 10'b0;
        addr_wd_min_d0 <= 28'b0; 
        addr_wd_max_d0 <= 28'b0;
        wd_burst_len_d0 <= 10'b0;
    end
    else begin
        addr_rd_min_d0 <= addr_rd_min; 
        addr_rd_max_d0 <= addr_rd_max;
        rd_burst_len_d0 <= rd_burst_len;
        addr_wd_min_d0 <= addr_wd_min; 
        addr_wd_max_d0 <= addr_wd_max;
        wd_burst_len_d0 <= wd_burst_len;
    end
end

//ddr3读写状态跳转
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state_cnt <= IDLE;
        wd_addr <= addr_wd_min;
        rd_addr <= addr_rd_min;
        wd_req <= 1'b0;
        wd_len <= 10'd0;
        rd_req <= 1'b0;
        rd_len <= 10'b0;
    end
    else begin
        case(state_cnt)
            IDLE : begin
                if(ddr3_init_done)
                    state_cnt <= DDR3_DONE;
                else
                    state_cnt <= IDLE;
            end
            DDR3_DONE : begin//当读到结束地址对读地址计数器清零
                if(rd_addr >= addr_rd_max_d0[27:3])begin        
                //DDR单次突发法长度为8，所以最大地址除以八
                    state_cnt <= DDR3_DONE;
                    rd_addr <= addr_rd_min_d0;
                end
                //当写到结束地址对写地址计数器清零
                else if(wd_addr >= addr_wd_max_d0[27:3])begin  
                //DDR单次突发法长度为8，所以最大地址除以八
                    state_cnt <= DDR3_DONE;
                    wd_addr <= addr_wd_min_d0;
                end
                // wfifo 的存储深度大于一次突发长度
                else if(wfifo_rcount >= (wd_burst_len_d0 - 2'd1))begin
                    state_cnt <= WRITE;
                    wd_addr <= wd_addr;
                end
                // rfifo 的存储深度小于一次突发长度
                else if(rfifo_wcount <= (rd_burst_len_d0 -2'd1))begin
                    state_cnt <= READ;
                    rd_addr <= rd_addr;
                end
                else begin
                    state_cnt <= state_cnt;
                end
            end    
            WRITE : begin
                // 一次突发写完成
                if(wd_finish)begin
                    state_cnt <= DDR3_DONE;
                    wd_addr <= wd_addr + wd_burst_len_d0;
                end
                // wfifo 
                else if(wfifo_rcount < (wd_burst_len_d0 -2'd1))
                    wd_req <= 1'b0;
                else begin
                    wd_len <= wd_burst_len_d0;
                    wd_req <= 1'b1;
                end
            end
            READ : begin
                if(rd_finish)begin
                    state_cnt <= DDR3_DONE;
                    rd_addr <= rd_addr + rd_burst_len_d0;
                end
                else if(rfifo_wcount > (rd_burst_len_d0 -2'd1))
                    rd_req <= 1'b0;
                else begin
                    rd_len <= rd_burst_len_d0;
                    rd_req <= 1'b1;
                end
            end
            default:begin
                state_cnt <= IDLE;
            end
        endcase
    end
end 
endmodule
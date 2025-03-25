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
//****************************************************************************************//

module ddr3_rw_ctrl(
    input                   rst_n               ,
    input                   clk                 ,
    input                   ddr3_init_done      ,
    //地址
    input       [27:0]      addr_rd_min         ,   //读 ddr3 的起始地址
    input       [27:0]      addr_rd_max         ,   //读 ddr3 的结束地址
    input       [9:0]       rd_burst_len        ,   //从 ddr3 中读数据时的突发长度
    input       [27:0]      addr_wd_min         ,   //写 ddr3 的起始地址
    input       [27:0]      addr_wd_max         ,   //写 ddr3 的结束地址
    input       [9:0]       wd_burst_len        ,   //从 ddr3 中读数据时的突发长度
    input                   ddr3_pingpang_en    ,   // DDR3 乒乓操作
    input                   ddr3_read_valid     ,
    //源更新
    input                   rd_load             ,   //输出源更新
    input                   wd_load_1           ,   //输入源更新
    input                   wd_load_2           ,   //输入源更新
    //通道一
    input       [10:0]      rfifo_wcount_1      ,   //读fifo的写入数据量clk
    input       [10:0]      wfifo_rcount_1      ,   //写fifo的写入数据量
    output  reg             wfifo_rd_en_1       ,   //从FIFO向DDR写入数据请求
    input       [127:0]     wfifo_rd_data_1     ,   //从FIFO向DDR写入的数据
    output  reg             rfifo_wd_en_1       ,   //从DDR向FIFO写入数据请求
    output  reg [127:0]     rfifo_wd_data_1     ,   //从DDR向FIFO写入的数据
    //通道二
    input       [10:0]      rfifo_wcount_2      ,   //读fifo的写入数据量clk
    input       [10:0]      wfifo_rcount_2      ,   //写fifo的写入数据量
    output  reg             wfifo_rd_en_2       ,   //从FIFO向DDR写入数据请求
    input       [127:0]     wfifo_rd_data_2     ,   //从FIFO向DDR写入的数据
    output  reg             rfifo_wd_en_2       ,   //从DDR向FIFO写入数据请求
    output  reg [127:0]     rfifo_wd_data_2     ,   //从DDR向FIFO写入的数据
    // ddr3交互信号
    input                   wd_fifo_re          ,   //wfifo的读请求信号
    input                   wd_finish           ,   //一次突发长度写完成信号
    output  reg             wd_req              ,   //写请求信号 
    output  reg [27:0]      wd_addr             ,   //写地址信号
    output  reg [9:0]       wd_len              ,   //写突发次数
    input                   rd_fifo_we          ,   //rfifo的写请求信号
    input                   rd_finish           ,   //一次突发长度读完成信号
    output  reg             rd_req              ,   //读请求信号
    output  reg [27:0]      rd_addr             ,   //读地址信号
    output  reg [9:0]       rd_len              ,   //一次读突发长度
    //数据   
    output  reg [127:0]     wd_ddr3_data        ,   //从FIFO中向DDR传输的数据
    input       [127:0]     rd_ddr3_data            //从DDR中向FIFO传输的数据

);
//localparam define
localparam IDLE      = 7'd0 ;
localparam DDR3_DONE = 7'd1 ;
localparam WRITE_1   = 7'd2 ;
localparam READ_1    = 7'd3 ;
localparam WRITE_2   = 7'd4 ;
localparam READ_2    = 7'd5 ;
//reg define
reg [6:0]   state_cnt           ;
reg [27:0]  addr_rd_min_d0      ;
reg [27:0]  addr_rd_max_d0      ;
reg [27:0]  addr_wd_min_d0      ;
reg [27:0]  addr_wd_max_d0      ;
reg [9:0]   rd_burst_len_d0     ;
reg [9:0]   wd_burst_len_d0     ;
reg         init_start          ;
reg         rd_load_d0          ;
reg         rd_load_d1          ;
reg         wd_load_1_d0        ;
reg         wd_load_1_d1        ;
reg         wd_load_2_d0        ;
reg         wd_load_2_d1        ;
reg  [27:0] rd_addr_n           ;
reg  [27:0] wd_addr_n           ;
reg         waddr_page_1        ;       //通道一的写地址切换
reg         raddr_page_1        ;       //通道一的读地址切换
reg         waddr_page_2        ;       //通道二的写地址切换
reg         raddr_page_2        ;       //通道二的读地址切换
reg         wd_rst_1            ;
reg         wd_rst_2            ;
reg         rd_rst              ;
reg         raddr_rst_h         ;
reg [10:0]  raddr_rst_h_cnt     ;
reg [27:0]  wd_addr_1           ;       //通道一的写地址
reg [27:0]  wd_addr_2           ;       //通道二的写地址
reg [27:0]  rd_addr_1           ;       //通道一的读地址
reg [27:0]  rd_addr_2           ;       //通道二的读地址
reg         wd_end_1            ;
reg         wd_end_2            ;
reg         rd_end_1            ;
reg         rd_end_2            ; 

//*****************************************************
//**                    main code
//*****************************************************

//FIFO读写请求与数据
always @(*) begin
    if(!rst_n)begin
        wfifo_rd_en_1 <= 1'b0;
        wfifo_rd_en_2 <= 1'b0;
        rfifo_wd_en_1 <= 1'b0;
        rfifo_wd_en_2 <= 1'b0;
        wd_ddr3_data <=128'b0;
        rfifo_wd_data_1 <= 128'b0;
        rfifo_wd_data_2 <= 128'b0;
    end
    else begin 
        case (state_cnt)
        WRITE_1: begin
            wfifo_rd_en_1 <= wd_fifo_re;
            wd_ddr3_data <= wfifo_rd_data_1;
        end
        WRITE_2: begin
            wfifo_rd_en_2 <= wd_fifo_re;
            wd_ddr3_data <= wfifo_rd_data_2;
        end
        READ_1: begin
            rfifo_wd_en_1 <= rd_fifo_we;
            rfifo_wd_data_1 <= rd_ddr3_data;
        end
        READ_2: begin 
            rfifo_wd_en_2 <= rd_fifo_we;
            rfifo_wd_data_2 <= rd_ddr3_data;
        end
            default: begin
                wfifo_rd_en_1 <= 1'b0;
                wfifo_rd_en_2 <= 1'b0;
                rfifo_wd_en_1 <= 1'b0;
                rfifo_wd_en_2 <= 1'b0;
                wd_ddr3_data <= 128'b0;
                rfifo_wd_data_1 <= 128'b0;
                rfifo_wd_data_2 <= 128'b0;
            end
        endcase
    end
end

// 乒乓操作
always @(*) begin
    if(!rst_n)begin
        rd_addr <= 28'b0;
        wd_addr <= 28'b0;
    end
    else if(ddr3_pingpang_en) begin
        if(state_cnt == READ_1)
            rd_addr <= {3'b0,1'b0,raddr_page_1,rd_addr_1[22:0]};
        else if(state_cnt == WRITE_1)
            wd_addr <= {3'b0,1'b0,waddr_page_1,wd_addr_1[22:0]};
        else if(state_cnt == READ_2)
            rd_addr <= {3'b0,1'b1,raddr_page_2,rd_addr_2[22:0]};
        else if(state_cnt == WRITE_2)
            wd_addr <= {3'b0,1'b1,waddr_page_2,wd_addr_2[22:0]};
    end
    else begin
        rd_addr <= 28'b0;
        wd_addr <= 28'b0;
    end
end


//输出源更新 
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        rd_load_d0 <= 1'b0;
        rd_load_d1 <= 1'b0;
    end
    else begin
        rd_load_d0 <= rd_load;
        rd_load_d1 <= rd_load_d0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rd_rst <= 1'b0;
    else if(rd_load_d0 && (!rd_load_d1))
        rd_rst <= 1'b1;
    else
        rd_rst <= 1'b0;
end


/****************通道一的读写区域切换******************/
//对信号进行打拍处理
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        wd_load_1_d0 <= 1'b0;
        wd_load_1_d1 <= 1'b0;
    end
    else begin
        wd_load_1_d0 <= wd_load_1;
        wd_load_1_d1 <= wd_load_1_d0;
    end
end

//对输入通道一做帧复位标志
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        wd_rst_1 <= 1'b0;
    else if(wd_load_1_d0 && (!wd_load_1_d1))
        wd_rst_1 <= 1'b1;
    else
        wd_rst_1 <= 1'b0;
end

//对输出通道一的写地址做位切换
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        raddr_page_1 <= 1'b0;
    else if(rd_rst)
        raddr_page_1 <= ~waddr_page_1;
    else
        raddr_page_1 <= raddr_page_1;
end

//对输入通道一的写地址做位切换
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        waddr_page_1 <= 1'b0;
    else if(wd_rst_1)begin
        waddr_page_1 <= ~waddr_page_1;   
    end
    else
        waddr_page_1 <= waddr_page_1;
end

/****************通道二的读写区域切换******************/
//对信号进行打拍处理
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        wd_load_2_d0 <= 1'b0;
        wd_load_2_d1 <= 1'b0;
    end
    else begin
        wd_load_2_d0 <= wd_load_2;
        wd_load_2_d1 <= wd_load_2_d0;
    end 
end

//对输入通道二做帧复位标志
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        wd_rst_2 <= 1'b0;       
    else if(wd_load_2_d0 && (!wd_load_2_d1))
        wd_rst_2 <= 1'b1;
    else
        wd_rst_2 <= 1'b0;
end

//对输出通道二的写地址做位切换
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        raddr_page_2 <= 1'b0;
    else if(rd_rst)
        raddr_page_2 <= ~waddr_page_2;
    else
        raddr_page_2 <= raddr_page_2;
end

//对输入通道二的写地址做位切换
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        waddr_page_2 <= 1'b0;
    else if(wd_rst_2)
        waddr_page_2 <= ~waddr_page_2;
    else
        waddr_page_2 <= waddr_page_2;
end

//对输出源的读地址做个帧复位脉冲
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        raddr_rst_h <= 1'b0;
    else if(rd_load_d0 && !rd_load_d1)
        raddr_rst_h <= 1'b1;
    else if((state_cnt == READ_1) || (state_cnt == READ_2))
        raddr_rst_h <= 1'b0;
    else
        raddr_rst_h <= raddr_rst_h;
end

//对输出源的帧复位脉冲进行计数
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        raddr_rst_h_cnt <= 11'b0;
    else if(raddr_rst_h) begin
        if(raddr_rst_h_cnt >= 10'd1000)
            raddr_rst_h_cnt <= raddr_rst_h_cnt;
        else
            raddr_rst_h_cnt <= raddr_rst_h_cnt + 1'b1;
    end
    else
        raddr_rst_h_cnt <= 11'b0;
end



//DDR3读写
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state_cnt <= IDLE;
        wd_addr_1 <= addr_wd_min;       //通道1的写起始地址
        wd_addr_2 <= addr_wd_min;       //通道2的写起始地址
        rd_addr_1 <= addr_rd_min;       //通道1的读起始地址
        rd_addr_2 <= addr_rd_min;       //通道2的读起始地址
        wd_len <= 10'd0;                //一次写突发长度
        rd_len <= 10'b0;                //一次读突发长度       
    end
    else begin
        case(state_cnt)
            IDLE : begin
                if(ddr3_init_done)
                    state_cnt <= DDR3_DONE;
                else
                    state_cnt <= IDLE;
            end
            DDR3_DONE : begin
                //当wfifo1的存储深度大于一次突发，跳转到写操作1
                if(wfifo_rcount_1 >= (wd_burst_len - 1'd1))begin
                    state_cnt <= WRITE_1;
                   // wd_addr_1 <= wd_addr_1;
                end
                //当wfifo2存储数据超过一次突发长度时，跳转到写操作2
                else if(wfifo_rcount_2 >= (wd_burst_len - 1'd1))begin
                    state_cnt <= WRITE_2;
                   // wd_addr_2 <= wd_addr_2;
                end
               //当帧复位到来时，对寄存器进行复位
                else if(raddr_rst_h)begin        //当帧复位到来时，对寄存器进行复位 
                    if(raddr_rst_h_cnt >= 10'd1000 )
                        state_cnt <= READ_1;
                    else
                        state_cnt <= DDR3_DONE;
                    end
                //当rfifo1存储数据少于设定阈值时，并且输入源1已经写入ddr 1帧数据
                else if(rfifo_wcount_1 < (rd_burst_len - 1'b1))        //跳到读操作1
                    state_cnt <= READ_1;
                //当rfifo1存储数据少于设定阈值时，并且输入源1已经写入ddr 1帧数据 
                else if(rfifo_wcount_2 < (rd_burst_len - 1'b1))
                    state_cnt <=  READ_2;
                else
                    state_cnt <= state_cnt;
                  //当帧复位到来时，对信号进行复位  
                if(raddr_rst_h)begin
                    rd_addr_1 <= addr_rd_min;
                    rd_addr_2 <= addr_rd_min;
                end
                else if(rfifo_wcount_1 <= (rd_burst_len - 1'b1))
                    rd_addr_1 <= rd_addr_1;
                else if(rfifo_wcount_2 <= (rd_burst_len - 1'b1))
                    rd_addr_2 <= rd_addr_2;
                else begin
                    rd_addr_1 <= rd_addr_1;
                    rd_addr_2 <= rd_addr_2;                    
                end

                //当帧复位到来时，对信号进行复位
                if(wd_rst_1)
                    wd_addr_1 <= addr_wd_min;					
			    //当wfifo存储数据超过一次突发长度时
                else if(wfifo_rcount_1 >= (wd_burst_len - 1'd1))
                    wd_addr_1 <= wd_addr_1;            //写地址保持不变
                else
                    wd_addr_1 <= wd_addr_1;
                
                //当帧复位到来时，对信号进行复位
                if(wd_rst_2)
                    wd_addr_2 <= addr_wd_min;					                  
                //当wfifo存储数据超过一次突发长度时
                else if(wfifo_rcount_2 >= (wd_burst_len - 1'd1))
                    wd_addr_2 <= wd_addr_2;            //写地址保持不变
                 else
                    wd_addr_2  <= wd_addr_2;
            end
            WRITE_1:begin
                // 一次突发写完成
                if(wd_finish)begin
                    state_cnt <= DDR3_DONE;
                    wd_addr_1 <= wd_addr_1 + wd_burst_len;
                end
                // wfifo 
                else if(wfifo_rcount_1 < (wd_burst_len -1'd1))
                    wd_req <= 1'b0;
                else begin
                    wd_len <= wd_burst_len;
                    wd_req <= 1'b1;
                end
            end
            WRITE_2:begin
                // 一次突发写完成
                if(wd_finish)begin
                    state_cnt <= DDR3_DONE;
                    wd_addr_2 <= wd_addr_2 + wd_burst_len;
                end
                // wfifo 
                else if(wfifo_rcount_2 < (wd_burst_len -2'd1))
                    wd_req <= 1'b0;
                else begin
                    wd_len <= wd_burst_len;
                    wd_req <= 1'b1;
                end
            end
            READ_1:begin
                if(rd_finish)begin
                    state_cnt <= DDR3_DONE;
                    rd_addr_1 <= rd_addr_1 + rd_burst_len;
                end
                else if(rfifo_wcount_1 > (rd_burst_len -1'b1))begin
                    rd_req <= 1'b0;
                end
                else begin
                    rd_len <= rd_burst_len;
                    rd_req <= 1'b1;
                end
            end
            READ_2:begin
                if(rd_finish)begin
                    state_cnt <= DDR3_DONE;
                    rd_addr_2 <= rd_addr_2 + rd_burst_len;
                end
                else if(rfifo_wcount_2 > (rd_burst_len - 1'b1)) begin
                    rd_req <= 1'b0;
                end
                else begin
                    rd_len <= rd_burst_len;
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
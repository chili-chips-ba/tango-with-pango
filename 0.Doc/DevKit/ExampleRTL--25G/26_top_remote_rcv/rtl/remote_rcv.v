//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           remote_rcv
// Last modified Date:  2023��9��8��13:11:06
// Last Version:        V1.0
// Descriptions:        ��������
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2023��9��8��13:11:06
// Version:             V1.0
// Descriptions:        The original version
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module remote_rcv(
    input                  sys_clk   ,  //ϵͳʱ��
    input                  sys_rst_n ,  //ϵͳ��λ�źţ��͵�ƽ��Ч
    
    input                  remote_in ,  //��������ź�
    output    reg          repeat_en ,  //�ظ�����Ч�ź�
    output    reg          data_en   ,  //������Ч�ź�
    output    reg  [7:0]   data         //���������
    );

//parameter define
parameter  st_idle           = 5'b0_0001;  //����״̬
parameter  st_start_low_9ms  = 5'b0_0010;  //���ͬ����͵�ƽ
parameter  st_start_judge    = 5'b0_0100;  //�ж��ظ����ͬ����ߵ�ƽ(�����ź�)
parameter  st_rec_data       = 5'b0_1000;  //��������
parameter  st_repeat_code    = 5'b1_0000;  //�ظ���

//reg define
reg    [4:0]    cur_state      ;
reg    [4:0]    next_state     ;

reg    [11:0]   div_cnt        ;  //��Ƶ������
reg             div_clk        ;  //��Ƶʱ��
reg             remote_in_d0   ;  //������ĺ����ź���ʱ����
reg             remote_in_d1   ;
reg    [7:0]    time_cnt       ;  //�Ժ���ĸ���״̬���м���

reg             time_cnt_clr   ;  //�����������ź�
reg             time_done      ;  //��ʱ����ź�
reg             error_en       ;  //�����ź�
reg             judge_flag     ;  //�����ı�־�ź� 0:ͬ����ߵ�ƽ(�����ź�)  1:�ظ���
reg    [15:0]   data_temp      ;  //�ݴ��յ��Ŀ�����Ϳ��Ʒ���
reg    [5:0]    data_cnt       ;  //�Խ��յ����ݽ��м���       
//wire define
wire            pos_remote_in  ;  //��������źŵ�������
wire            neg_remote_in  ;  //��������źŵ��½���

//*****************************************************
//**                    main code
//*****************************************************

assign  pos_remote_in = (~remote_in_d1) & remote_in_d0;
assign  neg_remote_in = remote_in_d1 & (~remote_in_d0);

//ʱ�ӷ�Ƶ,50Mhz/(2*(3124+1))=8khz,T=0.125ms
always @(posedge sys_clk or negedge sys_rst_n  ) begin
    if (!sys_rst_n) begin
        div_cnt <= 12'd0;
        div_clk <= 1'b0;
    end    
    else if(div_cnt == 12'd3124) begin
        div_cnt <= 12'd0;
        div_clk <= ~div_clk;
    end    
    else
        div_cnt <= div_cnt + 12'b1;
end

//�Ժ���ĸ���״̬���м���
always @(posedge div_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        time_cnt <= 8'b0;
    else if(time_cnt_clr)
        time_cnt <= 8'b0;
    else 
        time_cnt <= time_cnt + 8'b1;
end 

//�������remote_in�ź���ʱ����
always @(posedge div_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        remote_in_d0 <= 1'b0;
        remote_in_d1 <= 1'b0;
    end
    else begin
        remote_in_d0 <= remote_in;
        remote_in_d1 <= remote_in_d0;
    end
end

//״̬��
always @ (posedge div_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cur_state <= st_idle;
    else
        cur_state <= next_state ;
end

always @(*) begin
    next_state = st_idle;
    case(cur_state)
        st_idle : begin                           //����״̬
            if(remote_in_d0 == 1'b0)
                next_state = st_start_low_9ms;
            else
                next_state = st_idle;            
        end
        st_start_low_9ms : begin                  //���ͬ����͵�ƽ
            if(time_done)
                next_state = st_start_judge;
            else if(error_en)
                next_state = st_idle;
            else
                next_state = st_start_low_9ms;
        end
        st_start_judge : begin                    //�ж��ظ����ͬ����ߵ�ƽ(�����ź�)
            if(time_done) begin
                if(judge_flag == 1'b0)
                    next_state = st_rec_data;
                else 
                    next_state = st_repeat_code;
            end
            else if(error_en)
                next_state = st_idle;
            else
                next_state = st_start_judge;
        end
        st_rec_data : begin                       //��������
            if(pos_remote_in && data_cnt == 6'd32) 
                next_state = st_idle;
            else
                next_state = st_rec_data;                
        end
        st_repeat_code : begin                    //�ظ���
            if(pos_remote_in)
                next_state = st_idle;
            else
                next_state = st_repeat_code;    
        end    
        default : next_state = st_idle;
    endcase
end

always @(posedge div_clk or negedge sys_rst_n ) begin 
    if (!sys_rst_n) begin  
        time_cnt_clr <= 1'b0;
        time_done <= 1'b0;
        error_en <= 1'b0;
        judge_flag <= 1'b0;
        data_en <= 1'b0;
        data <= 8'd0;
        repeat_en <= 1'b0;
        data_cnt <= 6'd0;
        data_temp <= 32'd0;
    end
    else begin
        time_cnt_clr <= 1'b0;
        time_done <= 1'b0;
        error_en <= 1'b0;
        repeat_en <= 1'b0;
        data_en <= 1'b0;
        case(cur_state)
            st_idle           : begin
                if(remote_in_d0 == 1'b0)
                    time_cnt_clr <= 1'b0;
                else
                    time_cnt_clr <= 1'b1;
            end   
            st_start_low_9ms  : begin                             //9ms/0.125ms = 72
                if(pos_remote_in) begin                                      
                    if(time_cnt >= 69 && time_cnt <= 75)begin
                        time_done <= 1'b1;
                        error_en <= 1'b0;
                        time_cnt_clr <= 1'b1;
                    end
                    else begin
                        error_en <= 1'b1;
                        time_done <= 1'b1;
                        time_cnt_clr <= 1'b1;
                    end
                end   
            end
             st_start_judge : begin
                if(neg_remote_in) begin                         
                    //�ظ���ߵ�ƽ2.25ms 2.25/0.125 = 18      
                    if(time_cnt >= 15 && time_cnt <= 20) begin
                        time_done <= 1'b1;
                        judge_flag <= 1'b1;
                        time_cnt_clr <= 1'b1;
                        error_en <= 1'b0;
                    end    
                    //ͬ����ߵ�ƽ4.5ms 4.5/0.125 = 36
                    else if(time_cnt >= 33 && time_cnt <= 38) begin
                        time_done <= 1'b1;
                        judge_flag <= 1'b0;
                        time_cnt_clr <= 1'b1;
                        error_en <= 1'b0;                        
                    end
                    else begin
                        time_done <= time_done;
                        judge_flag <= judge_flag;
                        time_cnt_clr <= 1'b1;
                        error_en <= 1'b1;   
                    end                    
                end                                      
            end
            st_rec_data : begin 
                if(pos_remote_in || neg_remote_in) 
                    time_cnt_clr <= 1'b1;
                else
                    time_cnt_clr <= 1'b0; 
                if(neg_remote_in) begin                
                    data_cnt <= data_cnt + 1'b1;
                end                                               
                if(pos_remote_in) begin                 
                    if(data_cnt == 6'd32) begin                        
                        if(data_temp[7:0] == ~data_temp[15:8])begin    //У�������Ϳ��Ʒ���
                            data_en <= 1'b1;
                            data_cnt <= 6'd0;
                            data_temp <= 16'd0;
                            data <= data_temp[7:0];
                        end
                        else begin
                            data_en <= 1'b1;
                            data_cnt <= 6'd0;
                            data_cnt <= 6'd0;
                            data <= data;
                        end
                    end
                end
                if(neg_remote_in) begin   //����������Ϳ��Ʒ���                                                                 
                    if(data_cnt >= 6'd16 && data_cnt <= 6'd31) begin 
                        if(time_cnt >= 2 && time_cnt <= 6)   
                            data_temp <= {1'b0,data_temp[15:1]};  //�߼���0��                        
                        else if(time_cnt >= 10 && time_cnt <= 15) 
                            data_temp <= {1'b1,data_temp[15:1]};  //�߼���1��
                        else 
                            data_temp <= data_temp;
                    end
                end
            end
            st_repeat_code : begin                                
                if(pos_remote_in) begin                           
                    time_cnt_clr <= 1'b1;
                    repeat_en <= 1'b1;
                end
                else begin
                    time_cnt_clr <= time_cnt_clr;
                    repeat_en <= repeat_en;
                end
            end
            default : ;
        endcase
    end
end

endmodule
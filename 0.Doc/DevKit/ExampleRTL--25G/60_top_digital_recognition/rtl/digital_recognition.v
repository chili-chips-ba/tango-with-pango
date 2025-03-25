//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�http://www.openedv.com/forum.php
//�Ա����̣�https://zhengdianyuanzi.tmall.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2023-2033
//All rights reserved    
//----------------------------------------------------------------------------------------
// File name:           digital_recognition
// Last modified Date:  2023/05/04 9:19:08
// Last Version:        V1.0
// Descriptions:        ��������ʶ��ģ��
//                      
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/05/04 9:19:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module digital_recognition #(
    parameter NUM_ROW =  1 ,
    parameter NUM_COL =  4 ,
    parameter NUM_WIDTH = (NUM_ROW*NUM_COL<<2)-1
)(
    //module clock
    input                    clk              ,  // ʱ���ź�
    input                    rst_n            ,  // ��λ�źţ�����Ч��

    //image data interface
    input                    monoc            ,  // ��ɫͼ����������
    input                    monoc_fall       ,  // ͼ�����ݱ仯
    input      [10:0]        xpos             ,  //������
    input      [10:0]        ypos             ,  //������
    output reg [15:0]        color_rgb        ,  //���ͼ������

    //project border ram interface
    input      [10:0]        row_border_data  ,  //�б߽�ram������
    output reg [10:0]        row_border_addr  ,  //�б߽�ram����ַ
    input      [10:0]        col_border_data  ,  //�б߽�ram������
    output reg [10:0]        col_border_addr  ,  //�б߽�ram����ַ

    //user interface
    input      [ 1:0]        frame_cnt        ,  // ��ǰ֡
    input                    project_done_flag,  // ͶӰ��ɱ�־
    input      [ 3:0]        num_col          ,  // �ɼ�������������
    input      [ 3:0]        num_row          ,  // �ɼ�������������
    output reg [NUM_WIDTH:0] digit               // ʶ�𵽵�����
);

//localparam define
localparam FP_1_3 = 6'b010101;                   // 1/3 С���Ķ��㻯
localparam FP_2_3 = 6'b101011;                   // 2/3 
localparam FP_2_5 = 6'b011010;                   // 2/5 
localparam FP_3_5 = 6'b100110;                   // 3/5 
localparam NUM_TOTAL = NUM_ROW * NUM_COL - 1'b1; // ��ʶ������ֹ�������ʼ��0

//reg define
reg  [10:0]        col_border_l                    ;  //��߽�
reg  [10:0]        col_border_r                    ;  //�ұ߽�
reg  [10:0]        row_border_low                  ;  //�±߽�
reg  [10:0]        row_border_high                 ;  //�ϱ߽�
reg  [16:0]        row_border_low_t                ;
reg  [16:0]        row_border_high_t               ;  
reg                x1_l     [NUM_TOTAL:0]          ;  //x1�����������
reg                x1_r     [NUM_TOTAL:0]          ;  //x1���ұ������� 
reg                x2_l     [NUM_TOTAL:0]          ;  //x2�����������
reg                x2_r     [NUM_TOTAL:0]          ;  //x2���ұ�������
reg  [ 1:0]        y        [NUM_TOTAL:0]          ;  //y��������
reg  [ 1:0]        y_flag   [NUM_TOTAL:0]          ;  //y�����ϵ�����  
reg                row_area [NUM_ROW - 1'b1:0]     ;  // ������
reg                col_area [NUM_TOTAL     :0]     ;  // ������
reg  [ 3:0]        row_cnt,row_cnt_t               ;  //�����м���
reg  [ 3:0]        col_cnt,col_cnt_t               ;  //�����м���
reg  [11:0]        cent_y_t                        ;
reg  [10:0]        v25                             ;  // �б߽��2/5
reg  [10:0]        v23                             ;  // �б߽��2/3
reg  [22:0]        v25_t                           ;
reg  [22:0]        v23_t                           ;
reg  [ 5:0]        num_cnt                         ;  //����������
reg                row_d0,row_d1                   ;
reg                col_d0,col_d1                   ;
reg                row_chg_d0,row_chg_d1,row_chg_d2;
reg                row_chg_d3                      ;
reg                col_chg_d0,col_chg_d1,col_chg_d2;
reg  [ 7:0]        real_num_total                  ;  //������������
reg  [ 3:0]        digit_id                        ; 
reg  [ 3:0]        digit_cnt                       ;  //���������ܸ���������
reg  [NUM_WIDTH:0] digit_t                         ;
reg  [10:0]        cent_y                          ;  //�������ֵ��м������

//wire define
wire        y_flag_fall ;
wire        col_chg     ;
wire        row_chg     ;
wire        feature_deal;  //�������������Ч�ź�              

//*****************************************************
//**                    main code
//*****************************************************
assign row_chg = row_d0 ^ row_d1;
assign col_chg = col_d0 ^ col_d1;
assign y_flag_fall  = ~y_flag[num_cnt][0] & y_flag[num_cnt][1];
assign feature_deal = project_done_flag && frame_cnt == 2'd2; // ��������

//ʵ�ʲɼ�������������
always @(*) begin
    if(project_done_flag)
        real_num_total = num_col * num_row;
end


//����б仯
always @(posedge clk) begin
    if(project_done_flag) begin
        row_cnt_t <= row_cnt;
        row_d1    <= row_d0 ;
        if(row_cnt_t != row_cnt)
            row_d0 <= ~row_d0;
    end
    else begin
        row_d0 <= 1'b1;
        row_d1 <= 1'b1;
        row_cnt_t <= 4'hf;
    end
end

//��ȡ���ֵ��б߽�
always @(posedge clk) begin
    if(row_chg)
        row_border_addr <= (row_cnt << 1'b1) + 1'b1;
    else
        row_border_addr <= row_cnt << 1'b1;
end

always @(posedge clk) begin
    if(row_border_addr[0])
        row_border_low <= row_border_data;
    else
        row_border_high <= row_border_data;
end

always @(posedge clk) begin
    row_chg_d0 <= row_chg;
    row_chg_d1 <= row_chg_d0;
    row_chg_d2 <= row_chg_d1;
    row_chg_d3 <= row_chg_d2;
end

//����б仯
always @(posedge clk) begin
    if(project_done_flag) begin
        col_cnt_t <= col_cnt;
        col_d1    <= col_d0;
        if(col_cnt_t != col_cnt)
            col_d0 <= ~col_d0;
    end
    else begin
        col_d0 <= 1'b1;
        col_d1 <= 1'b1;
        col_cnt_t <= 4'hf;
    end
end

//��ȡ�������ֵ��б߽�
always @(posedge clk) begin
    if(col_chg)
        col_border_addr <= (col_cnt << 1'b1) + 1'b1;
    else
        col_border_addr <= col_cnt << 1'b1;
end

always @(posedge clk) begin
    if(col_border_addr[0])
        col_border_r <= col_border_data;
    else
        col_border_l <= col_border_data;
end

always @(posedge clk) begin
    col_chg_d0 <= col_chg;
    col_chg_d1 <= col_chg_d0;
    col_chg_d2 <= col_chg_d1;
end


//��������y
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cent_y_t <= 12'd0;
    else if(project_done_flag) begin
        if(col_chg_d1)
            cent_y_t <= col_border_l + col_border_r;
        if(col_chg_d2)
            cent_y = cent_y_t[11:1];
    end
end

//x1��x2
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        v25 <= 11'd0;
        v23 <= 11'd0;
        v25_t <= 23'd0;
        v23_t <= 23'd0;
        row_border_low_t <= 17'b0;
        row_border_high_t <= 17'b0;
    end
    else if(project_done_flag) begin
        if(row_chg_d1) begin
            row_border_low_t <= { row_border_low,6'b0};
            row_border_high_t <= { row_border_high,6'b0};
        end
        if(row_chg_d2) begin
            v25_t <= row_border_low_t * FP_2_5 + row_border_high_t * FP_3_5;// x1
            v23_t <= row_border_low_t * FP_2_3 + row_border_high_t * FP_1_3;// x2
        end
        if(row_chg_d3) begin
            v25 <= v25_t[22:12];
            v23 <= v23_t[22:12];
        end
    end
end

//������
always @(*) begin
    row_area[row_cnt] = ypos >= row_border_high && ypos <= row_border_low;
end

//������
always @(*) begin
    col_area[col_cnt] = xpos >= col_border_l   && xpos <= col_border_r;
end

//ȷ��col_cnt
always @(posedge clk) begin
    if(project_done_flag) begin
        if(row_area[row_cnt] && xpos == col_border_r)
            col_cnt <= col_cnt == num_col - 1'b1 ? 'd0 : col_cnt + 1'b1;
    end
    else
        col_cnt <= 4'd0;
end

//ȷ��row_cnt
always @(posedge clk) begin
    if(project_done_flag) begin
        if(ypos == row_border_low + 1'b1)
            row_cnt <= row_cnt == num_row - 1'b1 ? 'd0 : row_cnt + 1'b1;
    end
    else
        row_cnt <= 12'd0;
end

//num_cnt��������������ͼ���������
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        num_cnt <= 'd0;
    else if(feature_deal)
        num_cnt <= row_cnt * num_col + col_cnt;
    else if(num_cnt <= NUM_TOTAL)
        num_cnt <= num_cnt + 1'b1;
    else
        num_cnt <= 'd0;
end

//x1��x2��������
always @(posedge clk) begin
    if(feature_deal) begin
        if(ypos == v25) begin
            if(xpos >= col_border_l && xpos <= cent_y && monoc_fall)
                x1_l[num_cnt] <= 1'b1;
            else if(xpos > cent_y && xpos < col_border_r && monoc_fall)
                x1_r[num_cnt] <= 1'b1;
        end
        else if(ypos == v23) begin
            if(xpos >= col_border_l && xpos <= cent_y && monoc_fall)
                x2_l[num_cnt] <= 1'b1;
            else if(xpos > cent_y && xpos < col_border_r && monoc_fall)
                x2_r[num_cnt] <= 1'b1;
        end
    end
    else begin
        x1_l[num_cnt] <= 1'b0;
        x1_r[num_cnt] <= 1'b0;
        x2_l[num_cnt] <= 1'b0;
        x2_r[num_cnt] <= 1'b0;
    end
end

//�Ĵ�y_flag�����½���
always @(posedge clk) begin
    if(feature_deal) begin
        if(row_area[row_cnt] && xpos == cent_y)
            y_flag[num_cnt] <= {y_flag[num_cnt][0],monoc};
    end
    else
        y_flag[num_cnt] <= 2'd3;
end

//Y�����������
always @(posedge clk) begin
    if(feature_deal) begin
        if(xpos == cent_y + 1'b1 && y_flag_fall)
            y[num_cnt] <= y[num_cnt] + 1'd1;
    end
    else
        y[num_cnt] <= 2'd0;
end

//����ƥ��
always @(*) begin
    case({y[digit_cnt],x1_l[digit_cnt],x1_r[digit_cnt],x2_l[digit_cnt],x2_r[digit_cnt]})
        6'b10_1_1_1_1: digit_id = 4'h0; //0
        6'b01_1_0_1_0: digit_id = 4'h1; //1
        6'b11_0_1_1_0: digit_id = 4'h2; //2
        6'b11_0_1_0_1: digit_id = 4'h3; //3
        6'b10_1_1_1_0: digit_id = 4'h4; //4
        6'b11_1_0_0_1: digit_id = 4'h5; //5
        6'b11_1_0_1_1: digit_id = 4'h6; //6
        6'b10_0_1_1_0: digit_id = 4'h7; //7
        6'b11_1_1_1_1: digit_id = 4'h8; //8
        6'b11_1_1_0_1: digit_id = 4'h9; //9
        default: digit_id = 4'h0;
    endcase
end

//ʶ������
always @(posedge clk) begin
    if(feature_deal && ypos == row_border_low + 1'b1) begin
        if(real_num_total == 1'b1)
            digit_t <= digit_id;
        else if(digit_cnt < real_num_total) begin
            digit_cnt <= digit_cnt + 1'b1;
            digit_t   <= {digit_t[NUM_WIDTH-4:0],digit_id};
        end
    end
    else begin
        digit_cnt <= 'd0;
        digit_t   <= 'd0;
    end
end

//���ʶ�𵽵�����
always @(posedge clk) begin
    if(feature_deal && digit_cnt == real_num_total)
        digit <= digit_t;
end

//����߽��ͼ��
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        color_rgb <= 16'h0000;
    else if(row_area[row_cnt] && ( xpos == col_border_l || xpos == col_border_r ||
            xpos == (col_border_l -1) || xpos == (col_border_r+1)))
        color_rgb <= 16'hf800; //������ֱ�߽���
    else if(col_area[col_cnt] && (ypos == row_border_high || ypos== row_border_low ||
            ypos==( row_border_high - 1) || ypos== (row_border_low + 1)))
        color_rgb <= 16'hf800; //����ˮƽ�߽���
    else if(monoc)
        color_rgb <= 16'hffff; //white
    else
        color_rgb <= 16'h0000; //dark
end

endmodule
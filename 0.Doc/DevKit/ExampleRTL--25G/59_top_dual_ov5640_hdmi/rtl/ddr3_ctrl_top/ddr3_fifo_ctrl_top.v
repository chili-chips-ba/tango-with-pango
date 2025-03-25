module ddr3_fifo_ctrl_top(
    input                   rst_n           ,       //��λ�ź�
    input                   rd_clk          ,       //rfifoʱ��
    input  wire             ui_clk          ,       //�û�ʱ��
    //fifo1�ӿ�
    input                   wd_clk_1        ,       //wfifoʱ��
    input                   wd_en_1         ,       //wfifoд�����ź�
    input       [15:0]      wd_data_1       ,       //wfifoд����Ч����
    input                   wd_load_1       ,       //����Դ���ź�   
    input                   rfifo_wd_en_1   ,       //��DDR�������ݵ���Чʹ��
    input       [127:0]     rfifo_wd_data_1 ,       //��DDR����������
    input                   wfifo_rd_en_1   ,       //wfifo��ʹ��
    output      [127:0]     wfifo_rd_data_1 ,       //wfifo�Ķ�������
    output      [10:0]      wfifo_rcount_1  ,       //wfifoʣ�����ݼ���
    output      [10:0]      rfifo_wcount_1  ,       //rfifoд�����ݼ���    
    //fifo2�ӿ�
    input                   wd_clk_2        ,       //wfifoʱ��    
    input                   wd_en_2         ,       //������Чʹ���ź�
    input       [15:0]      wd_data_2       ,       //��Ч����    
    input                   wd_load_2       ,       //����Դ���ź�
    input                   rfifo_wd_en_2   ,       //��DDR�������ݵ���Чʹ��
    input       [127:0]     rfifo_wd_data_2 ,       //��DDR����������
    input                   wfifo_rd_en_2   ,       //wfifo��ʹ��
    output      [127:0]     wfifo_rd_data_2 ,       //wfifo�Ķ�������
    output      [10:0]      wfifo_rcount_2  ,       //wfifoʣ�����ݼ���
    output      [10:0]      rfifo_wcount_2  ,       //rfifoд�����ݼ��� 
    
    input       [12:0]      h_disp          ,
    input                   rd_load         ,       //���Դ���ź�
    input                   rd_en           ,       //�������ź�
    output      [15:0]      rd_data                 //��Ч����
);
//reg define
reg [12:0] rd_cnt;

//wire  define
wire                rd_en_1         ;
wire                rd_en_2         ;
wire    [15:0]      rd_data_1       ;
wire    [15:0]      rd_data_2       ;

//*****************************************************
//**                    main code
//*****************************************************

//������ʾ�����ź��л�������ʾ���������FIFO1���Ҳ�����FIFO2��ʾ
assign rd_en_1 = (rd_cnt <= (h_disp[12:1] - 1'b1)) ? rd_en : 1'b0;
assign rd_en_2 = (rd_cnt <= (h_disp[12:1] - 1'b1)) ? 1'b0 : rd_en;

//��������ʾ����ʾλ�õ��л������������ʾFIFO1���Ҳ���ʾFIFO2
assign rd_data = (rd_cnt <= h_disp[12:1]) ? rd_data_1 : rd_data_2;

//�Զ������źż���
always @(posedge rd_clk or negedge rst_n) begin
    if(!rst_n)
        rd_cnt <= 13'd0;
    else if(rd_en)
        rd_cnt <= rd_cnt + 1'b1;
    else
        rd_cnt <= 0;
end

//ͨ��һ
ctrl_fifo u_ctrl_fifo_1(
    .rst_n         (rst_n           ),
    .wd_clk        (wd_clk_1        ),
    .rd_clk        (rd_clk          ),
    .clk_100       (ui_clk          ),
    .rd_load       (rd_load         ),
    .wr_load       (wd_load_1       ),
    //дFIFOͨ��
    .wfifo_wr_en   (wd_en_1         ),      //������ͷ����FIFO��д�����ź�
    .wfifo_wr_data (wd_data_1       ),      //������ͷ���������
    .wfifo_rd_en   (wfifo_rd_en_1   ),      //��FIFO�ж������ݶ�ʹ���ź�
    .wfifo_rd_data (wfifo_rd_data_1 ),      //��FIFO�ж�������
    .wfifo_rcount  (wfifo_rcount_1   ),      //�ɶ�����������
    //��FIFOͨ��
    .rfifo_wr_en   (rfifo_wd_en_1   ),      //д��FIFOO��д�����ź�
    .rfifo_wr_data (rfifo_wd_data_1 ),      //��DDRд��FIFO������
    .rfifo_wcount  (rfifo_wcount_1  ),      //д������������
    .rfifo_rd_en   (rd_en_1         ),      //��FIFO��������ʹ���ź�
    .rfifo_rd_data (rd_data_1       )       //��FIFO����������
);

//ͨ����
ctrl_fifo u_ctrl_fifo_2(
    .rst_n         (rst_n           ),
    .wd_clk        (wd_clk_2        ),
    .rd_clk        (rd_clk          ),
    .clk_100       (ui_clk          ),
    .rd_load       (rd_load         ),
    .wr_load       (wd_load_2       ),

    .wfifo_wr_en   (wd_en_2         ),
    .wfifo_wr_data (wd_data_2       ),
    .wfifo_rd_en   (wfifo_rd_en_2   ),
    .wfifo_rd_data (wfifo_rd_data_2 ),
    .wfifo_rcount  (wfifo_rcount_2  ),

    .rfifo_wr_en   (rfifo_wd_en_2   ),
    .rfifo_wr_data (rfifo_wd_data_2 ),
    .rfifo_wcount  (rfifo_wcount_2  ),
    .rfifo_rd_en   (rd_en_2         ),
    .rfifo_rd_data (rd_data_2       )
);

endmodule
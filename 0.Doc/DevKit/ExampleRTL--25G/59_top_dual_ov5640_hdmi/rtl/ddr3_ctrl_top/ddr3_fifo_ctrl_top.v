module ddr3_fifo_ctrl_top(
    input                   rst_n           ,       //复位信号
    input                   rd_clk          ,       //rfifo时钟
    input  wire             ui_clk          ,       //用户时钟
    //fifo1接口
    input                   wd_clk_1        ,       //wfifo时钟
    input                   wd_en_1         ,       //wfifo写请求信号
    input       [15:0]      wd_data_1       ,       //wfifo写入有效数据
    input                   wd_load_1       ,       //输入源场信号   
    input                   rfifo_wd_en_1   ,       //从DDR读出数据的有效使能
    input       [127:0]     rfifo_wd_data_1 ,       //从DDR读出的数据
    input                   wfifo_rd_en_1   ,       //wfifo读使能
    output      [127:0]     wfifo_rd_data_1 ,       //wfifo的读出数据
    output      [10:0]      wfifo_rcount_1  ,       //wfifo剩余数据计数
    output      [10:0]      rfifo_wcount_1  ,       //rfifo写进数据计数    
    //fifo2接口
    input                   wd_clk_2        ,       //wfifo时钟    
    input                   wd_en_2         ,       //数据有效使能信号
    input       [15:0]      wd_data_2       ,       //有效数据    
    input                   wd_load_2       ,       //输入源场信号
    input                   rfifo_wd_en_2   ,       //从DDR读出数据的有效使能
    input       [127:0]     rfifo_wd_data_2 ,       //从DDR读出的数据
    input                   wfifo_rd_en_2   ,       //wfifo读使能
    output      [127:0]     wfifo_rd_data_2 ,       //wfifo的读出数据
    output      [10:0]      wfifo_rcount_2  ,       //wfifo剩余数据计数
    output      [10:0]      rfifo_wcount_2  ,       //rfifo写进数据计数 
    
    input       [12:0]      h_disp          ,
    input                   rd_load         ,       //输出源场信号
    input                   rd_en           ,       //读请求信号
    output      [15:0]      rd_data                 //有效数据
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

//像素显示请求信号切换，即显示器左侧请求FIFO1，右侧请求FIFO2显示
assign rd_en_1 = (rd_cnt <= (h_disp[12:1] - 1'b1)) ? rd_en : 1'b0;
assign rd_en_2 = (rd_cnt <= (h_disp[12:1] - 1'b1)) ? 1'b0 : rd_en;

//像素在显示器显示位置的切换，即在左侧显示FIFO1，右侧显示FIFO2
assign rd_data = (rd_cnt <= h_disp[12:1]) ? rd_data_1 : rd_data_2;

//对读请求信号计数
always @(posedge rd_clk or negedge rst_n) begin
    if(!rst_n)
        rd_cnt <= 13'd0;
    else if(rd_en)
        rd_cnt <= rd_cnt + 1'b1;
    else
        rd_cnt <= 0;
end

//通道一
ctrl_fifo u_ctrl_fifo_1(
    .rst_n         (rst_n           ),
    .wd_clk        (wd_clk_1        ),
    .rd_clk        (rd_clk          ),
    .clk_100       (ui_clk          ),
    .rd_load       (rd_load         ),
    .wr_load       (wd_load_1       ),
    //写FIFO通道
    .wfifo_wr_en   (wd_en_1         ),      //从摄像头输入FIFO的写请求信号
    .wfifo_wr_data (wd_data_1       ),      //从摄像头输入的数据
    .wfifo_rd_en   (wfifo_rd_en_1   ),      //从FIFO中读出数据读使能信号
    .wfifo_rd_data (wfifo_rd_data_1 ),      //从FIFO中读出数据
    .wfifo_rcount  (wfifo_rcount_1   ),      //可读数据数据量
    //读FIFO通道
    .rfifo_wr_en   (rfifo_wd_en_1   ),      //写入FIFOO的写请求信号
    .rfifo_wr_data (rfifo_wd_data_1 ),      //从DDR写入FIFO的数据
    .rfifo_wcount  (rfifo_wcount_1  ),      //写入数据数据量
    .rfifo_rd_en   (rd_en_1         ),      //从FIFO读出数据使能信号
    .rfifo_rd_data (rd_data_1       )       //从FIFO读出的数据
);

//通道二
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
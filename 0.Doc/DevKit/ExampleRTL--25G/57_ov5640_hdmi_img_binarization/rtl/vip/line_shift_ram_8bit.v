module line_shift_ram_8bit(
    input          clock, 
    input          rst_n,  
    input          clken,
    input          pre_frame_href,
    
    input   [7:0]  shiftin,  
    output  [7:0]  taps0x,   
    output  [7:0]  taps1x    
);

//reg define
reg  [2:0]  clken_dly;
reg  [10:0] ram_rd_addr;
reg  [10:0] ram_rd_addr_d0;
reg  [10:0] ram_rd_addr_d1;
reg  [7:0]  shiftin_d0;
reg  [7:0]  shiftin_d1;
reg  [7:0]  shiftin_d2;

//*****************************************************
//**                    main code
//*****************************************************

//在数据来到时，ram地址累加
always@(posedge clock)begin
    if(pre_frame_href)
        if(clken)
            ram_rd_addr <= ram_rd_addr + 1 ;
        else
            ram_rd_addr <= ram_rd_addr ;
    else
        ram_rd_addr <= 0 ;
end

//时钟使能信号延迟三拍
always@(posedge clock) begin
    clken_dly <= { clken_dly[1:0] , clken };
end

//将ram地址延迟二拍
always@(posedge clock ) begin
    ram_rd_addr_d0 <= ram_rd_addr;
    ram_rd_addr_d1 <= ram_rd_addr_d0;
end

//输入数据延迟三拍
always@(posedge clock)begin
    shiftin_d0 <= shiftin;
    shiftin_d1 <= shiftin_d0;
    shiftin_d2 <= shiftin_d1;
end

//用于存储前一行图像的RAM
blk_mem_gen_0 u_ram_2048x8_0 (
    .wr_data (shiftin_d2 ),   //input [7:0]ram写数据
    .wr_addr (ram_rd_addr_d1),//input [4:0]ram写地址
    .wr_en   (clken_dly[2]),  //inpu在延迟的第三个时钟周期，当前行的数据写入RAM0
    .wr_clk  (clock ),        //input
    .wr_rst  (~rst_n ),       //input
    .rd_addr (ram_rd_addr ),  //input [4:0]ram读地址
    .rd_data (taps0x ),       //output[7:0]ram读数据延迟一个时钟周期，输出RAM0中前一行图像的数据
    .rd_clk  (clock ),        //input
    .rd_rst  (~rst_n )        //input
);

//用于存储前前一行图像的RAM
blk_mem_gen_0 u_ram_2048x8_1 (
    .wr_data (taps0x),        //input [7:0]ram写数据
    .wr_addr (ram_rd_addr_d1),//input [4:0]ram写地址
    .wr_en   (clken_dly[2] ), //input在延迟的第三个时钟周期，将前一行图像的数据写入RAM1
    .wr_clk  (clock ),        //input
    .wr_rst  (~rst_n ),       //input
    .rd_addr (ram_rd_addr ),  //input [4:0]ram读地址
    .rd_data (taps1x ),       //output[7:0]ram读数据延迟一个时钟周期，输出RAM1中前前一行图像的数据
    .rd_clk  (clock ),        //input
    .rd_rst  (~rst_n )        //input
);
endmodule 
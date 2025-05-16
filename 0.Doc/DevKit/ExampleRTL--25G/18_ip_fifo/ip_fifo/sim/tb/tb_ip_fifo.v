`timescale 1ns / 1ps        //仿真单位/仿真精度

module tb_ip_fifo();

//全局复位
reg  grs_n;
GTP_GRS GRS_INST(
    .GRS_N (grs_n)
    );
    
initial begin
    grs_n = 1'b0;
    #5000 grs_n = 1'b1;
end

//parameter define
parameter  CLK_PERIOD = 20; //时钟周期 20ns

//reg define
reg     sys_clk;
reg     sys_rst_n;

//wire define
wire        fifo_wr_en  ;
wire        fifo_rd_en  ;
wire        fifo_full   ;
wire        fifo_empty  ;
wire  [7:0] fifo_wr_data;
wire  [7:0] fifo_rd_data;

//信号初始化
initial begin
    sys_clk = 1'b0;
    sys_rst_n = 1'b0;
    #200
    sys_rst_n = 1'b1;
end

//产生时钟
always #(CLK_PERIOD/2) sys_clk = ~sys_clk;

ip_fifo u_ip_fifo(
    .sys_clk        (sys_clk     ),
    .sys_rst_n      (sys_rst_n   ),
    .fifo_wr_en     (fifo_wr_en  ), 
    .fifo_rd_en     (fifo_rd_en  ), 
    .fifo_full      (fifo_full   ), 
    .fifo_empty     (fifo_empty  ), 
    .fifo_wr_data   (fifo_wr_data),
    .fifo_rd_data   (fifo_rd_data)
    );

endmodule
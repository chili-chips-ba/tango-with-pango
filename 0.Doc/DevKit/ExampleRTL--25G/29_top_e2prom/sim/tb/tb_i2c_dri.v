`timescale  1ns/1ns                     //定义仿真时间单位1ns和仿真时间精度为1ns

module  tb_i2c_dri;              

//parameter  define
parameter  T = 20;                      //时钟周期为20ns
parameter  IIC_WR_CYCYLE  = 10_000;
parameter  SLAVE_ADDR = 7'b1010000 ;    //EEPROM从机地址
parameter  CLK_FREQ   = 26'd50_000_000; //模块输入的时钟频率
parameter  I2C_FREQ   = 18'd250_000;    //IIC_SCL的时钟频率

//reg define
reg          sys_clk;                   //时钟信号
reg          sys_rst_n;                 //复位信号
     
reg          i2c_exec  ;
reg          bit_ctrl  ;
reg          i2c_rh_wl ;
reg   [15:0] i2c_addr  ;
reg   [7:0]  i2c_data_w;
reg   [3:0]  flow_cnt  ;
reg   [13:0] delay_cnt ;

//wire define
wire  [7:0]  i2c_data_r;
wire         i2c_done  ;
wire         i2c_ack   ;
wire         scl       ;
wire         sda       ;
wire         dri_clk   ;

//*****************************************************
//**                    main code
//*****************************************************

//给输入信号初始值
initial begin
    sys_clk            = 1'b0;
    sys_rst_n          = 1'b0;     //复位
    #(T+1)  sys_rst_n  = 1'b1;     //在第21ns的时候复位信号信号拉高
end

//50Mhz的时钟，周期则为1/50Mhz=20ns,所以每10ns，电平取反一次
always #(T/2) sys_clk = ~sys_clk;

always @(posedge dri_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        i2c_exec <= 1'b0;
        bit_ctrl <= 1'b0;
        i2c_rh_wl <= 1'b0;
        i2c_addr <= 1'b0;
        i2c_data_w <= 1'b0;
        flow_cnt <= 1'b0;
        delay_cnt <= 1'b0;
    end
    else begin
        case(flow_cnt)
            'd0 : flow_cnt <= flow_cnt + 1'b1;
            'd1 : begin
                i2c_exec <= 1'b1;                //拉高触发信号
                bit_ctrl <= 1'b1;                //地址位选择信号   1: 16位
                i2c_rh_wl <= 1'b0;               //写操作
                i2c_addr <= 16'h0555;            //写地址
                i2c_data_w <= 8'hAA;             //写数据
                flow_cnt <= flow_cnt + 1'b1;
            end
            'd2 : begin 
                i2c_exec <= 1'b0;
                flow_cnt <= flow_cnt + 1'b1;
            end    
            'd3 : begin
                if(i2c_done)
                    flow_cnt <= flow_cnt + 1'b1;
            end
            'd4 : begin
                delay_cnt <= delay_cnt + 1'b1;
                if(delay_cnt == IIC_WR_CYCYLE - 1'b1)
                    flow_cnt <= flow_cnt + 1'b1;
            end
            'd5 : begin
                    i2c_exec <= 1'b1;
                    bit_ctrl <= 1'b1;                   
                    i2c_rh_wl <= 1'b1;           //读操作     
                    i2c_addr <= 16'h0555;
                    i2c_data_w <= 8'hAA;        
                    flow_cnt <= flow_cnt + 1'b1;                    
            end
            'd6 : begin 
                i2c_exec <= 1'b0;
                flow_cnt <= flow_cnt + 1'b1;
            end 
            'd7 : begin
                if(i2c_done)
                    flow_cnt <= flow_cnt + 1'b1;
            end
            default:;
        endcase    
    end
end

pullup(sda);

//例化led模块
i2c_dri #(
    .SLAVE_ADDR  (SLAVE_ADDR),  //EEPROM从机地址
    .CLK_FREQ    (CLK_FREQ  ),  //模块输入的时钟频率
    .I2C_FREQ    (I2C_FREQ  )   //IIC_SCL的时钟频率
) u_i2c_dri(
    .clk          (sys_clk),
    .rst_n        (sys_rst_n), 

    .i2c_exec     (i2c_exec  ), 
    .bit_ctrl     (bit_ctrl  ), 
    .i2c_rh_wl    (i2c_rh_wl ), 
    .i2c_addr     (i2c_addr  ), 
    .i2c_data_w   (i2c_data_w), 
    .i2c_data_r   (i2c_data_r), 
    .i2c_done     (i2c_done  ), 
    .i2c_ack      (i2c_ack   ), 
    .scl          (scl       ), 
    .sda          (sda       ),
    .dri_clk      (dri_clk   )
);

EEPROM_AT24C64 u_EEPROM_AT24C64(
    .scl         (scl),
    .sda         (sda)
    );

endmodule

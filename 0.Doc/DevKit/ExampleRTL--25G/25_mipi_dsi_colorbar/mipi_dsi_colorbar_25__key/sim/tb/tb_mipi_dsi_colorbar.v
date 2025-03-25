`timescale  1ns/1ns   // 定义仿真时间单位1ns和仿真时间精度为1ns

module  tb_mipi_dsi_colorbar();            

//输入
reg  sys_clk;                      // 时钟信号
reg  sys_rst_n;                    // 复位信号


//*****************************************************
//**                    main code
//*****************************************************

//给输入信号初始值
initial begin
    sys_clk            = 1'b0;
    sys_rst_n          = 1'b0;     // 复位
    #20  sys_rst_n  = 1'b1;     // 在第21ns的时候复位信号信号拉高
end

//50Mhz的时钟，周期则为1/50Mhz=20ns,所以每10ns，电平取反一次
always #10 sys_clk = ~sys_clk;

reg  grs_n;
    GTP_GRS GRS_INST(
    .GRS_N (grs_n)
    );
    
    initial begin
        grs_n = 1'b0;
        #5000 grs_n = 1'b1;
    end

//例化模块
mipi_dsi_colorbar  u_mipi_dsi_colorbar(
    .sys_clk            (sys_clk  ),
    .sys_rst_n          (sys_rst_n),

    .mipi_dsi_rst_n     (),
    .mipi_dsi_bl        (),
    .mipi_dsi_data_p    (),
    .mipi_dsi_data_n    (),
    .mipi_dsi_clk_p     (),
    .mipi_dsi_clk_n     ()
);

endmodule

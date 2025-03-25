`timescale 1ns/1ns

module tb_hdmi_colorbar_top();

reg        sys_clk		;
reg        sys_rst_n	;
    
wire       tmds_clk_p	;    //  TMDS 时钟通道
wire       tmds_clk_n	;
wire [2:0] tmds_data_p	;    // TMDS 数据通道
wire [2:0] tmds_data_n  ;

//GTP_GRS I_GTP_GRS(
GTP_GRS GRS_INST(
    .GRS_N (1'b1)
);

initial begin
	sys_clk = 1'b1;
	sys_rst_n <= 1'b0;
	#201
	sys_rst_n <= 1'b1;
end

always #10 sys_clk <= ~sys_clk;

hdmi_colorbar_top	hdmi_colorbar_top_inst(
    .sys_clk		(sys_clk	),
    .sys_rst_n		(sys_rst_n	),

    .tmds_clk_p		(tmds_clk_p	),    // TMDS 时钟通道
    .tmds_clk_n		(tmds_clk_n	),
    .tmds_data_p	(tmds_data_p),   // TMDS 数据通道
    .tmds_data_n    (tmds_data_n)
);

endmodule

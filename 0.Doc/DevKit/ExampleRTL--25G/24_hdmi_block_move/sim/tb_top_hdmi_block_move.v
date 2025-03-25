`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/09 16:00:39
// Design Name: 
// Module Name: tb_top_hdmi_block_move
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_top_hdmi_block_move();

reg          sys_clk	;
reg          sys_rst_n	;
						
wire         tmds_clk_n	;
wire         tmds_clk_p	;
wire  [2:0]  tmds_data_n;
wire  [2:0]  tmds_data_p;

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

defparam top_hdmi_block_move_inst.u_video_display.DIV_CNT = 75;

top_hdmi_block_move top_hdmi_block_move_inst(
    .sys_clk	(sys_clk	),
	.sys_rst_n	(sys_rst_n	),

    .tmds_clk_n	(tmds_clk_n	),
    .tmds_clk_p	(tmds_clk_p	),
    .tmds_data_n(tmds_data_n),
    .tmds_data_p(tmds_data_p)
);

endmodule

#Generated by Fabric Compiler ( version 2021.4-SP1.2 <build 96435> ) at Sat Sep  9 16:39:15 2023

add_design "C:/Users/ALIENTEK/Desktop/licheng/Test/Ziguang/PGL25G/top_ddr3_rw/rtl/ddr_rw_top.v"
add_design "C:/Users/ALIENTEK/Desktop/licheng/Test/Ziguang/PGL25G/top_ddr3_rw/rtl/ddr_test.v"
add_design "C:/Users/ALIENTEK/Desktop/licheng/Test/Ziguang/PGL25G/top_ddr3_rw/rtl/led_disp.v"
add_design "C:/Users/ALIENTEK/Desktop/licheng/Test/Ziguang/PGL25G/top_ddr3_rw/rtl/ddr3_ctrl_top/aq_axi_master.v"
add_design "C:/Users/ALIENTEK/Desktop/licheng/Test/Ziguang/PGL25G/top_ddr3_rw/rtl/ddr3_ctrl_top/ctrl_fifo.v"
add_design "C:/Users/ALIENTEK/Desktop/licheng/Test/Ziguang/PGL25G/top_ddr3_rw/rtl/ddr3_ctrl_top/ddr3_ctrl_top.v"
add_design "C:/Users/ALIENTEK/Desktop/licheng/Test/Ziguang/PGL25G/top_ddr3_rw/rtl/ddr3_ctrl_top/ddr3_rw_ctrl.v"
add_design C:/Users/ALIENTEK/Desktop/licheng/Test/Ziguang/PGL25G/top_ddr3_rw/prj/ipcore/wr_fifo/wr_fifo.idf
add_design C:/Users/ALIENTEK/Desktop/licheng/Test/Ziguang/PGL25G/top_ddr3_rw/prj/ipcore/rd_fifo/rd_fifo.idf
add_design C:/Users/ALIENTEK/Desktop/licheng/Test/Ziguang/PGL25G/top_ddr3_rw/prj/ipcore/ddr3_ip/ddr3_ip.idf
add_constraint "C:/Users/ALIENTEK/Desktop/licheng/Test/Ziguang/PGL25G/top_ddr3_rw/prj/source/ddr3_rw_pin.fdc"
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
synthesize -synplify_pro -selected_syn_tool_opt 1 -top_module ddr_rw_top
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr_rw_top
synthesize -ads -selected_syn_tool_opt 2 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr_rw_top
synthesize -ads -selected_syn_tool_opt 2 
synthesize -ads -selected_syn_tool_opt 2 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr_rw_top
synthesize -ads -selected_syn_tool_opt 2 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr_rw_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr_rw_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr_rw_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr_rw_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr_rw_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr_rw_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr_rw_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
report_timing 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr_rw_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr_rw_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr_rw_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr_rw_top
remove_design -force C:/Users/ALIENTEK/Desktop/licheng/Test/Ziguang/PGL25G/bank/top_ddr3_rw/prj/ipcore/ddr3_ip/ddr3_ip.idf
remove_design -force C:/Users/ALIENTEK/Desktop/licheng/Test/Ziguang/PGL25G/bank/top_ddr3_rw/prj/ipcore/wr_fifo/wr_fifo.idf
remove_design -force C:/Users/ALIENTEK/Desktop/licheng/Test/Ziguang/PGL25G/bank/top_ddr3_rw/prj/ipcore/rd_fifo/rd_fifo.idf
add_design C:/Users/ALIENTEK/Desktop/licheng/Test/Ziguang/PGL25G/bank/top_ddr3_rw/prj/ipcore/ddr3_ip/ddr3_ip.idf
add_design C:/Users/ALIENTEK/Desktop/licheng/Test/Ziguang/PGL25G/bank/top_ddr3_rw/prj/ipcore/wr_fifo/wr_fifo.idf
add_design C:/Users/ALIENTEK/Desktop/licheng/Test/Ziguang/PGL25G/bank/top_ddr3_rw/prj/ipcore/rd_fifo/rd_fifo.idf
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr_rw_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr_rw_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
add_design "C:/Users/ALIENTEK/Desktop/licheng/Test/Ziguang/PGL25G/bank/top_ddr3_rw/rtl/ddr3_rw_top.v"
remove_design -verilog "C:/Users/ALIENTEK/Desktop/licheng/Test/Ziguang/PGL25G/bank/top_ddr3_rw/rtl/ddr_rw_top.v"
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr3_rw_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr3_rw_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr3_rw_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr3_rw_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr3_rw_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr3_rw_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr3_rw_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module ddr3_rw_top
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 

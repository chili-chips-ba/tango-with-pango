#Generated by Fabric Compiler ( version 2022.2-SP4.2 <build 132111> ) at Sun Oct  8 17:54:11 2023

add_design "D:/Desktop/50G/12_top_key_beep/rtl/top_key_beep.v"
add_design "D:/Desktop/50G/12_top_key_beep/rtl/key_debounce.v"
add_design "D:/Desktop/50G/12_top_key_beep/rtl/key_beep.v"
set_arch -family Logos -device PGL50G -speedgrade -6 -package MBG324
compile -top_module top_key_beep
add_constraint "D:/Desktop/50G/12_top_key_beep/prj/top_key_beep.fdc"
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module top_key_beep
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 

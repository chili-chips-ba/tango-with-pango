#Generated by Fabric Compiler ( version 2022.2-SP4.2 <build 132111> ) at Mon Oct  9 14:42:26 2023

add_design "D:/Desktop/50G/13_touch_led/rtl/touch_led.v"
set_arch -family Logos -device PGL50G -speedgrade -6 -package MBG324
compile -top_module touch_led
add_constraint "D:/Desktop/50G/13_touch_led/prj/touch_led.fdc"
synthesize -ads -selected_syn_tool_opt 2 
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL50G -speedgrade -6 -package MBG324
compile -top_module touch_led
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 
set_arch -family Logos -device PGL25G -speedgrade -6 -package MBG324
compile -top_module touch_led
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream 

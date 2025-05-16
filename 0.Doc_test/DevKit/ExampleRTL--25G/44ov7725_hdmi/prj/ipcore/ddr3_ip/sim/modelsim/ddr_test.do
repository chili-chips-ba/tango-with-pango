onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ddr_test_top_tb/u_ddr3_rw_top/u_ddr_test/clk_50m
add wave -noupdate /ddr_test_top_tb/u_ddr3_rw_top/u_ddr_test/rst_n
add wave -noupdate /ddr_test_top_tb/u_ddr3_rw_top/u_ddr_test/wr_en
add wave -noupdate /ddr_test_top_tb/u_ddr3_rw_top/u_ddr_test/wr_data
add wave -noupdate /ddr_test_top_tb/u_ddr3_rw_top/u_ddr_test/rd_en
add wave -noupdate /ddr_test_top_tb/u_ddr3_rw_top/u_ddr_test/data_max
add wave -noupdate /ddr_test_top_tb/u_ddr3_rw_top/u_ddr_test/ddr3_init_done
add wave -noupdate /ddr_test_top_tb/u_ddr3_rw_top/u_ddr_test/error_flag
add wave -noupdate /ddr_test_top_tb/u_ddr3_rw_top/u_ddr_test/init_done_d0
add wave -noupdate /ddr_test_top_tb/u_ddr3_rw_top/u_ddr_test/init_done_d1
add wave -noupdate /ddr_test_top_tb/u_ddr3_rw_top/u_ddr_test/wr_cnt
add wave -noupdate /ddr_test_top_tb/u_ddr3_rw_top/u_ddr_test/rd_cnt
add wave -noupdate /ddr_test_top_tb/u_ddr3_rw_top/u_ddr_test/rd_valid
add wave -noupdate /ddr_test_top_tb/u_ddr3_rw_top/u_ddr_test/rd_data
add wave -noupdate /ddr_test_top_tb/u_ddr3_rw_top/u_ddr_test/rd_cnt_d0
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {547170200000 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ms
update
WaveRestoreZoom {0 fs} {946991718750 fs}

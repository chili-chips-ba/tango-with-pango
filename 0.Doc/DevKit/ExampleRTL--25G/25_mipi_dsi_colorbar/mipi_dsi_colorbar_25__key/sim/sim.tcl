vlib work
#vmap work
vlog -f file_list.f -l vlog.log
vsim -novopt -suppress 3486,3680,3781  -c tb_mipi_dsi_colorbar_touch -L work -l sim.log
#do wave.do
#run -all
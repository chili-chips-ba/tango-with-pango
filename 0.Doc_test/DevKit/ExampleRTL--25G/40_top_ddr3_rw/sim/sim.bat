
@echo  off

title sim.tcl is running.... 


cd ./../prj/ipcore/ddr3_ip/sim/modelsim

echo sim.tcl is running.... 

vsim -gui -do sim.tcl

del w*
del v*
del m*
del tr*
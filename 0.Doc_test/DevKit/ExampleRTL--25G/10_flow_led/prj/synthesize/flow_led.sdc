###==== BEGIN "create_clock"
create_clock -name {flow_led|sys_clk} [get_ports {sys_clk}] -period {20.000} -waveform {0 10}
###==== END "create_clock"

###==== BEGIN "create_generated_clock"
###==== END "create_generated_clock"

###==== BEGIN "set_clock_latency"
###==== END "set_clock_latency"

###==== BEGIN "set_clock_uncertainty"
###==== END "set_clock_uncertainty"

###==== BEGIN "set_clock_groups"
set_clock_groups -name Inferred_clock_group_0 -asynchronous -group [get_clocks {flow_led|sys_clk}]
###==== END "set_clock_groups"

###==== BEGIN "set_external_delay"
###==== END "set_external_delay"

###==== BEGIN "set_input_delay"
###==== END "set_input_delay"

###==== BEGIN "set_output_delay"
###==== END "set_output_delay"

###==== BEGIN "set_max_skew"
###==== END "set_max_skew"

###==== BEGIN "set_max_delay"
###==== END "set_max_delay"

###==== BEGIN "set_min_delay"
###==== END "set_min_delay"

###==== BEGIN "set_multicycle_path"
###==== END "set_multicycle_path"

###==== BEGIN "set_false_path"
###==== END "set_false_path"

###==== BEGIN "set_disable_timing"
###==== END "set_disable_timing"


# 
# Synthesis run script generated by Vivado
# 

debug::add_scope template.lib 1
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
set_msg_config -id {Synth 8-256} -limit 10000
set_msg_config -id {Synth 8-638} -limit 10000
create_project -in_memory -part xc7z020clg484-2

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir C:/Users/Joey/rf_project/rf_project.cache/wt [current_project]
set_property parent.project_path C:/Users/Joey/rf_project/rf_project.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
read_vhdl -library xil_defaultlib C:/Users/Joey/rf_project/rf_project.srcs/sources_1/new/simple_control.vhd
read_xdc C:/Users/Joey/rf_project/rf_project.srcs/constrs_1/new/pins.xdc
set_property used_in_implementation false [get_files C:/Users/Joey/rf_project/rf_project.srcs/constrs_1/new/pins.xdc]

synth_design -top simple_control -part xc7z020clg484-2
write_checkpoint -noxdef simple_control.dcp
catch { report_utilization -file simple_control_utilization_synth.rpt -pb simple_control_utilization_synth.pb }

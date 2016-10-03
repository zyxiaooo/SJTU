
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name ex9 -dir "C:/Documents and Settings/ex9/planAhead_run_1" -part xc3s100ecp132-5
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "ex4_t.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {ex9.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top ex4_t $srcset
add_files [list {ex4_t.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc3s100ecp132-5

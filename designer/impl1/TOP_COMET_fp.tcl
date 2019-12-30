new_project \
    -name {TOP_COMET} \
    -location {D:\0_all_libero_project\CERN_LHCb\COMET_TEST\designer\impl1\TOP_COMET_fp} \
    -mode {single}
set_programming_file -file {D:\0_all_libero_project\CERN_LHCb\COMET_TEST\designer\impl1\TOP_COMET.pdb}
set_programming_action -action {PROGRAM}
catch {run_selected_actions} return_val
save_project
close_project
if { $return_val != 0 } {
  exit 1 }

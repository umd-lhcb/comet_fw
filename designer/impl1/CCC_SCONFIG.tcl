# Created by Microsemi Libero Software 11.5.2.6
# Wed Oct 14 10:02:34 2015

# (OPEN DESIGN)

open_design "CCC_SCONFIG.adb"

# set default back-annotation base-name
set_defvar "BA_NAME" "CCC_SCONFIG_ba"
set_defvar "IDE_DESIGNERVIEW_NAME" {Impl1}
set_defvar "IDE_DESIGNERVIEW_COUNT" "1"
set_defvar "IDE_DESIGNERVIEW_REV0" {Impl1}
set_defvar "IDE_DESIGNERVIEW_REVNUM0" "1"
set_defvar "IDE_DESIGNERVIEW_ROOTDIR" {D:\0_all_libero_project\CERN_LHCb\COMET_TEST\designer}
set_defvar "IDE_DESIGNERVIEW_LASTREV" "1"

backannotate -format "SDF" -language "VHDL93" -netlist

save_design

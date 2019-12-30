# Created by Microsemi Libero Software 11.9.2.1
# Sun Dec 29 19:00:33 2019

# (OPEN DESIGN)

open_design "TOP_COMET.adb"

# set default back-annotation base-name
set_defvar "BA_NAME" "TOP_COMET_ba"
set_defvar "IDE_DESIGNERVIEW_NAME" {Impl1}
set_defvar "IDE_DESIGNERVIEW_COUNT" "1"
set_defvar "IDE_DESIGNERVIEW_REV0" {Impl1}
set_defvar "IDE_DESIGNERVIEW_REVNUM0" "1"
set_defvar "IDE_DESIGNERVIEW_ROOTDIR" {Z:\windows\comet_fw\designer}
set_defvar "IDE_DESIGNERVIEW_LASTREV" "1"


layout -timing_driven
report -type "status" {TOP_COMET_place_and_route_report.txt}
report -type "globalnet" {TOP_COMET_globalnet_report.txt}
report -type "globalusage" {TOP_COMET_globalusage_report.txt}
report -type "iobank" {TOP_COMET_iobank_report.txt}
report -type "pin" -listby "name" {TOP_COMET_report_pin_byname.txt}
report -type "pin" -listby "number" {TOP_COMET_report_pin_bynumber.txt}

save_design

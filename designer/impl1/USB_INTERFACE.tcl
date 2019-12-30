# Created by Microsemi Libero Software 11.5.2.6
# Tue Sep 08 17:16:55 2015

# (NEW DESIGN)

# create a new design
new_design -name "USB_INTERFACE" -family "ProASIC3E"

# set default back-annotation base-name
set_defvar "BA_NAME" "USB_INTERFACE_ba"
set_defvar "IDE_DESIGNERVIEW_NAME" {Impl1}
set_defvar "IDE_DESIGNERVIEW_COUNT" "1"
set_defvar "IDE_DESIGNERVIEW_REV0" {Impl1}
set_defvar "IDE_DESIGNERVIEW_REVNUM0" "1"
set_defvar "IDE_DESIGNERVIEW_ROOTDIR" {D:\0_all_libero_project\CERN_LHCb\COMET_TEST\designer}
set_defvar "IDE_DESIGNERVIEW_LASTREV" "1"

# set working directory
set_defvar "DESDIR" "D:/0_all_libero_project/CERN_LHCb/COMET_TEST/designer/impl1"

# set back-annotation output directory
set_defvar "BA_DIR" "D:/0_all_libero_project/CERN_LHCb/COMET_TEST/designer/impl1"

# enable the export back-annotation netlist
set_defvar "BA_NETLIST_ALSO" "1"

# set EDIF options
set_defvar "EDNINFLAVOR" "GENERIC"

# set HDL options
set_defvar "NETLIST_NAMING_STYLE" "VHDL93"

# setup status report options
set_defvar "EXPORT_STATUS_REPORT" "1"
set_defvar "EXPORT_STATUS_REPORT_FILENAME" "USB_INTERFACE.rpt"

# legacy audit-mode flags (left here for historical reasons)
set_defvar "AUDIT_NETLIST_FILE" "1"
set_defvar "AUDIT_DCF_FILE" "1"
set_defvar "AUDIT_PIN_FILE" "1"
set_defvar "AUDIT_ADL_FILE" "1"

# import of input files
import_source  \
-format "edif" -edif_flavor "GENERIC" -netlist_naming "VHDL" {../../synthesis/USB_INTERFACE.edn}

# export translation of original netlist
export -format "vhdl" {../../synthesis/USB_INTERFACE.vhd}

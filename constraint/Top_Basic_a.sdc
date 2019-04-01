################################################################################
#  SDC WRITER VERSION "3.1";
#  DESIGN "Top_Basic";
#  Timing constraints scenario: "Primary";
#  DATE "Wed Jul 08 13:53:29 2015";
#  VENDOR "Actel";
#  PROGRAM "Microsemi Libero Software Release v11.5 SP2";
#  VERSION "11.5.2.6"  Copyright (C) 1989-2015 Actel Corp. 
################################################################################


set sdc_version 11.7


########  Clock Constraints  ######## ==>  type port (p: or get_ports), inst (i: or get_cells), pin (t: or get_pins), or net (n: or get_nets )


## THIS SYNTAX WORKS WITH SYNPLIFY, BUT NOT DESIGNER:

 create_clock -name {CLK_40M_GL} -period 25.000 { n:CLK_40M_GL }
 create_clock -name {CCC_160M_FXD} -period 6.250  { n:CCC_160M_FXD }
 create_clock -name {CLK60MHZ} -period 16.665  { n:CLK60MHZ }

 create_clock -name {CCC_160M_ADJ} -period 6.250  { n:U13C_MASTER_DES.CCC_160M_ADJ }
 create_clock -name {CCC_160M_ADJ_ALIAS} -period 6.250  {  n:U_MASTER_DES.CCC_160M_ADJ }

 create_clock -name {Y_INFERRED} -period 5.000  { n:U0_200M_BUF.Y }


 
 set_clock_groups -asynchronous -group {CLK60MHZ}
 
 

########  Generated Clock Constraints  ########



########  Clock Source Latency Constraints #########



########  Input Delay Constraints  ########



########  Output Delay Constraints  ########



########   Delay Constraints  ########



########   Delay Constraints  ########



########   Multicycle Constraints  ########



########   False Path Constraints  ########


########   Output load Constraints  ########



########  Disable Timing Constraints #########



########  Clock Uncertainty Constraints #########
################################################################################
#  SDC WRITER VERSION "3.1";
#  DESIGN "Top_Basic";
#  Timing constraints scenario: "Primary";
#  DATE "Wed Jul 08 13:53:29 2015";
#  VENDOR "Actel";
#  PROGRAM "Microsemi Libero Software Release v11.5 SP2";
#  VERSION "11.5.2.6"  Copyright (C) 1989-2015 Actel Corp. 
################################################################################


set sdc_version 1.7


########  Clock Constraints  ######## ==>  type port (p: or get_ports), inst (i: or get_cells), pin (t: or get_pins), or net (n: or get_nets )


## THIS SYNTAX WORKS WITH SYNPLIFY, BUT NOT DESIGNER:

## create_clock  -name { CLK_PH1_160MHZ } -period 6.250   { n:P_CLK_PH1_160MHZ }
## create_clock  -name { CLK40M_GEN_PH_A } -period 25.000  { n:U13C_MASTER_DES.U13C_MASTER_DESER.U_CLK_BNDRY_CROSS.CLK40M_GEN_PH_A }
## create_clock  -name { CLK40M_GEN_PH_B } -period 25.000  { n:U13C_MASTER_DES.U13C_MASTER_DESER.U_CLK_BNDRY_CROSS.CLK40M_GEN_PH_B }
## create_clock  -name { CLK40M_GEN_PH_C } -period 25.000  { n:U13C_MASTER_DES.U13C_MASTER_DESER.U_CLK_BNDRY_CROSS.CLK40M_GEN_PH_C }
## create_clock  -name { CLK40M_GEN_PH_D } -period 25.000  { n:U13C_MASTER_DES.U13C_MASTER_DESER.U_CLK_BNDRY_CROSS.CLK40M_GEN_PH_D }
## set_clock_groups -asynchronous -group {CLK_PH1_160MHZ CLK40M_GEN_GLB CLK40M_GEN_PH_A CLK40M_GEN_PH_B CLK40M_GEN_PH_C CLK40M_GEN_PH_D}


 create_clock -name {CLK_40M_GL} -period 25.000 { n:U_MAINCLKGEN.GLA }
 create_clock -name {CLK60MHZ} -period 16.667 { n:U_MAINCLKGEN.GLB }
 create_clock -name {CCC_160M_ADJ} -period 6.250 { n:U13C_MASTER_DES.U13B_CCC.GLA }
 create_clock -name {CCC_160M_FXD} -period 6.250 { n:U13C_MASTER_DES.U13B_CCC.GLB }
 create_clock -name {RAW_200MHZ} -period 5.000 { n:U0_200M_BUF.Y }

 #create_clock  -name { CLK40M_GEN_GLB } -period 25.000   { n:U_MAINCLKGEN.GLB }
#
 #create_clock  -name { CCC_160M_ADJ } -period 6.250   { n:P_CCC_160M_ADJ }
 #create_clock  -name { CCC_160M_adj_i } -period 6.250  { n:U13C_MASTER_DES.U13B_CCC.GLA }
 #create_clock  -name { CCC_40M_adj_i } -period 25.000  { n:U13C_MASTER_DES.U13B_CCC.GLB }
#
 #create_clock  -name { clk60MHZ } -period 16.393  { n:CLK60MHZ }
 set_clock_groups -asynchronous -group {CLK60MHZ}
 
 

########  Generated Clock Constraints  ########



########  Clock Source Latency Constraints #########



########  Input Delay Constraints  ########



########  Output Delay Constraints  ########



########   Delay Constraints  ########



########   Delay Constraints  ########



########   Multicycle Constraints  ########



########   False Path Constraints  ########   t:U100_BYTE_PATT.BYTE_OUT[0]


########   Output load Constraints  ########



########  Disable Timing Constraints #########



########  Clock Uncertainty Constraints #########
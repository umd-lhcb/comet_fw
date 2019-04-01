################################################################################
#  SDC WRITER VERSION "3.1";
#  DESIGN "TOP_COMET";
#  Timing constraints scenario: "Primary";
#  DATE "Fri Nov 13 15:05:04 2015";
#  VENDOR "Actel";
#  PROGRAM "Microsemi Libero Software Release v11.5 SP2";
#  VERSION "11.5.2.6"  Copyright (C) 1989-2015 Actel Corp. 
################################################################################


set sdc_version 1.7


########  Clock Constraints  ########

create_clock  -name { U0C_50M_CLKGEN/SCFG_CLK_I:Q } -period 20.000 -waveform { 0.000 10.000  }  { U0C_50M_CLKGEN/SCFG_CLK_I:Q  } 

create_clock  -name { U13B_CCC/Core:GLA } -period 6.250 -waveform { 0.000 3.125  }  { U13B_CCC/Core:GLA  } 

create_clock  -name { U13B_CCC/Core:GLB } -period 25.000 -waveform { 0.000 12.500  }  { U13B_CCC/Core:GLB  } 

create_clock  -name { U3_MAINCLKGEN/Core:GLA } -period 6.250 -waveform { 0.000 3.125  }  { U3_MAINCLKGEN/Core:GLA  } 

create_clock  -name { U3_MAINCLKGEN/Core:GLB } -period 25.000 -waveform { 0.000 12.500  }  { U3_MAINCLKGEN/Core:GLB  } 

create_clock  -name { U3_MAINCLKGEN/Core:GLC } -period 16.667 -waveform { 0.000 8.333  }  { U3_MAINCLKGEN/Core:GLC  } 

create_clock  -name { USBCLK60MHZ } -period 16.667 -waveform { 0.000 8.333  }  { USBCLK60MHZ  } 



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




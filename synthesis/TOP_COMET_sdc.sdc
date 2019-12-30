# Top Level Design Parameters

# Clocks

create_clock -name {CLK_40M_GL} -period 25.000000 -waveform {0.000000 12.500000} U_MAINCLKGEN/Core:GLA
create_clock -name {CCC_160M_FXD} -period 6.250000 -waveform {0.000000 3.125000} U_MAINCLKGEN/Core:GLB
create_clock -name {CLK60MHZ} -period 16.665000 -waveform {0.000000 8.332500} U_MAINCLKGEN/Core:GLC
create_clock -name {CCC_160M_ADJ_ALIAS} -period 6.250000 -waveform {0.000000 3.125000} U_MASTER_DES/U13B_CCC/Core:GLA
create_clock -name {Y_INFERRED} -period 5.000000 -waveform {0.000000 2.500000}  {U0_200M_BUF/\INBUF_LVDS[0]\:Y}

# False Paths Between Clocks


# False Path Constraints


# Maximum Delay Constraints


# Multicycle Constraints


# Virtual Clocks
# Output Load Constraints
# Driving Cell Constraints
# Wire Loads
# set_wire_load_mode top

# Other Constraints

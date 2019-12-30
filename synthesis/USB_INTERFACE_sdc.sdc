# Top Level Design Parameters

# Clocks

create_clock -name {CLK40M_GEN_RAM} -period 25.000000 -waveform {0.000000 12.500000} CLK_40MHZ_GEN
create_clock -name {clk60MHZ} -period 16.393000 -waveform {0.000000 8.196500} CLK60MHZ_keep:Y

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

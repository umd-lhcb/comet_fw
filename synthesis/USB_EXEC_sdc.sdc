# Top Level Design Parameters

# Clocks

create_clock -name {USB_EXEC|CLK60MHZ} -period 10.000000 -waveform {0.000000 5.000000} CLK60MHZ
create_clock -name {USB_EXEC|CLK_40MHZ_GEN} -period 10.000000 -waveform {0.000000 5.000000} CLK_40MHZ_GEN

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

# Clock input 80 MHz
set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 12.5 [get_ports clk]

# Reset (Center button = BTNC)
set_property PACKAGE_PIN N17 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

# Digit output (4 bits)
set_property PACKAGE_PIN N14 [get_ports {digit[0]}]
set_property PACKAGE_PIN R18 [get_ports {digit[1]}]
set_property PACKAGE_PIN V17 [get_ports {digit[2]}]
set_property PACKAGE_PIN U17 [get_ports {digit[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {digit[*]}]

# 7-segment display segments (CA to CG)
set_property PACKAGE_PIN T10 [get_ports {segment[0]}] 
set_property PACKAGE_PIN R10 [get_ports {segment[1]}]  
set_property PACKAGE_PIN K16 [get_ports {segment[2]}] 
set_property PACKAGE_PIN K13 [get_ports {segment[3]}]  
set_property PACKAGE_PIN P15 [get_ports {segment[4]}]
set_property PACKAGE_PIN T11 [get_ports {segment[5]}] 
set_property PACKAGE_PIN L18 [get_ports {segment[6]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {segment[*]}]

# Done signal to LED
set_property PACKAGE_PIN K15 [get_ports done]
set_property IOSTANDARD LVCMOS33 [get_ports done]

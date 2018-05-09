# Clock signal                                                                      
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [ get_ports clk ]       
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [ get_ports clk ];
                                                                                    
#VGA Connector                                                                      
set_property -dict { PACKAGE_PIN G19   IOSTANDARD LVCMOS33 } [ get_ports vga_r[0] ];
set_property -dict { PACKAGE_PIN H19   IOSTANDARD LVCMOS33 } [ get_ports vga_r[1] ];
set_property -dict { PACKAGE_PIN J19   IOSTANDARD LVCMOS33 } [ get_ports vga_r[2] ];
set_property -dict { PACKAGE_PIN N19   IOSTANDARD LVCMOS33 } [ get_ports vga_r[3] ];
set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS33 } [ get_ports vga_b[0] ];
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [ get_ports vga_b[1] ];
set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [ get_ports vga_b[2] ];
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [ get_ports vga_b[3] ];
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [ get_ports vga_g[0] ];
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [ get_ports vga_g[1] ];
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [ get_ports vga_g[2] ];
set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [ get_ports vga_g[3] ];
set_property -dict { PACKAGE_PIN P19   IOSTANDARD LVCMOS33 } [ get_ports vga_hs   ];
set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [ get_ports vga_vs   ];
                                                                                    
## LEDs                                                                              
#set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [ get_ports led[0]  ]; 
#set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [ get_ports led[1]  ]; 
#set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [ get_ports led[2]  ]; 
#set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 } [ get_ports led[3]  ]; 
#set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [ get_ports led[4]  ]; 
#set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [ get_ports led[5]  ]; 
#set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [ get_ports led[6]  ]; 
#set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [ get_ports led[7]  ]; 
#set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [ get_ports led[8]  ]; 
#set_property -dict { PACKAGE_PIN V3    IOSTANDARD LVCMOS33 } [ get_ports led[9]  ]; 
#set_property -dict { PACKAGE_PIN W3    IOSTANDARD LVCMOS33 } [ get_ports led[10] ]; 
#set_property -dict { PACKAGE_PIN U3    IOSTANDARD LVCMOS33 } [ get_ports led[11] ]; 
#set_property -dict { PACKAGE_PIN P3    IOSTANDARD LVCMOS33 } [ get_ports led[12] ]; 
#set_property -dict { PACKAGE_PIN N3    IOSTANDARD LVCMOS33 } [ get_ports led[13] ]; 
#set_property -dict { PACKAGE_PIN P1    IOSTANDARD LVCMOS33 } [ get_ports led[14] ]; 
#set_property -dict { PACKAGE_PIN L1    IOSTANDARD LVCMOS33 } [ get_ports led[15] ]; 
                                                                                    
## USB-RS232 Interface                                                                
set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [ get_ports rx       ];
set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [ get_ports tx       ];
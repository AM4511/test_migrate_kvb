# LaunchPnPGen.tcl
# 4/27/2016
# Ken Paist
# 
# This QuartusII Tcl script launches the Wish Tcl script which generates
# the PnP ROM memory image file. It uses the Wish Tcl environment with the
# tDOM package since we haven't found a way to install a DOM parcer package
# into the QuartusII Tcl script processor.
# 
# ----------------------------------------------------------------------------

#get_global_assignment -name SOPCINFO_INPUT_FILE
exec {C:\Tcl\bin\wish} PnP_ROM_Compiler.tcl q_sys.sopcinfo


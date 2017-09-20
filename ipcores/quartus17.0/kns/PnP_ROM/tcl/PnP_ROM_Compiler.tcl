# Avalon_PnP_ROM_Compiler.tcl
#
# 08/14/2015    Ryan Ellis                  Initial.
# 04/22/2016    Ken Paist                   Code clean-up.
# 08/16/2017    Alain Marchand (Matrox)     Fixed for Quartus.
# 09/20/2017    David Rauth                 Added gitCommit and buildId.
# 
# Used to generate the PnP ROM image after a .sopcinfo file is output from
# Qsys. Uses the tDOM parser package to read the XML file into memory. 
# The tDOM parser converts the XML file into a "DOM tree" with each line of 
# the file being a "DOM node" of the tree. For the most part, this script uses
# XPaths to navigate through the tree, extracting information into an 
# intermediate data structure called "sopc", made up of nested dictionaries. 
# Finally, the data is written to a ROM image.
# 
# ----------------------------------------------------------------------------
set myself [info script]
puts "Running ${myself}"

# Define required package
package require tdom


# VersionMatch
#     Finds the version number of the file to be parsed, then compares it to 
#     the version number provided in the code below. Returns boolean values 
#     based on whether these version numbers match. 
# Arguments: 
#     matchThis       A version number specified in the code below, before the
#                     VersionMatch call.
# Return Values: 
#     0       The file version number matches the desired version. 
#     1       The file version number does not match the desired version. 
# An example line from the file containing the version number: 
#     <!-- Format version 14.0 200 (Future versions may contain additional ...
# An example matchThis argument: 
#     14.0 200
proc VersionMatch {matchThis} {
    global logFile inputString
    puts $logFile {VersionMatch}
    puts $logFile "\tScript Version: \"$matchThis\""
    
    # Find Format Version
    set doc [dom parse $inputString]
    set root [$doc documentElement]
    set node [$root firstChild]
    set versionComment [$node data]
    puts $logFile "\tFile Version: \"$versionComment\""
    if {[string match *$matchThis* $versionComment]} {
        puts $logFile "\tMatch"
        return 0
    } else {
        puts $logFile "\tNo match"
        return 1
    }
}

# ExtractDeviceIdentification
#     Creates a node in the "sopc" dict structure for device identification, 
#     if the information exists.  
# Arguments: 
#     pnpModuleNode       The DOM node of a module which has the name: 
#                         "PnP_ROM". This node is searched for parameters 
#                         named: "dev_name", "part_num", and "gw_ver". If any 
#                         of these parameters exist within the module, their 
#                         values are added to the "sopc" dictionary structure.
proc ExtractDeviceIdentification {pnpModuleNode} {
    global logFile doc sopc offset firstInModule

    puts $logFile {ExtractDeviceIdentification}
    puts $logFile "\t[$pnpModuleNode selectNodes {@name}]"
    puts $logFile "\t$pnpModuleNode"
    
    # Get Parameters Named: "dev_name", "part_num", or "gw_ver"
    set devNameNode [$pnpModuleNode selectNodes {parameter[@name="dev_name"]}]
    set devName [$devNameNode selectNodes value]
    set devName [$devName asText]
    puts $logFile "\t\tdevname:    $devName"
    set partNumNode [$pnpModuleNode selectNodes {parameter[@name="part_num"]}]
    set partNum [$partNumNode selectNodes value]
    set partNum [$partNum asText]
    puts $logFile "\t\tpartNum:    $partNum"
    set gwVerNode [$pnpModuleNode selectNodes {parameter[@name="gw_ver"]}]
    set gwVer [$gwVerNode selectNodes value]
    set gwVer [$gwVer asText]
    puts $logFile "\t\tgwVer:      $gwVer"
    set gitCommitNode [$pnpModuleNode selectNodes {parameter[@name="git_commit"]}]
    set gitCommit [$gitCommitNode selectNodes value]
    set gitCommit [$gitCommit asText]
    set gitCommitHex [format %x $gitCommit]
    puts $logFile "\t\tgitCommit:  0x$gitCommitHex"
    set buildIdNode [$pnpModuleNode selectNodes {parameter[@name="build_id"]}]
    set buildId [$buildIdNode selectNodes value]
    set buildId [$buildId asText]
    puts $logFile "\t\tbuildId:    $buildId"
    set devNameOffset 12
    set partNumOffset [expr $devNameOffset + [string length $devName] + 1]
#    puts $logFile "\tParameter List: $parameterList"
    # Nest structure offset (word aligned)
    set offset [expr ($partNumOffset + [string length $partNum] + 1)]
    set offset [expr ((($offset + 3) / 4) * 4)]
    #
    dict set sopc "deviceIDCap" \
             [dict create startOffset   0 \
			  devNameOffset $devNameOffset \
			  partNumOffset $partNumOffset \
	                  devName       $devName \
                          partNum       $partNum \
                          gwVer         $gwVer \
                          gitCommit     $gitCommit\
                          buildId       $buildId]
    puts $logFile ">> sopc: \"$sopc\""
}

# ExtractAvalonMaster_IntReceiver
#     Called for any module. If any masters with memoryBlocks or
#     any interrupt receivers with interrupts exist within the given module,
#     adds an IP Identification Capability entry to "sopc". Adds all 
#     proper master and slave information, if any, then adds all proper 
#     interrupt receiver and sender information, if any.
# Arguments: 
#     anyModuleNode    The DOM node of all modules. 
proc ExtractAvalonMaster_IntReceiver {anyModuleNode} {
    global logFile doc firstInModule AAMMSI_times_called AAISI_times_called
    puts $logFile "ExtractAvalonMaster_IntReceiver"
    puts $logFile "\t[$anyModuleNode selectNodes {@name}]"
    puts $logFile "\t$anyModuleNode"
    
    # Create List of Interfaces with kind: "avalon_master"
    set interfaceMasterList [$anyModuleNode selectNodes \
                             {interface[@kind="avalon_master"]}]
    puts $logFile "\tInterface Master List:"
    # Handle List of Interfaces
    foreach interface $interfaceMasterList {
        puts $logFile "\t\t$interface is type avalon_master"
        # Create List of memoryBlocks
        set memoryBlockList [$interface selectNodes {memoryBlock}]
        puts $logFile "\t\tMemory Block List:"
        # Handle List of memoryBlocks
        foreach memoryBlock $memoryBlockList {
            puts $logFile "\t\t\t$memoryBlock"
            if {$memoryBlock == [lindex $memoryBlockList 0]} {
                if {$firstInModule} {
                    # Add IP Identification Capability
                    AddIPIdentificationCapability $anyModuleNode
                }
                set firstInModule 0
                # Add Avalon-MM Master Interface
                AddAvalonMMMasterInterface $interface
            }
            # Add Avalon-MM Slave Interface
            AddAvalonMMSlaveInterface $memoryBlock
        }
        set AAMMSI_times_called 0; # setup for next memory block (slave)
    }
  
    # Create List of Interfaces with kind: "interrupt_receiver"
    set interfaceInterruptReceiverList [$anyModuleNode selectNodes \
                                      {interface[@kind="interrupt_receiver"]}]
    puts $logFile "\tInterface Interrupt List:"
    foreach interfaceInterruptReceiver $interfaceInterruptReceiverList {
        puts $logFile "\t\t$interfaceInterruptReceiver"
    }
    
    # Handle List of Interfaces
    foreach interface $interfaceInterruptReceiverList {
        # Create List of interrupts
        set interruptList [$interface selectNodes {interrupt}]
        puts $logFile "\t\tInterrupt List:"
        foreach interrupt $interruptList {
            puts $logFile "\t\t\t$interrupt"
        }
        
        # Handle List of interrupts
        foreach interrupt $interruptList {
            if {$interrupt == [lindex $interruptList 0]} {
                if {$firstInModule} {
                    # Add IP Identification Capability
                    AddIPIdentificationCapability $anyModuleNode
                }
                set firstInModule 0
                # Add Avalon Interrupt Receiver Interface
                AddAvalonInterruptReceiverInterface $interface
            }
            # Add Avalon Interrupt Sender Interface
            AddAvalonInterruptSenderInterface $interrupt
        }
        set AAISI_times_called 0
    }
}

# AddIPIdentificationCapability
#     Called once per module, when the module includes master/slave or 
#     interrupt receiver/sender information. Adds the necessary capability
#     information to "sopc". 
# Arguments: 
#     moduleNode      A module DOM node. 
proc AddIPIdentificationCapability {moduleNode} {
    global logFile sopc offset AIPIC_times_called
    
    # Update last K&S capability offset
    if {$AIPIC_times_called != 0} {
	dict append sopc "avalonIPCap$AIPIC_times_called" \
	    " nextKnsCapOff " $offset
	puts $logFile "\tavalonIPCap nextKnsCapOff: $offset"
    } else {
	dict append sopc "deviceIDCap" " nextKnsCapOff " $offset
	puts $logFile "\tdeviceIDCap nextKnsCapOff: $offset"
    }
    incr AIPIC_times_called; # this capability number
    # Adds kind, module, version, and interface list offset to Dictionary
    set startOffset $offset
    set kind [$moduleNode selectNodes @kind]
    set kind [string range $kind 6 end-1]
    set name [$moduleNode selectNodes @name]
    set name [string range $name 6 end-1]
    set ver [$moduleNode selectNodes @version]
    set ver [string range $ver 9 end-1]
    set kindStrOffset [expr ($offset + 12)]
    set nameStrOffset [expr ($kindStrOffset + [string length $kind] + 1)]
    set verStrOffset  [expr ($nameStrOffset + [string length $name] + 1)]
    # offset for next structure (word aligned)
    set offset [expr ($verStrOffset + [string length $ver] + 1)]
    set offset [expr ((($offset + 3) / 4) * 4)]
    set ifListOffset $offset
    # Set up the values for the IP Capability structure
    dict set sopc \
             "avalonIPCap$AIPIC_times_called" \
             [dict create startOffset   $startOffset \
			  kindStrOffset $kindStrOffset \
			  nameStrOffset $nameStrOffset \
			  verStrOffset  $verStrOffset \
			  ifListOffset  $ifListOffset \
			  modKind       $kind \
                          modName       $name \
                          modVer        $ver]
    #
    puts -nonewline $logFile "\t\t\t\t" 
    puts $logFile {AddIPIdentificationCapability}
    puts $logFile "\t\t\t\t\t$moduleNode"
    puts $logFile ">> sopc: \"$sopc\""
}

# AddAvalonMMMasterInterface
#     Called for each master interface with memoryBlocks in a module. Adds the
#     master information to "sopc". 
# Arguments: 
#     interface       A master interface DOM node. 
proc AddAvalonMMMasterInterface {interface} {
    global logFile sopc offset master_intRcvrOff
    global AAMMMI_times_called AIPIC_times_called AAIRI_times_called

    # Update last Memory Mapped Master Interface offset
    set miIndex [expr ($AAMMMI_times_called + $AAIRI_times_called)]
    if {$miIndex != 0} {
#	set sopc1 "[string range $sopc 0 end-2]"
#	set sopc2 "[string range $sopc end-1 end]"
	set sopc "[string range $sopc 0 end-2] nextIfOffset $offset\
		  [string range $sopc end-1 end]"
    }
    incr AAMMMI_times_called; # this master number
    # Add Master Name to Dictionary
    set startOffset $offset
    set name [$interface selectNodes @name]
    set name [string range $name 6 end-1]
    set nameStrOffset [expr ($offset + 8)]
    # offset for next structure
    set offset [expr ($nameStrOffset + [string length $name] + 1)]
    set offset [expr ((($offset + 3) / 4) * 4)]
    set slIfListOffset $offset
    #
    set miIndex [expr ($AAMMMI_times_called + $AAIRI_times_called)]
    dict set sopc \
             "avalonIPCap$AIPIC_times_called" \
             "avalonMasterIntf$miIndex" \
             [dict create startOffset    $startOffset \
			  nameStrOffset  $nameStrOffset \
			  slIfListOffset $slIfListOffset \
	                  masterName     $name]
    #
    puts -nonewline $logFile "\t\t\t\t" 
    puts $logFile {AddAvalonMMMasterInterface}
    puts $logFile "\t\t\t\t\t$interface"
    puts $logFile ">> sopc: \"$sopc\""
}

# AddAvalonMMSlaveInterface
#     Called when a master is found with slave information. Adds the necessary
#     slave information to "sopc". 
# Arguments: 
#     memoryBlock     A memoryBlock DOM node. 
proc AddAvalonMMSlaveInterface {memoryBlock} {
    global logFile sopc offset slave_intSndrOff
    global AAMMSI_times_called AAISI_times_called
    global AAMMMI_times_called AIPIC_times_called

    # Update last Memory Mapped Slave Interface offset
    set siIndex [expr ($AAMMSI_times_called + $AAISI_times_called)]
    if {$siIndex != 0} {
	set sopc "[string range $sopc 0 end-3] nextIfOffset $offset\
		  [string range $sopc end-2 end]"
    }
    incr AAMMSI_times_called; # this slave number
    # Adds slaveName, moduleName, baseAddress, and span to Dictionary
    set startOffset $offset
    set sNameNode [$memoryBlock selectNodes slaveName]
    set sName [$sNameNode asText]
    set slaveNameOffset [expr ($offset + 24)]
    set mNameNode [$memoryBlock selectNodes moduleName]
    set mName [$mNameNode asText]
    set moduleNameOffset [expr ($slaveNameOffset + [string length $sName] + 1)]
    set bAddressNode [$memoryBlock selectNodes baseAddress]
    set bAddress [$bAddressNode asText]
    set spnNode [$memoryBlock selectNodes span]
    set spn [$spnNode asText]
    # offset for next structure
    set offset [expr ($moduleNameOffset + [string length $mName] + 1)]
    set offset [expr ((($offset + 3) / 4) * 4)]; # word align
    #
    dict set sopc \
             "avalonIPCap$AIPIC_times_called" \
             "avalonMasterIntf$AAMMMI_times_called" \
             "avalonSlaveIntf$AAMMSI_times_called" \
             [dict create startOffset      $startOffset \
			  slaveNameOffset  $slaveNameOffset \
			  moduleNameOffset $moduleNameOffset \
                          baseAddress      $bAddress \
                          span             $spn \
			  slaveName        $sName \
                          moduleName       $mName]
    set siIndex [expr ($AAMMSI_times_called + $AAISI_times_called)]
    #
    puts -nonewline $logFile "\t\t\t\t" 
    puts $logFile {AddAvalonMMSlaveInterface}
    puts $logFile "\t\t\t\t\t$memoryBlock"
    puts $logFile ">> sopc: \"$sopc\""
}

# AddAvalonInterruptReceiverInterface
#     Called when an interrupt receiver interface containing interrupts is 
#     found. Any relevant receiver information is added to "sopc". 
# Arguments: 
#     interface       An interrupt receiver interface DOM node. 
proc AddAvalonInterruptReceiverInterface {interface} {
    global logFile sopc offset
    global AAMMMI_times_called AAIRI_times_called AIPIC_times_called
    
    # Update last MMMI or IRI offset
    set miIndex [expr ($AAMMMI_times_called + $AAIRI_times_called)]
    if {$miIndex != 0} {
	set sopc "[string range $sopc 0 end-2] nextIfOffset $offset\
		  [string range $sopc end-1 end]"
    }
    incr AAIRI_times_called; # this interrupt receiver number
    # Add Receiver Name to Dictionary
    set startOffset $offset
    set name [$interface selectNodes @name]
    set name [string range $name 6 end-1]
    set nameOffset [expr ($startOffset + 8)]
    # offset for next structure
    set offset [expr ($nameOffset + [string length $name] + 1)]
    set offset [expr ((($offset + 3) / 4) * 4)]; # word align
    set intSndrListOffset $offset
    #
    dict set sopc "avalonIPCap$AIPIC_times_called" \
		  "avalonIntRcvrIntf$AAIRI_times_called" \
		  [dict create startOffset       $startOffset \
			       intRcvrNameOffset $nameOffset \
			       intSndrListOffset $intSndrListOffset \
			       intRcvrName       $name]
    set miIndex [expr ($AAMMMI_times_called + $AAIRI_times_called)]
    #
    puts -nonewline $logFile "\t\t\t\t" 
    puts $logFile {AddAvalonInterruptReceiverInterface}
    puts $logFile "\t\t\t\t\t$interface"
    puts $logFile ">> sopc: \"$sopc\""
}

# AddAvalonInterruptSenderInterface
#     Called when an interrupt is found in an interrupt sender interface. 
#     Any necessary sender information is added to "sopc". 
# Arguments: 
#     interrupt       An interrupt DOM node. 
proc AddAvalonInterruptSenderInterface {interrupt} {
    global logFile sopc offset
    global AAISI_times_called AAMMSI_times_called
    global AAIRI_times_called AIPIC_times_called

    # Update last Interrupt Sender offset
    set siIndex [expr ($AAMMSI_times_called + $AAISI_times_called)]
    if {$siIndex != 0} {
	set sopc "[string range $sopc 0 end-3] nextIfOffset $offset\
		  [string range $sopc end-2 end]"
    }
    incr AAISI_times_called; # this interrupt sender number
    # Add slaveName, moduleName, and interruptNumber to Dictionary
    set startOffset $offset
    set sndrNameNode [$interrupt selectNodes slaveName]
    set sndrName [$sndrNameNode asText]
    set sndrNameOffset [expr ($offset + 12)]
    set modNameNode [$interrupt selectNodes moduleName]
    set modName [$modNameNode asText]
    set modNameOffset [expr ($sndrNameOffset + [string length $sndrName] + 1)]
    set intNumNode [$interrupt selectNodes interruptNumber]
    set intNum [$intNumNode asText]
    # offset for next structure
    set offset [expr ($modNameOffset + [string length $modName] + 1)]
    set offset [expr ((($offset + 3) / 4) * 4)]; # word align
    #
    dict set sopc "avalonIPCap$AIPIC_times_called" \
             "avalonIntRcvrIntf$AAIRI_times_called" \
             "avalonIntSendIntf$AAISI_times_called" \
             [dict create startOffset    $startOffset \
			  sndrNameOffset $sndrNameOffset \
			  modNameOffset  $modNameOffset \
			  sndrName       $sndrName \
                          modName        $modName \
                          intNum         $intNum]
    set siIndex [expr ($AAMMSI_times_called + $AAISI_times_called)]
    #
    puts -nonewline $logFile "\t\t\t\t" 
    puts $logFile {AddAvalonInterruptSenderInterface}
    puts $logFile "\t\t\t\t\t$interrupt"
    puts $logFile ">> sopc: \"$sopc\""
}

# *** Output Device Information Structure ***
proc OutputDeviceID {key0} {
    global logFile sopc addr devIdCap

    set devName       [dict get $sopc $key0 devName]
    set partNum       [dict get $sopc $key0 partNum]
    set gwVer         [dict get $sopc $key0 gwVer]
    set gitCommit     [dict get $sopc $key0 gitCommit]
    set buildId       [dict get $sopc $key0 buildId]
    set startOffset   [dict get $sopc $key0 startOffset]
    set nextKnsCapOff [dict get $sopc $key0 nextKnsCapOff]
    set devNameOffset [dict get $sopc $key0 devNameOffset]
    set partNumOffset [dict get $sopc $key0 partNumOffset]
    # Output Device ID Structure
    set hexStr [format "*Dev ID: %04X%s  @00h" $nextKnsCapOff $devIdCap]
    puts $logFile $hexStr
    set hexStr [format "%04X%s" $nextKnsCapOff $devIdCap]
    GenHex4 $hexStr $addr
    set hexStr [format "*Dev ID: %04X%04X  @04h" $partNumOffset $devNameOffset]
    puts $logFile $hexStr
    set hexStr [format "%04X%04X" $partNumOffset $devNameOffset]
    GenHex4 $hexStr [set addr [expr $addr + 1]]
    set hexStr [format "*Dev ID: 0000%04X  @08h" $gwVer]
    puts $logFile $hexStr
    set hexStr [format "0000%04X" $gwVer]
    GenHex4 $hexStr [set addr [expr $addr + 1]]
    set hexStr [format "*Dev ID: %08X  @0Ch" $gitCommit]
    puts $logFile $hexStr
    set hexStr [format "%08X" $gitCommit]
    GenHex4 $hexStr [set addr [expr $addr + 1]]
    set hexStr [format "*Dev ID: %08X  @0Ch" $buildId]
    puts $logFile $hexStr
    set hexStr [format "%08X" $buildId]
    GenHex4 $hexStr [set addr [expr $addr + 1]]
    # Convert strings characters to decimal
    binary scan [encoding convertto ascii $devName] c* decStr
    append decStr " 0 "; # null terminate the string
    binary scan [encoding convertto ascii $partNum] c* nxtDecStr
    append decStr $nxtDecStr
    append decStr " 0"
    set hexStr {};	# start with empty string
    foreach i $decStr { append hexStr [format "%02X" $i] }
    puts $logFile "*** Device ID Capability Strings ***"
#    puts $logFile "$hexStr"; # log the result
    GenStrHex4 $hexStr [set addr [expr $addr + 1]]
    set addr [expr {$addr + (([string length $hexStr] / 2) + 3) / 4}]
}

# *** IP Identification Structures ***
proc OutputIPCap {key0} {
    global logFile sopc ipCapOff addr ipCap

    set startOffset   [dict get $sopc $key0 startOffset]
    set kindStrOffset [dict get $sopc $key0 kindStrOffset]
    set nameStrOffset [dict get $sopc $key0 nameStrOffset]
    set verStrOffset  [dict get $sopc $key0 verStrOffset]
    set ifListOffset  [dict get $sopc $key0 ifListOffset]
    set modKind       [dict get $sopc $key0 modKind]
    set modName       [dict get $sopc $key0 modName]
    set modVer        [dict get $sopc $key0 modVer]
    if {[dict exists $sopc $key0 nextKnsCapOff]} {
	set nextKnsCapOff [dict get $sopc $key0 nextKnsCapOff]
    } else {
	set nextKnsCapOff 0; # last IP Capability in the list
    }
    # Output IP Identification Capability Structure
    set hexStr [format "*IP Cap: %04X%s  @00h" $nextKnsCapOff $ipCap]
    puts $logFile $hexStr
    set hexStr [format "%04X%s" $nextKnsCapOff $ipCap]
    GenHex4 $hexStr $addr
    set hexStr [format "*IP Cap: %04X%04X  @04h" $nameStrOffset $kindStrOffset]
    puts $logFile $hexStr
    set hexStr [format "%04X%04X" $nameStrOffset $kindStrOffset]
    GenHex4 $hexStr [set addr [expr $addr + 1]]
    set hexStr [format "*IP Cap: %04X%04X  @08h" $ifListOffset $verStrOffset]
    puts $logFile $hexStr
    set hexStr [format "%04X%04X" $ifListOffset $verStrOffset]
    GenHex4 $hexStr [set addr [expr $addr + 1]]
    # Convert the strings characters to decimal
    binary scan [encoding convertto ascii $modKind] c* decStr
    append decStr " 0 ";	# null terminate the string
    binary scan [encoding convertto ascii $modName] c* nxtDecStr
    append decStr $nxtDecStr;
    append decStr " 0 ";	# null terminate the string
    binary scan [encoding convertto ascii $modVer] c* nxtDecStr
    append decStr $nxtDecStr;
    append decStr " 0";		# null terminate the string
    # ASCII hex bytes to hexStr
    set hexStr {};	# start with empty string
    foreach i $decStr { append hexStr [format "%02X" $i] }
    puts $logFile "*** IP Capability Strings ***"
    puts $logFile "$modKind $modName $modVer"
    puts $logFile $hexStr
    GenStrHex4 $hexStr [set addr [expr $addr + 1]]
    set addr [expr {$addr + (([string length $hexStr] / 2) + 3) / 4}]
}

# ** Output Master Interface Structure **
proc OutputMasterIntf {key0 key1} {
    global logFile sopc addr masterIF

    puts $logFile "*Master Interface key0: $key0"
    puts $logFile "*                 key1: $key1"
    set startOffset    [dict get $sopc $key0 $key1 startOffset]
    set nameStrOffset  [dict get $sopc $key0 $key1 nameStrOffset]
    set slIfListOffset [dict get $sopc $key0 $key1 slIfListOffset]
    set masterName     [dict get $sopc $key0 $key1 masterName]
    if {[dict exists $sopc $key0 $key1 nextIfOffset]} {
	set nextIfOffset   [dict get $sopc $key0 $key1 nextIfOffset]
    } else {
	set nextIfOffset 0; # last Master in the list
    }
    puts $logFile "masterName: $masterName"
    # Output Master Interface Structure
    # Next Interface Offset | Version=1h | Interface Type=1h
    set hexStr [format "*MstrIF: %04X%s  @00h" $nextIfOffset $masterIF]
    puts $logFile $hexStr
    set hexStr [format "%04X%s" $nextIfOffset $masterIF]
    GenHex4 $hexStr $addr
    # Slave Interface List Offset | Master Interface Name String Offset
    set hexStr [format "*MstrIF: %04X%04X  @04h" \
			$slIfListOffset $nameStrOffset]
    puts $logFile $hexStr
    set hexStr [format "%04X%04X" $slIfListOffset $nameStrOffset]
    GenHex4 $hexStr [set addr [expr $addr + 1]]
    # Convert strings characters to decimal
    binary scan [encoding convertto ascii $masterName] c* decStr
    append decStr " 0"; # null terminate the string
    set hexStr {};	# start with empty string
    foreach i $decStr { append hexStr [format "%02X" $i] }
    puts $logFile "** Master Interface Strings **"
    puts $logFile "$masterName"
    puts $logFile "$hexStr"; # log the result
    GenStrHex4 $hexStr [set addr [expr $addr + 1]]
    set addr [expr {$addr + (([string length $hexStr] / 2) + 3) / 4}]
}

# ** Output Master Interrupt Receiver Structure **
proc OutputIntRcvrIntf {key0 key1} {
    global logFile sopc addr intRcvr

    puts $logFile "*Interrupt Receiver key0: $key0"
    puts $logFile "*                   key1: $key1"
    set startOffset       [dict get $sopc $key0 $key1 startOffset]
    set intRcvrNameOffset [dict get $sopc $key0 $key1 intRcvrNameOffset]
    set intSndrListOffset [dict get $sopc $key0 $key1 intSndrListOffset]
    set intRcvrName       [dict get $sopc $key0 $key1 intRcvrName]
    if {[dict exists $sopc $key0 $key1 nextIfOffset]} {
	set nextIfOffset  [dict get $sopc $key0 $key1 nextIfOffset]
    } else {
	set nextIfOffset 0; # last Master Receiver in the list
    }
    puts $logFile "intRcvrName: $intRcvrName"
    # +++ Output Master Interrupt Receiver Structure +++
    # Next Interface Offset | Version=1h | Interface Type=2h
    set hexStr [format "*MstrIF: %04X%s  @00h" $nextIfOffset $intRcvr]
    puts $logFile $hexStr
    set hexStr [format "%04X%s" $nextIfOffset $intRcvr]
    GenHex4 $hexStr $addr
    # Interrupt Sender List Offset | Interrupt Receiver Name String Offset
    set hexStr [format "*MstrIF: %04X%04X  @04h" \
    	$intSndrListOffset $intRcvrNameOffset]
    puts $logFile $hexStr
    set hexStr [format "%04X%04X" $intSndrListOffset $intRcvrNameOffset]
    GenHex4 $hexStr [set addr [expr $addr + 1]]
    # +++ Convert strings characters to decimal +++
    binary scan [encoding convertto ascii $intRcvrName] c* decStr
    append decStr " 0"; # null terminate the string
    # +++ Convert decimal to hexidecimal string +++
    set hexStr {};	# start with empty string
    foreach i $decStr { append hexStr [format "%02X" $i] }
    puts $logFile "** Interrupt Receiver Interface Strings **"
    puts $logFile "$hexStr"; # log the result
    GenStrHex4 $hexStr [set addr [expr $addr + 1]]
    set addr [expr {$addr + (([string length $hexStr] / 2) + 3) / 4}]
}

proc OutputSlaveIntf {key0 key1 key2} {
    global logFile sopc addr slaveIF

    puts $logFile "*Slave Interface key0: $key0"
    puts $logFile "*                key1: $key1"
    puts $logFile "*                key2: $key2"
    set startOffset      [dict get $sopc $key0 $key1 $key2 startOffset]
    set slaveNameOffset  [dict get $sopc $key0 $key1 $key2 slaveNameOffset]
    set moduleNameOffset [dict get $sopc $key0 $key1 $key2 moduleNameOffset] 
    set baseAddress      [dict get $sopc $key0 $key1 $key2 baseAddress]
    set span             [dict get $sopc $key0 $key1 $key2 span]
    set slaveName        [dict get $sopc $key0 $key1 $key2 slaveName]
    set moduleName       [dict get $sopc $key0 $key1 $key2 moduleName]
    if {[dict exists $sopc $key0 $key1 $key2 nextIfOffset]} {
	set nextIfOffset [dict get $sopc $key0 $key1 $key2 nextIfOffset]
    } else {
	set nextIfOffset 0; # last Slave in the list
    }
    puts $logFile "slaveName: $slaveName"
    # +++ Output Master Interface Structure +++
    # Next Interface Offset | Version=1h | Interface Type=2h
    set hexStr [format "*SlavIF: %04X%s  @00h" $nextIfOffset $slaveIF]
    puts $logFile $hexStr
    set hexStr [format "%04X%s" $nextIfOffset $slaveIF]
    GenHex4 $hexStr $addr
    # Module Name String Offset | Slave Interface Name String Offset
    set hexStr [format "*SlavIF: %04X%04X  @04h" \
			$moduleNameOffset $slaveNameOffset]
    puts $logFile $hexStr
    set hexStr [format "%04X%04X" $moduleNameOffset $slaveNameOffset]
    GenHex4 $hexStr [set addr [expr $addr + 1]]
    #
    # Base Address (Lower)
    set hexStr [format "%08X" $baseAddress]; # low 32-bits
    set hexStr2 [format "%08X" [expr $baseAddress / 4294967296]]; # high 32-bits
    puts $logFile "BaseAddress: $baseAddress -> $hexStr2\_$hexStr"
    puts $logFile [format "*SlavIF: %s  @08h" $hexStr]
    GenHex4 $hexStr [set addr [expr $addr + 1]]
    # Base Address (Upper)
    puts $logFile [format "*SlavIF: %s  @0Ch" $hexStr2]
    GenHex4 $hexStr2 [set addr [expr $addr + 1]]
    #
    # Address Span (Lower)
    set hexStr [format "%08X" $span]; # lower 32-bits
    set hexStr2 [format "%08X" [expr $span / 4294967296]]; # upper 32-bits
    puts $logFile "Span: $span -> $hexStr2\_$hexStr"
    puts $logFile [format "*SlavIF: %s  @10h" $hexStr]
    GenHex4 $hexStr [set addr [expr $addr + 1]]
    # Address Span (Upper)
    puts $logFile [format "*SlavIF: %s  @14h" $hexStr2]
    GenHex4 $hexStr2 [set addr [expr $addr + 1]]
    #
    # +++ Convert strings characters to decimal +++
    binary scan [encoding convertto ascii $slaveName] c* decStr
    append decStr " 0 "; # null terminate the string
    binary scan [encoding convertto ascii $moduleName] c* nxtDecStr
    append decStr $nxtDecStr;
    append decStr " 0 ";	# null terminate the string
    # +++ Convert decimal to hexidecimal string +++
    set hexStr {};	# start with empty string
    foreach i $decStr { append hexStr [format "%02X" $i] }
    puts $logFile "** Slave Interface Strings **"
    puts $logFile "$moduleName.$slaveName"
    puts $logFile "$hexStr"; # log the result
    GenStrHex4 $hexStr [set addr [expr $addr + 1]]
    set addr [expr {$addr + (([string length $hexStr] / 2) + 3) / 4}]
}

proc OutputIntSendIntf {key0 key1 key2} {
    global logFile sopc addr intSndr

    puts $logFile "*Int Sender Interface key0: $key0"
    puts $logFile "*                     key1: $key1"
    puts $logFile "*                     key2: $key2"
    set startOffset      [dict get $sopc $key0 $key1 $key2 startOffset]
    set sndrNameOffset   [dict get $sopc $key0 $key1 $key2 sndrNameOffset]
    set modNameOffset    [dict get $sopc $key0 $key1 $key2 modNameOffset]
    set sndrName         [dict get $sopc $key0 $key1 $key2 sndrName]
    set modName          [dict get $sopc $key0 $key1 $key2 modName]
    set intNum           [dict get $sopc $key0 $key1 $key2 intNum]
    if {[dict exists $sopc $key0 $key1 $key2 nextIfOffset]} {
	set nextIfOffset [dict get $sopc $key0 $key1 $key2 nextIfOffset]
    } else {
	set nextIfOffset 0; # last Sender in the list
    }
    puts $logFile "sndrName: $sndrName"
    # +++ Interrupt Sender Interface Structure +++
    # Next Interface Offset | Version=1h | Interface Type=4h
    set hexStr [format "*IntSnd: %04X%s  @00h" $nextIfOffset $intSndr]
    puts $logFile $hexStr
    set hexStr [format "%04X%s" $nextIfOffset $intSndr]
    GenHex4 $hexStr $addr
    # Module Name String Offset | Interrupt Sender Name String Offset
    set hexStr [format "*IntSnd: %04X%04X  @04h" \
			$modNameOffset $sndrNameOffset]
    puts $logFile $hexStr
    set hexStr [format "%04X%04X" $modNameOffset $sndrNameOffset]
    GenHex4 $hexStr [set addr [expr $addr + 1]]
    # 0000 | 000 | IRQ#
    set hexStr [format "*IntSnd: 0000000%01X  @08h" $intNum]
    puts $logFile $hexStr
    set hexStr [format "0000000%01X" $intNum]
    GenHex4 $hexStr [set addr [expr $addr + 1]]
    # +++ Convert strings characters to decimal +++
    binary scan [encoding convertto ascii $sndrName] c* decStr
    append decStr " 0 "; # null terminate the string
    binary scan [encoding convertto ascii $modName] c* nxtDecStr
    append decStr $nxtDecStr;
    append decStr " 0 ";	# null terminate the string
    # +++ Convert decimal to hexidecimal string +++
    set hexStr {};	# start with empty string
    foreach i $decStr { append hexStr [format "%02X" $i] }
    puts $logFile "** Interrupt Sender Strings **"
    puts $logFile "$hexStr"; # log the result
    GenStrHex4 $hexStr [set addr [expr $addr + 1]]
    set addr [expr {$addr + (([string length $hexStr] / 2) + 3) / 4}]
}


proc GenHex4 {hexStr startAddr} {
	#puts "DEBUG: ${hexStr} ${startAddr}"
    global logFile hexFile
    set memFileStr ":04";				# start code & byte cnt
    set chkSum -4
    append memFileStr [format "%04X" $startAddr];	# address
    set chkSum [expr {$chkSum - $startAddr / 256 - $startAddr % 256}] 
    append memFileStr "00";				# record type
    # 
    set thisByte xx
    for {set i 0} {$i < 8} {set i [expr {$i + 2}]} {
		set byteStr [string range $hexStr $i [expr $i + 1]]
	    #puts "DEBUG Byte: $byteStr"
		#Fix from amarchan@matrox.com
		# See http://core.tcl.tk/tcl/info/e077937cf04d43d2c43f1bca0cf86fa0b68b6bbb
		##scan $byteStr %2X thisByte <= Bug in tcl (X upper case not supported in this tcl version)
		scan $byteStr %2x thisByte
		append memFileStr [format "%02X" $thisByte]; # data byte
		set chkSum [expr $chkSum - $thisByte];	     # checksum calculation
    }
    #
    set chkSum [expr $chkSum % 256];	# use only lower byte
    append memFileStr [format "%02X" $chkSum];	# checksum
    #
    puts $logFile "$memFileStr";	# this record is complete
    puts $hexFile "$memFileStr";	# this record is complete
}

proc GenStrHex4 {hexStr startAddr} {
    global logFile hexFile

    set words [expr {(([string length $hexStr] / 2) + 3) / 4}]
    for {set j 0} {$j < $words} {incr j} {
	set addr [expr $startAddr + $j]
	set memFileStr ":04";				# start code & byte cnt
	set chkSum -4
	append memFileStr [format "%04X" $addr];	# address
	set chkSum [expr {($chkSum - $addr / 256 - $addr % 256)}] 
	append memFileStr "00";				# record type
	# output bytes in words in reverse order
	set thisByte zz
	for {set i 6} {$i >= 0} {set i [expr {$i - 2}]} {
	    set k [expr {($j * 8 + $i)}]; 
	    if {$k >= [string length $hexStr]} {
		set byteStr "00"
	    } else {
		set byteStr [string range $hexStr $k [expr $k + 1]]
	    }
		#Fix from amarchan@matrox.com
		# See http://core.tcl.tk/tcl/info/e077937cf04d43d2c43f1bca0cf86fa0b68b6bbb
		##scan $byteStr %2X thisByte <= Bug in tcl (X upper case not supported in this tcl version)
	    scan $byteStr %2x thisByte
	    append memFileStr [format "%02X" $thisByte]; # data byte
	    set chkSum [expr $chkSum - $thisByte];	 # checksum calculation
	}
	#
	set chkSum [expr $chkSum % 256];	# use only lower byte
	append memFileStr [format "%02X" $chkSum];	# checksum
	puts $logFile "$memFileStr";	# this record is complete
	puts $hexFile "$memFileStr";	# this record is complete
    }
}

# Done
#     Simply makes any necessary closing statements. 
proc Done {} {
    global logFile
    global hexFile
    # Close log file
    puts  $logFile {Done}
    close $logFile
    # Close HEX file
    puts  $hexFile ":00000001FF"; # End of File record
    close $hexFile
    puts "Parsing done"
   
	#fix amarchan@matrox.com. Can't use exit command from Quartus TCL shell
	#exit
}

# Separator
#     Prints a separator to the output file. 
proc Separator {} {
    global logFile
    puts            $logFile ""
    puts -nonewline $logFile "---------------------------------------"
    puts            $logFile "---------------------------------------"
}






###################################################################################
# Main section of this script (Top level)
###################################################################################

# SOPCINFO_FILE defined by the calling script
set sopcinfo_file ${SOPCINFO_FILE} 

if { [file exists ${sopcinfo_file}] } {

    puts "Parsing ${sopcinfo_file}"
    set inputFile [open ${sopcinfo_file} "r"]
}

set inputString [read $inputFile]
close $inputFile
set logFile [open "PnP_ROM_Parse.log" "w"]
set hexFile [open "./PnP_ROM.hex" "w"]

# Set Up Parser
set dom [dom parse $inputString]
set doc [$dom documentElement]

# Version Match
#set noMatch [VersionMatch "14.0 200"]
#if {$noMatch} {
#    Done
#}
Separator

# For Naming Conventions for the procs Involved with the dict. Every time a 
# dict-altering procedure is called, these are incremented and used to tag on 
# to the end of data strings. 
set AIPIC_times_called 0
set AAMMMI_times_called 0
set AAMMSI_times_called 0
set AAIRI_times_called 0
set AAISI_times_called 0

# Makes sure that AddIPIdentificationCapability is called only once per module
set firstInModule 1

# Create New Empty Dictionaries
set sopc              [dict create]
puts $logFile "sopc: \"$sopc\""
#set devCapOff         [dict create]
#set ipCapOff          [dict create]
set master_intRcvrOff [dict create]
set slave_intSndrOff  [dict create]
#
set offset 0;	# zero running structure byte address offset
set addr 0;		# zero running word address
set devIdCap 2001;	# Version = 2, K&S Capability ID = 1
set ipCap    1002;	# Version = 1, K&S Capability ID = 2
set masterIF 1001;	# Version = 1, Interface Type = 1
set slaveIF  1002;	# Version = 1, Interface Type = 2
set intRcvr  1003;	# Version = 1, Interface Type = 3
set intSndr  1004;	# Version = 1, Interface Type = 4

Separator

# Create List of Modules Named: "PnP_ROM"
set PnP_ROM_name_list [$doc selectNodes {module[@kind="PnPROM"]/@name}]
set PnP_ROM_node_list [$doc selectNodes {module[@kind="PnPROM"]}]
# Handle List
puts $logFile "PnP_ROM Module Names"
foreach pnpModuleName $PnP_ROM_name_list \
    pnpModuleNode $PnP_ROM_node_list {
	set pnpModuleName [string range $pnpModuleName 5 end]
	puts $logFile "\t$pnpModuleName: $pnpModuleNode"
    }
Separator
# >>> There should be only one PnP Module in the design <<<
# Add deviceIDCAP to the sopc dictionary (first entry)
foreach pnpModuleNode $PnP_ROM_node_list {
    puts $logFile [$pnpModuleNode selectNodes {@name}]
    ExtractDeviceIdentification $pnpModuleNode
    set firstInModule 1
}
Separator

# Create List of all Modules
set allModNameList [$doc selectNodes {module/@name}]
set allModNodeList [$doc selectNodes {module}]
# Handle List
puts $logFile "All Module Names"
foreach nonpnpModuleName $allModNameList \
    anyModuleNode $allModNodeList {
	set nonpnpModuleName [string range $nonpnpModuleName 5 end]
	puts $logFile "\t$nonpnpModuleName: $anyModuleNode"
    }
Separator
# Add avalonIPCap* to the sopc dictionary
foreach anyModuleNode $allModNodeList {
    ExtractAvalonMaster_IntReceiver $anyModuleNode
    Separator
    set AAMMMI_times_called 0
    set AAIRI_times_called 0
    set firstInModule 1
}

# Print Raw sopc Dictionary Data
puts $logFile ">> sopc: \"$sopc\""
Separator

# Print Indented sopc Dictionary Data
# Note:       The following code structure also forms the basis of the current
#             GenerateMEMFile algorithm. Because "sopc" is a dict with key/
#             value pairs, every other word is either a key or a value, and
#             can therefore be differentiated and given an appropriate 
#             indentation. The GenerateMEMFile algorithm goes backwards, 
#             judging what a word could be based on its "indentation" level. 

set num0 0;		# initialize word0 counter
foreach word0 $sopc {
    if {[expr $num0 % 2] == 0} {
	puts $logFile "$word0"
	#puts $logFile "[binary encode hex $word0]"
    } else {
	set num1 0
	foreach word1 $word0 {
	    if {[expr $num1 % 2] == 0} {
		puts $logFile "\t$word1"
		#puts $logFile "\t[binary encode hex $word1]"
	    } else {
		set num2 0
		foreach word2 $word1 {
		    if {[expr $num2 % 2] == 0} {
			puts $logFile "\t\t$word2"
			#puts $logFile "\t\t[binary encode hex $word2]"
		    } else {
			set num3 0
			foreach word3 $word2 {
			    if {[expr $num3 % 2] == 0} {
				puts $logFile "\t\t\t$word3"
				#puts $logFile "\t\t\t[binary encode\
				    hex $word3]"
                            } else {
                                puts $logFile "\t\t\t\t$word3"
                                #puts $logFile "\t\t\t\t[binary encode\
							     hex $word3]"
                            }
                            incr num3
                        }
                    }
                    incr num2
                }
            }
            incr num1
        }
    }
    incr num0
}
Separator

# Write the "sopc" Data to a ROM Image
#     Note:       This Algorithm in based on the part of the code that prints
#                 the contents of "sopc" in an indented fashion. The words 
#                 "# Indent Word" are used here to refer to the word with #
#                 indents in the indented version of "sopc". Each word in 
#                 "sopc" is visited, and its possible meaning is determined by
#                 the amount of indent that it would have if printed in the 
#                 code below. Then, its meaning is determined by a string 
#                 match. From there, it is handled and written into memory if 
#                 necessary. The code to do so for each type of word has not 
#                 yet been written. 
puts $logFile "Generate MEM File"
#
set num0 0
foreach word0 $sopc {
    # if a key
    if {[expr {$num0 % 2}] == 0} {
	set key0 $word0
	# if the key is "deviceIDCap"
	if {[string match "deviceIDCap" $key0]} {
	    OutputDeviceID $key0
	    # elseif the key is "avalonIPCap*"
	} elseif {[string match "avalonIPCap*" $key0]} {
	    OutputIPCap $key0 
	}
	# else a value or nested key
    } else {
	set num1 0
	foreach word1 $word0 {
	    # if a key
	    if {[expr $num1 % 2] == 0} {
		set key1 $word1
		# if the key is "avalonMasterIntf*"
		if {[string match "avalonMasterIntf*" $word1]} {
		    OutputMasterIntf $key0 $key1
		    # elseif the key is "avalonIntRcvrIntf*"
		} elseif {[string match "avalonIntRcvrIntf*" $word1]} {
		    OutputIntRcvrIntf $key0 $key1
		}
	    } else {
		set num2 0
		foreach word2 $word1 {
		    # if a key
		    if {[expr $num2 % 2] == 0} {
			set key2 $word2
			# if the key is "avalonSlaveInt*"
			if {[string match "avalonSlaveIntf*" $word2]} {
			    OutputSlaveIntf $key0 $key1 $key2
			    # if the key is "avalonIntSendIntf*"
			} elseif {[string match "avalonIntSendIntf*" $word2]} {
			    OutputIntSendIntf $key0 $key1 $key2
			}
		    }
		    incr num2
		}
	    }
	    incr num1
	}
    }
    incr num0
}

Separator

Done

Matrox CPUSKL/KBL K&S VME Bridge FPGA Design
============================================

+------------+-----------------------------------------------------------------+
| Folder     | Description                                                     |
+------------+-----------------------------------------------------------------+
| archive    | Contains Quartus archives of important releases.                |
+------------+-----------------------------------------------------------------+
| backend    | Contains all scripts for creating the Quartus project, the QSYS |
|            | system, timing constraints and QSF assignments, FPGA pinout.    |
+------------+-----------------------------------------------------------------+
| design     | Contains all design files that do not belong to QSYS IP Cores   |
|            | nor Altera Megafunction.                                        |
+------------+-----------------------------------------------------------------+
| ipcores    | Library of all IP required by the KVB project (QSYS IP and      |
|            | MegaFunctions IP).                                              |
+------------+-----------------------------------------------------------------+
| quartus    | The work folder for Quartus. All Quartus output will be         |
|            | generated under this folder. This project contains three        |
|            | Quartus revisions: skl_ball, skl_wedge, & kbl. Each revision    |
|            | has its own output subfolder.                                   |
+------------+-----------------------------------------------------------------+

Revisions
---------
2.0 - Matrox take over. Contains all files for creating the KVB FPGA firmware
      for the CPUSKL board PCB 7521_01. Note that there is a pinout definition
      change on this revision. See the file: ./backend/set_pinout.tcl.
2.1 - Replace 3 LPC UARTs with PCIe UARTs. Replace I2C master. Add CRA slave
      interface to PCIe-AvalonMM bridge. Add Git commit to scripts and PnP ROM.
      Add one-shot timer for camera triggers. Add PIO for user LEDs. Add QAR
      and ZIP archive generation to scripts.
2.2 - Update VME, QSPI, and PCIe UART IP. Add VME timing constraints.
2.4 - Reduce MRAM controller read clock to clk/12 as work-around for issue with
      TXB0108 auto-direction level translator.
2.5 - Fix MRAM controller QSPI bus contention issue during reads.
2.6 - Add final IO timing constraints.
2.7 - Fix I2C master controller clock domain crossing issue.
2.8 - Fix violation of timing rule 2.36 in VME master (VME spec revision C.1).
3.0 - Add support for CPUSKL/KC/KD (wedge bonder) and CPUKBL/KA.
3.1 - Add PIO IP for voltage_alert and power_failure_n signals.
3.2 - Connect COM1 to COM2 internally for wedge bonder.


Requirements
------------
1.  Quartus Prime 17.0 Standard Edition.
2.  Quartus Prime Standard Edition floating license added to LM_LICENSE_FILE
    environment variable.
    
    Example (LM_LICENSE_FILE already defined):
    setx LM_LICENSE_FILE "%LM_LICENSE_FILE%;27006@licserv-altera.corp.kns.com" /M

    Example (no LM_LICENSE_FILE defined):
    setx LM_LICENSE_FILE "27006@licserv-altera.corp.kns.com" /M

3.  Matrox license for LPC2Avalon IP core (part of floating license; exp 31-May-2018).
4.  Windows environment variable KVB defined for absolute path to repo.

    Example: setx KVB "C:/intelFPGA/projects/kvb"


Creating and Compiling Project from Quartus
-------------------------------------------
1.  Start Quartus.
2.  In the Tcl console source the following script:

    source "$::env(KVB)/backend/create_quartus_project.tcl"

3.  Select the desired Quartus project revision.
4.  Run start compilation (Ctrl+L) or compile all in Revisions (in Project Navigator).


Creating, Compiling, and Checking Project from Command-Line
-----------------------------------------------------------
1.  Open Command Prompt.
2.  Execute the following command:

    All revisions sequential:

    %KVB%\backend\create_quartus_project && %KVB%\backend\build_quartus_project && %KVB%\backend\check_messages

    All revisions parallel build:

    %KVB%\backend\create_quartus_project && %KVB%\backend\build_quartus_project parallel && %KVB%\backend\check_messages

    Single revision:

    %KVB%\backend\create_quartus_project && %KVB%\backend\build_quartus_project <revision name> && %KVB%\backend\check_messages <revision name>


Notes
-----
1.  To add IP cores to search path for Qsys, open Qsys and go to Tools -> Options

    Example: C:/intelFPGA/projects/kvb/ipcores/quartus17.0/**/*

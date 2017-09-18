Matrox CPUSKL K&S VME Bridge FPGA Design
========================================

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
| quartus    | The work folder for quartus. All Quartus output will be         |
|            | generated under this folder.                                    |
+------------+-----------------------------------------------------------------+

Revisions
---------
2.0 - Matrox take over. Contains all files for creating the KVB FPGA firmware
      for the CPUSKL board PCB 7521_01. Note that there is a pinout definition
      change on this revision. See the file: ./backend/set_pinout.tcl.
2.1 - Replaced 3 LPC UARTs with PCIe UARTs. Replaced I2C master. Added CRA slave
      interface to PCIe-AvalonMM bridge. Added Git commit to scripts and PnP ROM.


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


Creating and Compiling Project
------------------------------
1.  Start Quartus.
2.  In the Tcl console source the following script:

    source "$::env(KVB)/backend/create_quartus_project.tcl"

3.  Run the start compilation (Ctrl+L).


Notes
-----
1.  To add IP cores to search path for Qsys, open Qsys and go to Tools -> Options

    Example: C:/intelFPGA/projects/kvb/ipcores/quartus17.0/**/*

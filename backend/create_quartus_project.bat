@echo off
@rem ---------------------------------------------------------------------------
@rem  FILE: create_quartus_project.bat
@rem
@rem  COPYRIGHT (C) 2019 BY KULICKE AND SOFFA INDUSTRIES, INC.
@rem  This software is the property of Kulicke and Soffa Industries, Inc.
@rem  Any reproduction or distribution to a third party is
@rem  strictly forbidden unless written permission is given by an
@rem  authorized agent of Kulicke and Soffa.
@rem
@rem  Create Quartus project script for KVB FPGA project.
@rem
@rem  DATE      NAME              CHANGE DESCRIPTION
@rem  --------- ----------------- ----------------------------------------------
@rem  12-Mar-19 D.Rauth           Created
@rem ---------------------------------------------------------------------------

if exist "%KVB%\quartus" goto done
quartus_sh -t %KVB%/backend/create_quartus_project.tcl

:done

@echo off
@rem ---------------------------------------------------------------------------
@rem  FILE: check_messages.bat
@rem
@rem  COPYRIGHT (C) 2019 BY KULICKE AND SOFFA INDUSTRIES, INC.
@rem  This software is the property of Kulicke and Soffa Industries, Inc.
@rem  Any reproduction or distribution to a third party is
@rem  strictly forbidden unless written permission is given by an
@rem  authorized agent of Kulicke and Soffa.
@rem
@rem  Check build messages script for KVB FPGA project.
@rem
@rem  CALLING FORMATS:
@rem    check_messages               - Check all revisions in series
@rem    check_messages <rev_name>    - Check <rev_name> revision
@rem
@rem  DATE      NAME              CHANGE DESCRIPTION
@rem  --------- ----------------- ----------------------------------------------
@rem  12-Mar-19 D.Rauth           Created
@rem  19-Mar-19 D.Rauth           Wait for quartus_sh to exit before checking
@rem ---------------------------------------------------------------------------


:loop
tasklist | find /i "quartus_sh" >nul 2>&1
if ERRORLEVEL 1 (
  goto continue
) else (
  timeout /T 1 /nobreak >nul
  goto loop
)

:continue
quartus_sh -t %KVB%/backend/check_messages.tcl %1

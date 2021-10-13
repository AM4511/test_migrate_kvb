@echo off
@rem ---------------------------------------------------------------------------
@rem  FILE: build_quartus_project.bat
@rem
@rem  COPYRIGHT (C) 2019 BY KULICKE AND SOFFA INDUSTRIES, INC.
@rem  This software is the property of Kulicke and Soffa Industries, Inc.
@rem  Any reproduction or distribution to a third party is
@rem  strictly forbidden unless written permission is given by an
@rem  authorized agent of Kulicke and Soffa.
@rem
@rem  Build script for KVB FPGA project.
@rem
@rem  CALLING FORMATS:
@rem    build_quartus_project               - Build all revisions in series
@rem    build_quartus_project parallel      - Build all revisions in parallel
@rem    build_quartus_project <rev_name>    - Build <rev_name> revision
@rem
@rem  DATE      NAME              CHANGE DESCRIPTION
@rem  --------- ----------------- ----------------------------------------------
@rem  12-Mar-19 D.Rauth           Created
@rem  26-Sep-19 D.Rauth           Change kbl to kbl_ball
@rem  07-Oct-21 D.Rauth           Added *_22 and *_75 revs
@rem ---------------------------------------------------------------------------

if "%1" == "parallel" goto parallel
quartus_sh -t %KVB%/backend/build_quartus_project.tcl %1
goto done

:parallel
start "Build skl_ball_22" cmd /c "quartus_sh -t %KVB%/backend/build_quartus_project.tcl skl_ball_22 & pause"
start "Build skl_wedge_22" cmd /c "quartus_sh -t %KVB%/backend/build_quartus_project.tcl skl_wedge_22 & pause"
start "Build kbl_ball_22" cmd /c "quartus_sh -t %KVB%/backend/build_quartus_project.tcl kbl_ball_22 & pause"
start "Build skl_ball_75" cmd /c "quartus_sh -t %KVB%/backend/build_quartus_project.tcl skl_ball_75 & pause"
start "Build skl_wedge_75" cmd /c "quartus_sh -t %KVB%/backend/build_quartus_project.tcl skl_wedge_75 & pause"
start "Build kbl_ball_75" cmd /c "quartus_sh -t %KVB%/backend/build_quartus_project.tcl kbl_ball_75 & pause"

timeout /T 3 >nul

:done

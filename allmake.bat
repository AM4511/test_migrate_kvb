@echo off
@rem ---------------------------------------------------------------------------
@rem  COPYRIGHT (C) 2018 BY KULICKE AND SOFFA INDUSTRIES, INC.
@rem  This software is the property of Kulicke and Soffa Industries, Inc.
@rem  Any reproduction or distribution to a third party is
@rem  strictly forbidden unless written permission is given by an
@rem  authorized agent of Kulicke and Soffa.
@rem
@rem  Build script for Host CPU Bridge (4013) design.
@rem
@rem  These tools must be installed on the PC:
@rem    Intel Quartus 17.0 or greater
@rem
@rem  These environment variables must be set:
@rem    HOSTBRIDGE            - Path to 4013 project (use forward slashes)
@rem
@rem  CALLING FORMATS:
@rem    allmake               - Build only what needs to be built.
@rem    allmake clean         - Force build everything from scratch.
@rem    allmake clean_only    - Remove targets and don't re-build anything.
@rem
@rem
@rem  DATE      NAME              CHANGE DESCRIPTION
@rem  --------- ----------------- ----------------------------------------------
@rem  26-Mar-18 D.Rauth           Created
@rem ---------------------------------------------------------------------------
set BUILD_ERROR_FLAG=0


if "%KVB%"=="" (
    set "KVB=%~dp0."
)
if "%1" == "clean" goto clean
if "%1" == "clean_only" goto clean
goto noclean


:clean
del archive\*.* /F /Q
del /f /s /q quartus 1>nul 2>nul
rmdir quartus /S /Q 2>nul
rmdir quartus /S /Q 2>nul
rmdir quartus /S /Q 2>nul
if "%1" == "clean_only" goto done


:noclean
call backend\create_quartus_project
if errorlevel 1 goto build_error

call backend\build_quartus_project
if errorlevel 1 goto build_error

call backend\check_messages
if errorlevel 1 goto build_error

goto done


:build_error
set BUILD_ERROR_FLAG=1


:done


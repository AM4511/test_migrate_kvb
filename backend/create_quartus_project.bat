if exist "%KVB%\quartus" goto done
quartus_sh -t %KVB%/backend/create_quartus_project.tcl

:done

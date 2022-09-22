@echo off
REM Noam 205918360
REM Eviatar 205913858

find/c "SCRIPT" < %1 > saverrlev.txt
set /p exist=<saverrlev.txt
if not %exist%==0 echo yes >> counter.txt
if not %exist%==0 copy %1 %3\*.out > nul
if not %exist%==0 del %1
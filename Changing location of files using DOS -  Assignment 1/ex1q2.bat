REM Noam 205918360
REM Eviatar 205913858

@echo off

>counter.txt
>saverrlev.txt

REM Exception handling
if [%1]==[] goto exception2
if [%2]==[] goto exception2
if not exist %1\nul goto exception1
if not exist %2\nul goto exception1


for %%i in (%1\*.in) do call find1.bat %%i %1 %2
echo The number of files containing "SCRIPT" are:
find /c "yes" < counter.txt

goto end

:exception1
echo The input is incorrect, try agian.
goto end

:exception2
echo Check the method gets names of two folders, and those folders exist.
goto end

:end
del counter.txt
del saverrlev.txt
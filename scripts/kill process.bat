powershell.exe Start-Process "$psHome\powershell.exe" -Verb runAs

@echo off
set /p id="Enter program name to kill: "
echo killing program: %id%
powershell -c stop-process -name %id%
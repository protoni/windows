
@echo off
set /p id="Enter program name to download: "
echo Trying to download program: %id%
powershell.exe -c ("install-package -name %id%")

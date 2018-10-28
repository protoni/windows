;@echo off


;Findstr -rbv ; %0 | powershell -c - 
;goto:sCode

echo Downloading Windows Framework v5.0
invoke-webrequest "https://download.microsoft.com/download/2/C/6/2C6E1B4A-EBE5-48A6-B225-2D2058A9CEFB/Win7AndW2K8R2-KB3134760-x64.msu" -outfile "Win7AndW2K8R2-KB3134760-x64.msu"

echo installing Windows Framework v5.0
wusa Win7AndW2K8R2-KB3134760-x64.msu

;:sCode
;pause & goto :eof
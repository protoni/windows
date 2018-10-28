;@echo off


;Findstr -rbv ; %0 | powershell -c - 
;goto:sCode

$PSVersionTable


echo "OneGet works in management framework > 5.0. current version:"
$PSVersionTable.PSVersion.Major


if($PSVersionTable.PSVersion.Major -eq "5") {echo 'ps version is 5.0'} else {echo 'ps version is not 5.0'}

;:sCode
;pause & goto :eof

;@echo off


;Findstr -rbv ; %0 | powershell -c - 
;goto:sCode

echo Downloading microsoft automation tools
invoke-webrequest "https://download.microsoft.com/download/8/E/9/8E9BBC64-E6F8-457C-9B8D-F6C9A16E6D6A/KB3AIK_EN.iso" -outFile "KB3AIK_EN.iso"

echo Downloading pismo file mounter
invoke-webrequest "http://pismotec.com/download/pfmap-184-win.exe" -outfile "pfmap-184-win.exe"

echo installing pismo file mounter
.\pfmap-184-win.exe

do {
if([System.IO.File]::Exists("C:\Program Files\Pismo File Mount Audit Package\ptiso.exe")) {echo "Found Pismo installation. Continuing..."} else { echo "Can't find Pismo installation"}
Start-Sleep -s 1
}
until([System.IO.File]::Exists("C:\Program Files\Pismo File Mount Audit Package\ptiso.exe"))

pfm.exe mount -m m KB3AIK_EN.iso

cd m:\
.\startCD.exe


;:sCode
;pause & goto :eof
powershell.exe Start-Process "$psHome\powershell.exe" -Verb runAs

powershell -c Set-ExecutionPolicy RemoteSigned
powershell -c ("Get-PackageProvider Chocolatey -Force | Out-Null")


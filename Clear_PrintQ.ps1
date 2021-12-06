# script to delete print queue on server

#if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
#    Start-Process PowerShell.exe -ArgumentList "-NoProfile -FilePath `"$PSCommandPath`"" -Verb RunAs
#    Exit
#}

$server = Read-Host -Prompt 'Enter the server name'

Stop-Service -InputObject $(Get-Service -ComputerName $server -Name Spooler)

# Give time for spooler service to stop before deleting stuff
Start-Sleep -Seconds 2

Remove-Item -Path \\$server\c$\Windows\System32\spool\PRINTERS\*.shd -Verbose
Remove-Item -Path \\$server\c$\Windows\System32\spool\PRINTERS\*.spl -Verbose

# Give time to delete everything before starting spooler service
Start-Sleep -Seconds 2

Start-Service -InputObject $(Get-Service -ComputerName $server -Name Spooler)

pause

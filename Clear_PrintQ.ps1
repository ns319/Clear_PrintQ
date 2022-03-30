# script to clear print queue on supplied host

# elevate to admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process PowerShell.exe -ArgumentList "-NoProfile -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

$HostName = Read-Host -Prompt 'Enter hostname'
Write-Host ""

Stop-Service -InputObject $(Get-Service -ComputerName $HostName -Name Spooler)

# give spooler service time to stop before deleting stuff
Start-Sleep -Seconds 1

# count items, delete everything, then count again and subtract to get how many items deleted
# each job consists of 2 items, so divide by 2 to show how many jobs deleted
$Before = (Get-ChildItem -Path \\$HostName\c$\Windows\System32\spool\PRINTERS).count
$After = (Remove-Item -Path \\$HostName\c$\Windows\System32\spool\PRINTERS\* -Verbose).count
$Total = ($Before - $After)
$Jobs = ($Total / 2)

Write-Host ""
Write-Host "$Total items ($Jobs jobs) deleted."

# wait to make sure we're done deleting everything before starting spooler service
Start-Sleep -Seconds 1

Start-Service -InputObject $(Get-Service -ComputerName $HostName -Name Spooler)

Write-Host ""
Read-Host -Prompt "Press Enter to exit"

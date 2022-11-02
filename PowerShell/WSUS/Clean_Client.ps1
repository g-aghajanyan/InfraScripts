$PCS = ("**","**")

foreach ($PC in $PCS) {
    Invoke-Command -Computer $PC -ScriptBlock {net stop wuauserv}
    Invoke-Command -Computer $PC -ScriptBlock {net stop bits}
    Invoke-Command -Computer $PC -ScriptBlock {Remove-Item "C:\Windows\SoftwareDistribution\*" -Confirm:$false -recurse}
    Invoke-Command -Computer $PC -ScriptBlock {net start wuauserv}
    Invoke-Command -Computer $PC -ScriptBlock {net start bits}
}
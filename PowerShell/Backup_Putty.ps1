# Author: Gevorg A
try {
    Import-Module  $PSScriptRoot\_retention -Force

    $BackUpDir = "$env:USERPROFILE\Documents\Infrastructure\Backups\Putty"
    $retention = 5
    $append = $(Get-Date -Format FileDate)
    $name = "putty_config_$append.reg"
    $nameS = "putty_sessions_$append.reg"
    
    #Export Configs
    reg export HKCU\Software\SimonTatham "$BackUpDir\$name" /y
    reg export HKCU\Software\SimonTatham\PuTTY\Sessions "$BackUpDir\$nameS" /y
    
    Set-Retention -searchdir  $BackUpDir -retention $retention -begining "putty_config_"
    Set-Retention -searchdir  $BackUpDir -retention $retention -begining "putty_sessions_"    
}
catch {
    New-SlackMessageAttachment -Color "danger" `
        -Title 'Infrastructure Backups' `
        -Text "$($MyInvocation.MyCommand.Name) Failed to Run" `
        -AuthorName 'Putty Puckup Failed' `
        -Fallback 'kaboo~m!' |
    New-SlackMessage -Channel 'alerts' `
        -IconEmoji :bomb: |
    Send-SlackMessage -Uri $env:Slack_WebHook
}






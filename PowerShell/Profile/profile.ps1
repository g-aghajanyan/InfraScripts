# Author: Gevorg A 

Invoke-Command -ScriptBlock {Clear-Host}
Write-Host "PS Version: $($PSVersionTable.PSVersion.ToString()) $($PSVersionTable.PSEdition)"


Function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal $identity
    $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}


function prompt {
    $realLASTEXITCODE = $LASTEXITCODE
	$Host.UI.RawUI.ForegroundColor = "White"
    Write-Host "$ENV:USERNAME" -NoNewline -ForegroundColor DarkCyan
	Write-Host "@" -NoNewline -ForegroundColor Gray 
    Write-Host "$ENV:COMPUTERNAME" -NoNewline -ForegroundColor DarkGreen
    if ($null -ne $s) {  # color for PSSessions
        Write-Host " (`$s: " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($s.Name)" -NoNewline -ForegroundColor Yellow
        Write-Host ") " -NoNewline -ForegroundColor DarkGray
    }
    Write-Host " : " -NoNewline -ForegroundColor DarkGray
    Write-Host $($(Get-Location) -replace ($env:USERPROFILE).Replace('\','\\'), "~") -NoNewline 
    Write-Host " : " -NoNewline -ForegroundColor DarkGray
    Write-Host (Get-Date -Format "hh:mm:ss tt") -ForegroundColor Gray
    $global:LASTEXITCODE = $realLASTEXITCODE    
    if (Test-IsAdmin) { return "$ " } else { return "> " }
}


# Title
if (Test-IsAdmin) {
    $host.ui.RawUI.WindowTitle = "Administrator: PS $($PSVersionTable.PSEdition)"
} else {
    $host.ui.RawUI.WindowTitle = "PS $($PSVersionTable.PSEdition)"
}


function rdp () {
	Start-Process $env:windir\system32\mstsc.exe -ArgumentList "/v:$args"
}


function recon {
	Invoke-Command -ScriptBlock {.$PSScriptRoot\profile.ps1}
}

# Custom Modules
Import-Module  $PSScriptRoot\pwgen -Force
Import-Module  $PSScriptRoot\features -Force
Import-Module  $PSScriptRoot\Get-ChildItemColor -Force
# Import-Module  $PSScriptRoot\ADModules -Force -ErrorAction SilentlyContinue
Import-Module  $PSScriptRoot\plink -Force
Import-Module  $PSScriptRoot\bored -Force



# Aliases
Set-Alias -Name pss -Value Enter-PSSession -option AllScope
Set-Alias ls Get-ChildItemColor -option AllScope
Set-Alias -Name grep -Value Enter-PSSession -option AllScope
Set-Alias -Name vi -Value 'C:\Program Files (x86)\vim\vim80\vim.exe'
Set-Alias -Name vim -Value 'C:\Program Files (x86)\vim\vim80\vim.exe'


# PSReadLine
Import-Module PSReadLine

# History
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -MaximumHistoryCount 4000


# vim command line
Set-PSReadlineOption -EditMode vi -BellStyle None


# history substring search
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward


# Tab completion
Set-PSReadlineKeyHandler -Chord 'Shift+Tab' -Function Complete
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

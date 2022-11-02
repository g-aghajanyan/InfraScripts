###########################################################
# Generic Variables
###########################################################
$Updates = Get-WsusUpdate
$Declines = @()
$AutoDeclineTotal = 0
$LogPath = "C:\Scripts\Logs\"
$FileName = "WSUS_Housekeeper_$(Get-Date -Format yyyy).csv"
###########################################################
# Functions
###########################################################
# Create directories if needed
Function New-Directory
{
    Param
    (
        [Parameter(Mandatory=$True,Position=1)]
        [String]$Path
    )
    # If path doesn't already exist, create it
    If (!(Test-Path $Path))
    {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}
###########################################################
# Misc.
###########################################################
New-Directory $LogPath
###########################################################
# Decline filters and stats
###########################################################
$AutoDecline = @()
$AutoDecline += "*ARM64*"
$AutoDecline += "*itanium*"
$AutoDecline += "*Preview*"
ForEach ($Filter in $AutoDecline)
{
    $AutoDeclineTotal = $AutoDeclineTotal + ($Updates | Where {$_.Update.Title -Like $Filter}).Count
    $Declines += $Updates | Where {$_.Update.Title -Like $Filter}
}
$Declines += $Updates | Where {$_.Update.IsSuperseded -eq $True}
# Populate remaining stats
$Statistics = "" | Select "Date","SupersededUpdates","AutoDeclinedUpdates","TotalUpdatesRemoved","ObsoleteComputers","DiskSpaceFreed(GB)"
$Statistics."Date" = (Get-Date -format "yyyy-MM-dd hh:mm:ss tt").ToUpper()
$Statistics."SupersededUpdates" = ($Updates | Where {$_.Update.IsSuperseded -eq $True}).Count
$Statistics."AutoDeclinedUpdates" = $AutoDeclineTotal
$Statistics."TotalUpdatesRemoved" = $Declines.Count
$Statistics."ObsoleteComputers" = (Invoke-WsusServerCleanup -CleanupObsoleteComputers).Split(":")[1]
$Statistics."DiskSpaceFreed(GB)" = [Math]::Round((Invoke-WsusServerCleanup -CleanupUnneededContentFiles).Split(":")[1] /1GB, 2)
$Statistics | Export-Csv $(Join-Path $LogPath $FileName) -NoTypeInfo -Append
# Decline updates
$Declines | Deny-WsusUpdate

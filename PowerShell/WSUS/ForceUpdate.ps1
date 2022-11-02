$log = "$env:WINDIR\Logs\WindowsUpdate\$env:computername.log"

$ErrorActionPreference = "SilentlyContinue"
If ($Error) {
	$Error.Clear()
}
$Today = Get-Date

"Started at $Today" > $log

$UpdateCollection = New-Object -ComObject Microsoft.Update.UpdateColl
$Searcher = New-Object -ComObject Microsoft.Update.Searcher
$Session = New-Object -ComObject Microsoft.Update.Session

Add-Content $log  "Initialising and Checking for Applicable Updates. Please wait ..." 

$Result = $Searcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")

If ($Result.Updates.Count -EQ 0) {
	Add-Content $log  "There are no applicable updates for this computer."
}
Else {
    Add-Content $ReportFile "List of Applicable Updates For This Computer`r"
    For ($Counter = 0; $Counter -LT $Result.Updates.Count; $Counter++) {
		$DisplayCount = $Counter + 1
    		$Update = $Result.Updates.Item($Counter)
		$UpdateTitle = $Update.Title
		Add-Content $ReportFile "`t $DisplayCount -- $UpdateTitle"
	}
	$Counter = 0
	$DisplayCount = 0
    Add-Content $log "`r`n"
    Add-Content $log "Initialising Download of Applicable Updates"
    $Downloader = $Session.CreateUpdateDownloader()
    $UpdatesList = $Result.Updates
    For ($Counter = 0; $Counter -LT $Result.Updates.Count; $Counter++) {
		$UpdateCollection.Add($UpdatesList.Item($Counter)) | Out-Null
		$ShowThis = $UpdatesList.Item($Counter).Title
		$DisplayCount = $Counter + 1
		Add-Content $log "`t $DisplayCount -- Downloading Update $ShowThis `r"
		$Downloader.Updates = $UpdateCollection
		$Track = $Downloader.Download()
		If (($Track.HResult -EQ 0) -AND ($Track.ResultCode -EQ 2)) {
			Add-Content $log "`t Download Status: SUCCESS"
		}
		Else {
			Add-Content $log "`t Download Status: FAILED With Error -- $Error()"
			$Error.Clear()
			Add-content $log "`r"
		}	
	}
	$Counter = 0
	$DisplayCount = 0
    Add-Content $log "Installation of Downloaded Updates"
    $Installer = New-Object -ComObject Microsoft.Update.Installer
	For ($Counter = 0; $Counter -LT $UpdateCollection.Count; $Counter++) {
		$Track = $Null
		$DisplayCount = $Counter + 1
		$WriteThis = $UpdateCollection.Item($Counter).Title
		Add-Content $log "`t $DisplayCount -- Installing Update: $WriteThis"
		$Installer.Updates = $UpdateCollection
		Try {
			$Track = $Installer.Install()
			Add-Content $log "`t Update Installation Status: SUCCESS"
		}
		Catch {
			[System.Exception]
			Add-Content $log "`t Update Installation Status: FAILED With Error -- $Error()"
			$Error.Clear()
			Add-content $log "`r"
		}	
	}
}
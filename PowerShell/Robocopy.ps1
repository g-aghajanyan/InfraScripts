# Source folder
$Source = "\\am\source"
# dest folder
$Destination = "C:\dest2"
# log file
$log = "C:\copylog.txt"
# start synch
$Error.Clear()
$D = Get-Date
"-------------------------------------" | Out-File $Log -Append
"Start at $D " | Out-File $Log -Append
"-------------------------------------" | Out-File $Log -Append
robocopy $Source $Destination /E /v /PURGE	/R:3 /W:30 /UNILOG+:$log
# Switches
# /PURGE	Delete dest files/dirs that no longer exist in source..
# /E	Copies directories and subdirectories, including empty ones.
# /R:n	Number of Retries on failed copies: default 1 million.
# /W:n	Wait time between retries: default is 30 seconds.
$D = Get-Date
"-------------------------------------" | Out-File $Log -Append
"End at $D" | Out-File $Log -Append
"-------------------------------------" | Out-File $Log -Append
"Errors:" | Out-File $Log -Append
"$Error" | Out-File $Log -Append
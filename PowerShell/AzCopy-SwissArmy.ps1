# Author: Gevorg A

#create log files and remove old logs
$log = "D:\DBDownload\scriptlog.txt"
If (Test-Path $log) {Remove-Item $log}
If (Test-Path "D:\DBDownload\success") {Remove-Item "D:\DBDownload\success"}
If (Test-Path "D:\DBDownload\db5netconn.log") {Remove-Item "D:\DBDownload\db5netconn.log"}

#Logging
Function Logging($l) {
    "$(get-date -f `"yyyy/MM/dd hh:mm:ss`"): $l" | Out-File -Append -FilePath $log
}
"---------------Started At---------------" | Out-File -Append -FilePath $log
Get-date | Out-File -Append -FilePath $log
"----------------------------------------" | Out-File -Append -FilePath $log

#Start the Download Loop
$counter = 0
#$DownloadFinished = $false
$SQLJobName = "***"
$FileName = "***" #$args[0]

While (![System.IO.File]::Exists("D:\DBDownload\success")) {
    Start-Sleep 10
    If (Get-Process | Where-Object Name -Like "azcopy") { 
        # monitoring part
        $AZProcess = Get-Process | Where-Object Name -Like "azcopy"
        $netspeed = Get-WmiObject -Class Win32_PerfFormattedData_PerfProc_Process | Where-Object {$_.IDProcess -eq $AZProcess.Id} | Select-Object -Property IOOtherBytesPersec
        If ($netspeed.IOOtherBytesPersec -le 1500000) {
            $counter += 1
            Logging("Current speed: $([math]::round($netspeed.IOOtherBytesPersec / 1000000,2)) MB/s")
            Logging("Counter value: $counter")
        }
        If ($counter -eq 6) {
            TaskKill /F /PID $AZProcess.Id 
            $counter = 0
            Logging("Counter value reached the limit of $($counter) tries")
            Logging("AzCopy Process Was Killed with PID of $($AZProcess.Id)")
            Start-Sleep 30
       }
    } Else {
        If (![System.IO.File]::Exists("D:\DBDownload\success")) {
            Logging("Starting AzCopy.exe")
            Stop-Job -Name "DBCopy" -ErrorAction SilentlyContinue
            # Start AzCopy As Job
            Start-Job -Name "DBCopy" -Argumentlist $log,$FileName {
                $logfile = $args[0]
                $azPath = “C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy\”

                #from ne
                $sourcekey = "Secret"
                $Source = "Secret"

                $StartDBCopy = "/NC:5 /Z:`"D:\DBDownload\journalfolder`" /V:D:\DBDownload\db5netconn.log /Source:$Source /Dest:D:\DBDownload /SourceKey:$sourcekey /Pattern:`"$($args[1])`" -y"
                $status = Start-Process -FilePath "$azPath\AzCopy.exe"  -ArgumentList $StartDBCopy -PassThru -Wait -WindowStyle Hidden #  -RedirectStandardError $logfile
                "$(get-date -f `"yyyy/MM/dd hh:mm:ss`"): AzCopy Process exited with exit code $($status.ExitCode)" | Out-File -Append -FilePath $logfile
                if ($status.ExitCode -eq 0) {
                    New-Item -ItemType File -Name success -Path "D:\DBDownload\"
                    "$(get-date -f `"yyyy/MM/dd hh:mm:ss`"): Success file is created. Process Exited with 0" | Out-File -Append -FilePath $logfile
                }
            }
            Start-Sleep 5
            $newpid = Get-Process | Where-Object Name -Like "azcopy"
            Logging("AzCopy started with PID of $($newpid.Id)")
        }
    }
} 

#Post to slack
Function Slack ($msg) {
    Try {
        $Urltochannel="***"
        $Username="***" 
        $Channel="***"
        $body = @{ text=$msg; channel=$Channel; username=$Username } | ConvertTo-Json
        Invoke-WebRequest -Method Post -Uri $Urltochannel -Body $body
        Logging("Slack message is sent")
    } Catch {
        Logging("Slack Error: $($_.Exception.Message)")
    }
}

Slack("DB Dowload was successfull")


#Kick SQL restore job#
Try {
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')
    $srv = New-Object Microsoft.SqlServer.Management.SMO.Server($Env:COMPUTERNAME)
    $job = $srv.jobserver.jobs["$SQLJobName"] 
    $job.Start()
    Logging("SQL Job Successfully Started")
    Slack("SQL DB Restore job start: SUCCESS")   
} Catch {
    Logging("SQL Job Start Error: $($_.Exception.Message)")
    Slack("SQL DB Restore job start: FAILED")
}

#The END
"----------------Ended At----------------" | Out-File -Append -FilePath $log
Get-date | Out-File -Append -FilePath $log
"----------------------------------------" | Out-File -Append -FilePath $log



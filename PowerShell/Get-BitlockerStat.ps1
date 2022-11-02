
$errors = @()

Function GetStatus($ComputerName)
{
    $results = new-object PSObject[] 0;
	Try
	{
		#Invoke command to remoted computer
		
         $results += Invoke-Command -ComputerName $ComputerName -ScriptBlock { Get-BitLockerVolume |  Where-Object {$_.volumetype -eq "OperatingSystem"} | select ComputerName,MountPoint,VolumeType,ProtectionStatus }  -ErrorAction Stop
       
	}
	Catch 
	{
	    $global:errors = '<tag style="color:red;"> Error: </tag> ' + $_.Exception.Message + "</br>"
	}
        return $results
}


$a = "<style>"
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}"
$a = $a + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}"
$a = $a + "</style>"


$PCarray = get-adcomputer -filter 'name -like"AM*" -and Name -ne "**" -and Name -ne "**"' | ForEach-Object {$_.Name} #change to fit in your enviroment
$status = @()
foreach ($PCname in $PCarray) {    
	$status += GetStatus($PCname)
}

If (@($errors).Count -eq 0){
    $errors += '<tag style="color:green;"> No Errors </tag>' + "</br>"
}


$status | select ComputerName,MountPoint,VolumeType,ProtectionStatus  | ConvertTo-HTML -head $a -PostContent $errors | Out-File C:\Scripts\Bitlockerreport.html

$From = "BitLockerStatus@**.com"
$To = "**@**.com"
$Sub = "BitLocker Report"
$Smtpsrv = "***"
$mBody = Get-Content -Path C:\Scripts\Bitlockerreport.html -Raw
Send-MailMessage -From $From -To $To -Subject $Sub -Body $mBody -BodyAsHtml -SmtpServer $SmtpSrv
Remove-Item "c:\scripts\Bitlockerreport.html"
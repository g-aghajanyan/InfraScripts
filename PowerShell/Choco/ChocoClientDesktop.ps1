New-Item -ItemType Directory C:\temp -ErrorAction SilentlyContinue
Remove-Item C:\temp\chocolog.txt -ErrorAction SilentlyContinue
Start-Transcript -path C:\temp\chocolog.txt 

#choco source remove -n=chocolatey
#choco source add -n=praemium -s"**"


#install Mendatory

foreach ($app in Get-Content "\\**\NETLOGON\Choco\Desktop_choco_install.txt") {
    choco install -y $app	
}
foreach ($app in Get-Content "\\**\NETLOGON\Choco\Desktop_choco_install.txt") {
    choco install -y -f $app	
}
foreach ($app in Get-Content "\\**\NETLOGON\Choco\Desktop_choco_uninstall.txt") {
    choco uninstall -y $app	
}
#Upgrade All

Stop-Transcript

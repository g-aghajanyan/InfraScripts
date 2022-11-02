# Author: Gevorg A
Function wttr {
	curl https://wttr.in/evn?FAQ
}
Function moon {
	curl wttr.in/moon
}
Function ipinfo {
	$info = $(curl --silent ipinfo.io) | ConvertFrom-Json
	Write-Output $info 
}
function hah {
	$joke = $(curl --silent -H "Accept: application/json" https://icanhazdadjoke.com/) | ConvertFrom-Json
	Write-Output $joke.joke 
}
function elevate {
	Start-Process pwsh -ArgumentList "-wd $($pwd.Path)"-verb runas
}

Export-ModuleMember -Function 'elevate'
Export-ModuleMember -Function 'wttr'
Export-ModuleMember -Function 'moon'
Export-ModuleMember -Function 'ipinfo'
Export-ModuleMember -Function 'hah'

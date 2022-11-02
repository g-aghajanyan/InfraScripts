# Author: Gevorg A

Add-Type @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            ServicePointManager.ServerCertificateValidationCallback += 
                delegate
                (
                    Object obj, 
                    X509Certificate certificate, 
                    X509Chain chain, 
                    SslPolicyErrors errors
                )
                {
                    return true;
                };
        }
    }
"@
[ServerCertificateValidationCallback]::Ignore();


# Base Paremeters
$baseurl = '***'
$site = '***'
$user = "***"
$psswd = "***"
$GuestWiFi = "***"


# login
$logindata = @{"username"=$user; "password"=$psswd} | ConvertTo-Json
$loginurl = $baseurl + "/api/login"
Invoke-WebRequest -Uri $loginurl -Method Post -Body $logindata -ContentType "application/json" -SessionVariable Session
If($?) { "LOGIN SUCCESS" } Else { "LOGIN FAILED"; break }

#GetClientData
$clientdaturl = $baseurl + "/api/s/" + $site + "/stat/sta"
$GetClientData = Invoke-WebRequest -Uri $clientdaturl -WebSession $Session -Method Post
$GetClientDataobj = $GetClientData.Content | ConvertFrom-JSON

#GetNetConf
$neturl = $baseurl + "/api/s/" + $site + "/rest/networkconf"
$Getnetconf = Invoke-WebRequest -Uri $neturl -WebSession $Session
$Getnetconfobj = $Getnetconf.Content | ConvertFrom-JSON

#Get PVID BY Network ID 
Function GetPVID($netID) {
    $status = $Getnetconfobj.data | Where-Object {$_._id -eq $netID} | Select-Object vlan 
    $status.vlan
}

#Get Computer Description

Function GetUsername($ID) {
    $usernamebyid = Get-ADComputer -Filter 'Name -Like $ID' -Properties Description
    $usernamebyid.Description
}

#Represent Results
$GetClientDataobj.data | where-object {$_.network -ne $GuestWiFi} | 
Select-Object hostname,
   @{Label="Description"; Expression={GetUsername($_.hostname)}},
   @{Label="IP Address"; Expression={$_.ip}},
   @{Label="VLAN Name"; Expression={$_.network}},
   @{Label="PVID"; Expression={GetPVID($_.network_id)}},
   #SwitchName optional
   @{Label="SWPort ID"; Expression={$_.sw_port}},
   @{Label="Medium Type"; Expression={IF($_.is_wired){"Ethernet"} else {"WIFI"}}},
   @{Label="NIC Vendor"; Expression={$_.oui}},
   @{Label="MAC Address"; Expression={$_.mac}} | Out-GridView
   
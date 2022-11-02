﻿Function Get-LockingProcess {

    [cmdletbinding()]
    Param(
        [Parameter(Position=0, Mandatory=$True,
        HelpMessage="What is the path or filename? You can enter a partial name without wildcards")]
        [Alias("name")]
        [ValidateNotNullorEmpty()]
        [string]$Path
    )

    # Define the path to Handle.exe
    # //$Handle = "G:\Sysinternals\handle.exe"
    $Handle = "Execs\handle.exe"

    # //[regex]$matchPattern = "(?<Name>\w+\.\w+)\s+pid:\s+(?<PID>\b(\d+)\b)\s+type:\s+(?<Type>\w+)\s+\w+:\s+(?<Path>.*)"
    # //[regex]$matchPattern = "(?<Name>\w+\.\w+)\s+pid:\s+(?<PID>\d+)\s+type:\s+(?<Type>\w+)\s+\w+:\s+(?<Path>.*)"
    [regex]$matchPattern = "(?<Name>\w+\.\w+)\s+pid:\s+(?<PID>\d+)\s+type:\s+(?<Type>\w+)\s+(?<User>\S+)\s+\w+:\s+(?<Path>.*)"

    $data = &$handle -u $path
    $MyMatches = $matchPattern.Matches( $data )

    # //if ($MyMatches.value) {
    if ($MyMatches.count) {
        $MyMatches | ForEach-Object {
            [pscustomobject]@{
                FullName = $_.groups["Name"].value
                Name = $_.groups["Name"].value.split(".")[0]
                ID = $_.groups["PID"].value
                Type = $_.groups["Type"].value
                User = $_.groups["User"].value
                Path = $_.groups["Path"].value
                toString = "pid: $($_.groups["PID"].value), user: $($_.groups["User"].value), image: $($_.groups["Name"].value)"
            } #hashtable
        } #foreach
    } #if data
    else {
        Write-Warning "No matching handles found"
    }
} #end function
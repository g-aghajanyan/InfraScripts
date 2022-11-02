function Test-FileLock {
    ## Attempts to open a file and trap the resulting error if the file is already open/locked
    param ([string]$filePath )
    $filelocked = $false
    $fileInfo = New-Object System.IO.FileInfo $filePath
    trap {
        Set-Variable -name filelocked -value $true -scope 1
        continue
    }
    $fileStream = $fileInfo.Open( [System.IO.FileMode]::OpenOrCreate,[System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None )
    if ($fileStream) {
        $fileStream.Close()
    }
    $obj = New-Object Object
    $obj | Add-Member Noteproperty FilePath -value $filePath
    $obj | Add-Member Noteproperty IsLocked -value $filelocked
    $obj
}
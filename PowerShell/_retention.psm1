
function Set-Retention($searchdir, $retention, $begining) {
    try {
        $content = Get-ChildItem $searchdir -Filter "$begining*" | Sort-Object -Property LastWriteTimeUtc
        if ($content.Count -gt 1) {
            $hashSrc = Get-FileHash $content[-2].FullName -Algorithm SHA256
            $hashDest = Get-FileHash $content[-1].FullName -Algorithm SHA256
            
            if ($hashSrc.Hash -ne $hashDest.Hash) {
                if ($content.Count -gt $retention) {
                    Remove-Item $content[0]
                    return "rm_first"
                }
            }
            else {
                Remove-Item $content[-1]
                return "rm_last"
            }
        }
        else {
            return "le_1"
        }
    }
    catch {
        return $false
    }
}

Export-ModuleMember -Function 'Set-Retention'
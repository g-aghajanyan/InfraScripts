# Author: Gevorg A
#slack everything
$basePathforOLD = "C:\Users\gevorg.aghajanyan\Documents\TEST Files"
$basePathforNEW = "C:\Users\gevorg.aghajanyan\Documents\TEST Files\new"
$newfilenames = Get-ChildItem -Name -Path $basePathforNEW -filter "*.csv" | sort-object 
$oldfilenames = Get-ChildItem -Name -Path $basePathforOLD -filter "*.csv" | sort-object 

#Output
$outdir = "C:\Users\gevorg.aghajanyan\Documents\TEST Files\diff"

#break if no old files are found OR if  old and new file count is different
if($oldfilenames.count -eq 0) {break;}
if(!($newfilenames.count -eq $oldfilenames.count)) {break;}

#main 
foreach ($i in 0..($newfilenames.Count - 1)) {
    write-host $oldfilenames[$i] $newfilenames[$i]
    #Read Files
    $filenameold = $oldfilenames[$i]
    $filenamenew = $newfilenames[$i]
    #BREAK and REPORT if old and new file names not like each other
    if (!($filenameold.split("{_}")[-1] -match $filenamenew.split("{_}")[-1])) {break;}
    $old = import-csv -Delimiter "`t" -Path $basePathforOLD\$filenameold 
    $new = import-csv -Delimiter "`t" -Path $basePathforNEW\$filenamenew
    #compare
    $properties = $new | get-member -MemberType NoteProperty
    $comp = Compare-Object -ReferenceObject $old -DifferenceObject $new -CaseSensitive -PassThru -Property $properties.name
    #export
    $diff = @()
    $indicators = @()
    foreach($line in $comp) {
        $indicators += $line.sideindicator
        If( $line.sideindicator -eq "=>" ) {
            $line.PSObject.Properties.Remove('SideIndicator')
            $diff += $line
        }
    }
    $noEmptyFileAllowed = $false
    $indicators
    if (!($indicators -contains "=>")) { $noEmptyFileAllowed = $true; "a" } else {"b"}
    if (!$comp) { 
        $noEmptyFileAllowed = $true
    }
    #If no diff, we still need at least one record for Biztalk app not to crash
    If ($noEmptyFileAllowed) {
        $diff = Compare-Object -ReferenceObject $old[0] -DifferenceObject $new[0]  -CaseSensitive -PassThru -IncludeEqual
        $diff.PSObject.Properties.Remove('SideIndicator')
    }
    $diff | ConvertTo-Csv -Delimiter "`t" -NoTypeInformation | ForEach-Object {$_.Replace('"','')} | Out-File  $outdir\Diff_$filenamenew
    #Slack Names and Diff
}

#move new file to old files
#Slack About success


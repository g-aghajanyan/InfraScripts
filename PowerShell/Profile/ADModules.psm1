# Author: Gevorg A
Class ComputerNames : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $ComputerNames = ForEach ($computer in $(Get-ADComputer -Filter *)) {$computer.Name}
        return [String[]] $ComputerNames
    }
}
Function whosepc { 
    param (
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        HelpMessage="Enter one or more computer names separated by commas.")]
        [string[]]
        [ValidateSet([ComputerNames])]
        $ComputerName
    )
    foreach ($cn in $ComputerName) {
        try {
            $desc = Get-ADComputer -Properties Description -Identity "$cn"
            Write-Host "$cn" -ForegroundColor Yellow -NoNewline
            Write-Host "`tBelongs to: " -NoNewline
            Write-Host $desc.Description -ForegroundColor Green -NoNewline
            Write-Host "`tDepartment: " -NoNewline
            Write-Host $($desc.DistinguishedName.Split(',')[1].split('=')[1]) -ForegroundColor Green
        } catch {
            Write-Host "$cn Does not Exist: Check the spelling" -ForegroundColor red
        }
    }
}
Export-ModuleMember -Function 'whosepc'
# Author: Gevorg A
Class sessions : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $sessions =  $(Get-ChildItem -Path HKCU:\Software\SimonTatham\PuTTY\Sessions\ | Select-Object PSChildName).PSChildName
        return [String[]] $sessions
    }
}
Function term { 
    param (
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        HelpMessage="Enter SSH Sessin Name.")]
        [string[]]
        [ValidateSet([sessions])]
        $session
    )
    # plink -load $session
    putty -load $session
}
Export-ModuleMember -Function 'term'
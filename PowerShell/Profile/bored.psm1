# Author: Gevorg A
Class types : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $types =  @("education", "recreational", "social", "diy", "charity", "cooking", "relaxation", "music", "busywork")
        return [String[]] $types
    }
}
Function bored { 
    param (
        [Parameter(Mandatory=$false,
        ValueFromPipeline=$true,
        HelpMessage="Enter Type/Category.")]
        [string[]]
        [ValidateSet([types])]
        $type
    )
    if ($type) {
        $(curl --silent http://www.boredapi.com/api/activity?type=$type) | ConvertFrom-Json | Format-List -Property activity, type, participants, accessibility 
    } else {
        $(curl --silent http://www.boredapi.com/api/activity/) | ConvertFrom-Json | Format-List -Property activity, type, participants, accessibility 
    }
}
Export-ModuleMember -Function 'bored'
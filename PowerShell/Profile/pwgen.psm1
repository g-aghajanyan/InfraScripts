# Author: Gevorg A
Function pwgen {
	Param(
        [int]$lenght = 10
    )

	$symbols = 5*$lenght
	$SafeSymbols = 25*$lenght
	$nosymbols = 5*$lenght

	$UnsafeSymbols = 34,39,42,44,46,96
	$EliminateSymbols = 33..47 + 58..64 + 91..96

	$Psswd = "`n"

	for ($i=0; $i -lt $symbols) {
		$Psswd += [char][byte]$(Get-Random(33..122))
		$i++
		if ( $i % $lenght -eq 0  ) { $Psswd += "`t" } if ( $i % (5*$lenght) -eq 0  ) { $Psswd += "`n" }  
	}
	for ($i=0; $i -lt $SafeSymbols) {
		if ($randnum = Get-Random(33..122) | Where-Object {$_ -notin $UnsafeSymbols }) {
			$Psswd += [char][byte]$randnum
			$i++
			if ( $i % $lenght -eq 0  ) { $Psswd += "`t" } if ( $i % (5*$lenght) -eq 0  ) { $Psswd += "`n" }  
		}
	}
	for ($i=0; $i -lt $nosymbols) {
		if ($randnum = Get-Random(33..122) | Where-Object {$_ -notin $EliminateSymbols }) {
			$Psswd += [char][byte]$randnum
			$i++
			if ( $i % $lenght -eq 0  ) { $Psswd += "`t" } if ( $i % (5*$lenght) -eq 0  ) { $Psswd += "`n" }  
		}
	} 
	Write-Host $Psswd
}
 
Export-ModuleMember -Function 'pwgen'
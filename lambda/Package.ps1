Param(
	[string[]]
	$FunctionNames = @("update_route53")
)

Add-Type -Assembly System.IO.Compression.FileSystem

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

$FunctionNames | ForEach-Object {
	if (Test-Path $scriptPath\$_.zip) {
		Remove-Item -Force $scriptPath\$_.zip | Out-Null
	}

	$cache = Get-Location
	try {
		Set-Location $scriptPath\$_
		
		& npm install --production
	} finally {
		Set-Location $cache
	}

	[System.IO.Compression.ZipFile]::CreateFromDirectory("$scriptPath\$_", "$scriptPath\$_.zip")
}
# Parameter
$RequireSignature = $true # Every powershell scripts needs a signature
$CheckForSigErrors = $true # Check powershell scripts for signature errors
$RequireTimestamp = $true # Does the powershell script need a timestamp signature

$rootDirectory = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "\..\..\" -Resolve
$PowershellScripts = Get-ChildItem -Path $rootDirectory -Recurse -Filter "*.ps1" -File

$errSwitch = $false

foreach ($psscript in $PowershellScripts) {
    $sig = Get-AuthenticodeSignature $psscript.FullName
    if (($sig.Status -ne "Valid") -and $RequireSignature) {
        $errSwitch = $true
        Write-Output "Signature on file: $($psscript.FullName.Replace($rootDirectory, '.\')) is not valid. Status: $($sig.Status)"
    }
    if (-not (($sig.Status -eq "Valid") -xor ($sig.Status -eq "NotSigned")) -and $CheckForSigErrors) {
        $errSwitch = $true
        Write-Output "Signature on file: $($psscript.FullName.Replace($rootDirectory, '.\')) is signed but faulty. Status: $($sig.Status)"
    }
    if ($sig -and (!$sig.TimeStamperCertificate -and $RequireSignature)) {
        $errSwitch = $true
        Write-Output "Signature on file: $($psscript.FullName.Replace($rootDirectory, '.\')) has no timestamp certificate."
    }
}

if ($errSwitch) {
    EXIT 1
}
else {
    EXIT 0
}

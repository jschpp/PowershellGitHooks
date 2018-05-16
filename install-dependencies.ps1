# Taken from https://github.com/tlindsay42/ArmorPowerShell/blob/master/build/Install-Dependencies.ps1
# Licensed under Apache 2.0: https://github.com/tlindsay42/ArmorPowerShell/blob/master/LICENSE.txt
# Copyright = '(c) 2017-2018 Troy Lindsay. All rights reserved.'


Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted'

Write-Host -Object "`nInstalling package providers:" -ForegroundColor 'Yellow'
$providerNames = 'NuGet', 'PowerShellGet'
foreach ( $providerName in $providerNames ) {
    if ( -not ( Get-PackageProvider $providerName -ErrorAction 'SilentlyContinue' ) ) {
        Install-PackageProvider -Name $providerName -Scope 'CurrentUser' -Force -ForceBootstrap
    }
}
Remove-Variable -Name 'providerName'

Get-PackageProvider -Name $providerNames |
    Format-Table -AutoSize -Property 'Name', 'Version'

Write-Host -Object "Installing modules:" -ForegroundColor 'Yellow'
$moduleNames = 'Pester', 'PSScriptAnalyzer'
foreach ( $moduleName in $moduleNames ) {
    Install-Module -Name $moduleName -Scope 'CurrentUser' -Repository 'PSGallery' -SkipPublisherCheck -Force -Confirm:$false |`
        Out-Null
    Import-Module -Name $moduleName
}
Remove-Variable -Name 'moduleName'

Get-Module -Name $moduleNames |
    Format-Table -AutoSize -Property 'Name', 'Version'

Write-Host -Object ''

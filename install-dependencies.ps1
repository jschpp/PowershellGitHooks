﻿# Taken from https://github.com/tlindsay42/ArmorPowerShell/blob/master/build/Install-Dependencies.ps1
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
$moduleNames = 'Pester', 'Coveralls'
foreach ( $moduleName in $moduleNames ) {
    if ( $env:APPVEYOR_BUILD_WORKER_IMAGE -eq 'Visual Studio 2015' ) {
        Install-Module -Name $moduleName -Scope 'CurrentUser' -Repository 'PSGallery' -Force -Confirm:$false |
            Out-Null
    }
    else {
        Install-Module -Name $moduleName -Scope 'CurrentUser' -Repository 'PSGallery' -SkipPublisherCheck -Force -Confirm:$false |
            Out-Null
    }

    Import-Module -Name $moduleName
}
Remove-Variable -Name 'moduleName'

Get-Module -Name $moduleNames |
    Format-Table -AutoSize -Property 'Name', 'Version'

Write-Host -Object 'NodeJS version: ' -ForegroundColor 'Yellow' -NoNewline
& node --version
Write-Host -Object 'NodeJS Package Manager (npm) version: ' -ForegroundColor 'Yellow' -NoNewline
& npm --version

Write-Host -Object "`nInstalling npm packages: " -ForegroundColor 'Yellow'
& npm install --global sinon@1 markdown-spellcheck 2> ( [System.IO.Path]::GetTempFileName() )

Write-Host -Object ''

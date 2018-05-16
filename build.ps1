# Turn off Invoke-Expression Warning
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "")]

param(
    [string[]]$Tasks
)

function Invoke-AnalyzeScript {
    param(
        [string]$Path = "$PSScriptRoot\src\"
    )
    $result = Invoke-ScriptAnalyzer -Path $Path -Recurse -Severity "Error", "Warning" -ErrorAction Stop
    if ($result) {
        $result | Format-Table
        Write-Error -Message "$($result.SuggestedCorrections.Count) linting errors or warnings were found. The build cannot continue."
        EXIT 1
    }
}

function Invoke-Test {
    param(
        [string]$Path = "$PSScriptRoot\tests"
    )

    $results = Invoke-Pester -Path $Path -CodeCoverage $Path\..\*\*.psm1 -PassThru
    if ($results.FailedCount -gt 0) {
        Write-Output "  > $($results.FailedCount) tests failed. The build cannot continue."
        foreach ($result in $($results.TestResult | Where-Object {$_.Passed -eq $false} | Select-Object -Property Describe, Context, Name, Passed, Time)) {
            Write-Output "    > $result"
        }

        EXIT 1
    }
    $coverage = [math]::Round($(100 - (($results.CodeCoverage.NumberOfCommandsMissed / $results.CodeCoverage.NumberOfCommandsAnalyzed) * 100)), 2);
    Write-Output "  > Code Coverage: $coverage%"
}

function Invoke-BuildProcess {
    param(
        [string]$Path = "$PSScriptRoot\src",
        [string]$Version = "0.0.0"
    )

    # nuget
    $specpath = Join-Path $Path "PowershellGitHooks.nuspec"
    $outpath = Join-Path $PSScriptRoot "bin"
    $command = "& `'C:\Program Files (x86)\nuget\NuGet.exe`' pack `"$specpath`" -Basepath `"$Path`" -outputdirectory `"$outpath`" -Version `"$Version`""
    Write-Output $command
    Invoke-Expression $command

    # Test if package file exists
    if (! $(Test-Path $(Join-Path $outpath "Uni-Frankfurt.PSIdent.$Version.nupkg"))) {
        Write-Error "Build was unsuccessful!" -ErrorAction Stop
    }
}

function Get-GitCommitMessage {
    git log -1 --pretty=%B
}

foreach ($task in $Tasks) {
    $module = Test-ModuleManifest $(Join-Path $PSScriptRoot "src\PowershellGitHooks.psd1")
    if (! $?) {
        Write-Output "Error in Module Manifest"
        EXIT 1
    }
    try {
        switch ($task) {
            "analyze" {
                Write-Output "Analyzing Scripts..."
                Invoke-AnalyzeScript
            }
            "test" {
                Write-Output "Running Tests..."
                Invoke-Test
            }
            "release" {
                Write-Output "Building Package..."
                Invoke-BuildProcess -Version $module.Version
            }
        }
    }
    catch {
        EXIT 1
    }
}

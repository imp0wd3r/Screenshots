Param(
    [string]$Targets,
    [string]$Result
)

function New-SplitFiles {
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory=$False)]
        [string]$FileToSplit = $(Read-Host -Prompt "Please enter the full path of the file you need to split."),

        [Parameter(Mandatory=$False)]
        [string]$OutputDirectory = $FileToSplit,

        [Parameter(Mandatory=$False)]
        [int]$LineNumberToSplitOn
    )

    ### BEGIN Parameter Validation ###

    if (!$(Test-Path $FileToSplit)) {
        Write-Error "The path $FileToSplit was not found! Halting!"
        $global:FunctionResult = "1"
        return
    }
    if ($(Get-Item $OutputDirectory) -isnot [System.IO.DirectoryInfo]) {
        Write-Error "The path $OutputDirectory is not a directory! Halting!"
        $global:FunctionResult = "1"
        return
    }

    ### END Parameter Validation ###

    ### BEGIN MAIN Body ###

    $file = Get-Item $FileToSplit
    $FilesCreatedColection = @()
    $FileContent = Get-Content $(Get-Item $file.FullName)
    $LineCount = $FileContent.Count
    $TotalNumberOfSplitFiles = [math]::ceiling($($LineCount / $LineNumberToSplitOn))

    if ($TotalNumberOfSplitFiles -gt 1) {
        for ($i = 1; $i -lt $($TotalNumberOfSplitFiles + 1); $i++) {
            $StartingLine = $LineNumberToSplitOn * $($i - 1)
            if ($LineCount -lt $($LineNumberToSplitOn * $i)) {
                $EndingLine = $LineCount
            }
            if ($LineCount -gt $($LineNumberToSplitOn * $i)) {
                $EndingLine = $LineNumberToSplitOn * $i
            }

            New-Variable -Name "$($file.BaseName)_Part$i" -Value $(
                $FileContent[$StartingLine..$EndingLine]
            ) -Force

            $(Get-Variable -Name "$($file.BaseName)_Part$i" -ValueOnly) | Out-File "$OutputDirectory\$($file.BaseName)_Part$i$($file.Extension)"

            $FilesCreatedCollection += , $(Get-Variable -Name "$($file.BaseName)_Part$i" -ValueOnly)
        }
    }
}

$PWD = Get-Location

$TargetsDirectory = "$env:TEMP\targets"
if (!(Test-Path $TargetsDirectory)) {
    New-Item -ItemType Directory -Path $TargetsDirectory
}
Set-Location $TargetsDirectory
Remove-Item *_Part*
New-SplitFiles -FileToSplit $Targets -LineNumberToSplitOn 5 -OutputDirectory $TargetsDirectory

$ResultDirectory = "$PWD\$Result"
if (!(Test-Path $ResultDirectory)) {
    New-Item -ItemType Directory -Path $ResultDirectory
}
Set-Location $ResultDirectory
Remove-Item *.png

$ScriptPath = "$PWD\screenshot.js"
Get-ChildItem $TargetsDirectory | ForEach-Object {
    "Processing $($_.FullName)"
    & "$PWD\dos2unix\bin\dos2unix.exe" $_.FullName
    node $ScriptPath $_.FullName $ResultDirectory
}

Remove-Item $env:TEMP\puppeteer_dev_profile-* -Recurse
Set-Location $PWD
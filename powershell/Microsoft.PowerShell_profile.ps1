# This Powerhell-Profile is originally made by Marius Kehl (github.com/MeroFuruya)

# tools used:
# - git
# - npm
# - GitHub-cli
# - notepad++
# - oh-my-posh
# - wsl2
# - ntop

# Powershell-Modules used:
# - posh-git
# - npm-completion
# - updated PSReadline -> "Install-Module -Force PSReadLine"

## THEME

# oh-my-posh
Invoke-Expression -Command $(oh-my-posh completion powershell | Out-String)
oh-my-posh --init --shell pwsh --config "$env:POSH_THEMES_PATH/multiverse-neon.omp.json" | Invoke-Expression
Set-PSReadlineOption -ExtraPromptLineCount 2 # count of lines for oh-my-posh

## PSReadline

# Autocompletion
Set-PSReadlineKeyHandler -Key Tab -Function Complete
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

# PSReadline
Set-PSReadlineOption -PredictionSource History
Set-PSReadlineOption -PredictionViewStyle Inline
Set-PSReadlineOption -WordDelimiters " ./\`"(){}[]&;|_^@'-"
Set-PSReadlineOption -BellStyle None
Set-PSReadlineOption -CommandValidationHandler { $true }
Set-PSReadlineOption -ShowToolTips
Set-PSReadlineOption -HistorySaveStyle SaveIncrementally

## AUTOCOMPLETION

# github autocomplete
Invoke-Expression -Command $(gh completion -s powershell | Out-String)

# Git autocomplete
$global:GitPromptSettings = $false
Import-Module posh-git

# npm autocomplete
Import-Module npm-completion

# aws autocomplete
Register-ArgumentCompleter -Native -CommandName aws -ScriptBlock {
  param($commandName, $wordToComplete, $cursorPosition)
  $env:COMP_LINE=$wordToComplete
  if ($env:COMP_LINE.Length -lt $cursorPosition){
    $env:COMP_LINE=$env:COMP_LINE + " "
  }
  $env:COMP_POINT=$cursorPosition
  aws_completer.exe | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
  Remove-Item Env:\COMP_LINE
  Remove-Item Env:\COMP_POINT
}

## ALIASES

# git alias
New-Alias -Name g -Value git

# open root posh
Function _root {
  Invoke-Expression -Command "start-process powershell -verb runas"
}
New-Alias -Name root -Value _root

# exit with q
Function _q { exit }
New-Alias -Name q -Value _q

# clear screen
New-Alias -Name c -Value Clear-Host

# copy current location
Function _cc { (Get-Location).Path | Set-Clipboard }
New-Alias -Name cc -Value _cc

# copy current location as cd command
Function _ccd { "cd $((Get-Location).Path)" | Set-Clipboard }
New-Alias -Name ccd -Value _ccd

# pwd only print path
Function _pwd { Write-Host "$((Get-Location).Path)" }
New-Alias -Name pwd -Value pwd -Force -Option AllScope

# cd into ~/Documents/GitHub
Function _cdgh { Set-Location "~/Documents/GitHub/" }
New-Alias -Name cdgh -Value _cdgh

# notepad++
New-Alias -Name npp -Value "C:\Program Files\Notepad++\notepad++.exe"

# ntop -> top
New-Alias -Name top -Value ntop

# ConvertFrom-Json -> json
New-Alias -Name json -Value ConvertFrom-Json

## WSL ALIASES

# The commands to import.
$wslCommands = "awk", "grep", "head", "man", "sed", "seq", "ssh", "tail", "vim", "lsd", "mc", "nano", "sudo", "cat", "sh", "bat", "less"

# stolen from that article: https://devblogs.microsoft.com/commandline/integrate-linux-commands-into-windows-with-powershell-and-the-windows-subsystem-for-linux/
# Register a function for each command.
$wslCommands | ForEach-Object { Invoke-Expression @"
Remove-Item Alias:$_ -Force -ErrorAction Ignore
function global:$_() {
    for (`$i = 0; `$i -lt `$args.Count; `$i++) {
        # If a path is absolute with a qualifier (e.g. C:), run it through wslpath to map it to the appropriate mount point.
        if (Split-Path `$args[`$i] -IsAbsolute -ErrorAction Ignore) {
            `$args[`$i] = Format-WslArgument (wsl.exe wslpath (`$args[`$i] -replace "\\", "/"))
        # If a path is relative, the current working directory will be translated to an appropriate mount point, so just format it.
        } elseif (Test-Path `$args[`$i] -ErrorAction Ignore) {
            `$args[`$i] = Format-WslArgument (`$args[`$i] -replace "\\", "/")
        }
    }

    if (`$input.MoveNext()) {
        `$input.Reset()
        `$input | wsl.exe $_ (`$args -split ' ')
    } else {
        wsl.exe $_ (`$args -split ' ')
    }
}
"@
}

# Helper function to escape characters in arguments passed to WSL that would otherwise be misinterpreted.
function global:Format-WslArgument([string]$arg, [bool]$interactive) {
  if ($interactive -and $arg.Contains(" ")) {
    return "'$arg'"
  }
  else {
    return ($arg -replace " ", "\ ") -replace "([()|])", ('\$1', '`$1')[$interactive]
  }
}

# less wsl fix
Function Out-WSLless {
  if ($input.MoveNext()) {
    $input.Reset()
    $lessGUID = (New-Guid)
    $input | Out-String -Stream | wsl -e bash -c "cat > /tmp/pager.$lessGUID"
    Invoke-Expression "global:less $args /tmp/pager.$lessGUID"
    wsl -e bash -c "rm /tmp/pager.$lessGUID"
  }
  else {
    Invoke-Expression "global:less $args"
  }
}
New-Alias -Name less -Value Out-WSLless

## FUN :)

# thx
Function thx {
  Write-Host "ur welcome :)"
}

# be gender neutral
New-Alias -Name person -Value man
New-Alias -name human -Value man

# ls -> lsd alias
Remove-Item Alias:ls -Force -ErrorAction Ignore
New-Alias -Name ls -Value lsd -Force -Option AllScope

## FUNCTIONS

# convert encoding
Function Convert-Encoding {
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet("UTF8", "UTF7", "UTF32", "ASCII", "Unicode", "BigEndianUnicode", "Default", "OEM", "UTF8NoBOM", "UTF8BOM", "UTF7NoBOM", "UTF7BOM", "UTF32NoBOM", "UTF32BOM")]
    [string]$Encoding,
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$Path
  )
  $files = Get-ChildItem -Path $Path -Recurse -File
  foreach ($file in $files) {
    $text = Get-Content $file
    Set-Content -Encoding $Encoding -Force -Path $file -Value $text
  }
}

b# This Powerhell-Profile is originally made by Marius Kehl (github.com/MeroFuruya)

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
oh-my-posh --init --shell pwsh --config "$env:POSH_THEMES_PATH/catppuccin_frappe.omp.json" | Invoke-Expression
Set-PSReadlineOption -ExtraPromptLineCount 1 # count of lines for oh-my-posh

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
if (Get-Command aws_completer.exe -ErrorAction SilentlyContinue) {
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

# ForEach-Object -> fe
New-Alias -Name fe -Value ForEach-Object

## WSL ALIASES

# The commands to import.
$wslCommands = @(
  "awk", "grep", "head", "man",
  "sed", "seq", "ssh", "tail",
  "vim", "lsd", "mc", "nano",
  "sudo", "cat", "sh", "bat",
  "less", "bash"
)

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
        `$inputFile = "/tmp/wslPipe.`$(New-Guid)"
        `$input | Out-String -Stream | wsl -e bash -c "cat > `$inputFile"
        wsl.exe -e bash -c "cat `$inputFile | $_ `$(`$args -split ' ') && rm `$inputFile"
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

# be gender neutral
New-Alias -Name person -Value man
New-Alias -name human -Value man

## FUN :)

# thx
Function thx {
  Write-Host "ur welcome :)"
}

## FUNCTIONS

# update profile
Function Update-Profile {
  Invoke-WebRequest -Uri https://raw.githubusercontent.com/MeroFuruya/dotfiles/main/powershell/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
  Write-Host "New Profile is Downloaded. Will be available on next restart of PowerShell :)"
}

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

Function Update-wslLsd {
  if (-not(Get-Command aws_completer.exe -ErrorAction SilentlyContinue)) {
    throw "You dont have GitHub-cli installed. This is necessary for this Action"
  }
  gh auth status -h github.com -t > Out-Null
  if ($LASTEXITCODE -ne 0) {
    throw "make sure you are logged into GitHub, use ""gh auth login"" to do so!"
  }
  (gh api $($urls = @();$page=1;while($urls.Length -eq 0){(gh api repos/lsd-rs/lsd/actions/artifacts?page=$page|ConvertFrom-Json).artifacts|ForEach-Object{if($_.name -eq "lsd-x86_64-unknown-linux-gnu"){$urls=$urls+,$_.archive_download_url}};$page++};$urls[0]))|wsl -e bash -c "cat > /bin/lsd"
}

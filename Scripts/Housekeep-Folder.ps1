<#
    .SYNOPSIS
        Housekeep a folder by deleting files and empty folders more than X days old
   
    .DESCRIPTION
        Function to check the last modified timestamp of all files within a folder and delete files that are more than X days old

    .SYNTAX
        Housekeep-Folder [-Path] <System.String[]> [-Days] <System.Integer> [-IncludeEmptyFolder]
   
    .EXAMPLE
        # Delete files older than 30 days
        Housekeep-Folder -Path "F:\backup\" -Days 30
        
        # Delete files AND empty folders older than 7 days
        Housekeep-Folder -Path "F:\backup\" -Days 7 -IncludeEmptyFolder
   
    .NOTES
        Do not run this script on system folder or risk bricking your system.

        Credits to Anthony Bartolo, with his initial posting @
        https://techcommunity.microsoft.com/t5/itops-talk-blog/powershell-basics-how-to-delete-files-older-than-x-days/ba-p/1255317
#>

function Housekeep-Folder { 
    
    [CmdletBinding(SupportsShouldProcess)] 

    Param( 
    [Parameter(Mandatory=$True,
               ValueFromPipeline=$true,
               HelpMessage="Path of Folder To Housekeep")]
    [string[]]$Path,
    
    [Parameter(Mandatory=$True,
               HelpMessage="Deleting Files more than how many days old?")]
    [ValidateRange(0, [int]::MaxValue)]
    [int]$Days,
    
    [Parameter(Mandatory=$False)]
    [switch]$IncludeEmptyFolder
    ) 


    Write-Host "Deleting files older than $Days days in [ $Path ]" -ForegroundColor Cyan

    Get-ChildItem $Path -Recurse -Force -ea 0 |
    ? {!$_.PsIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-$Days)} |
    ForEach-Object {
        If ($WhatIfPreference) { 
            $_ | Remove-Item -Force -WhatIf
        }
        else {
            $_ | Remove-Item -Force
        }
        
        Write-Host "Deleting file:" $_.FullName "- Last Modified:"$_.LastWriteTime.ToString("dd/MM/yyyy HH:mm:ss")
    }

    #Delete empty folders and subfolders
    if ($IncludeEmptyFolder) {
        Get-ChildItem $Path -Recurse -Force -ea 0 |
        ? {$_.PsIsContainer -eq $True} |
        ? {$_.getfiles().count -eq 0} |
        ForEach-Object {
            If ($WhatIfPreference) { 
                $_ | Remove-Item -Force -Recurse -WhatIf
            }
            else {
                $_ | Remove-Item -Force -Recurse
            }
            Write-Host "Deleting empty folder:" $_.FullName "- Last Modified:"$_.LastWriteTime.ToString("dd/MM/yyyy HH:mm:ss")
        }
    }
}

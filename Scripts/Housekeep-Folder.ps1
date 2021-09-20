<#
    .SYNOPSIS
        Housekeep a folder by deleting files and empty folders more than X days old
   
    .DESCRIPTION
        Function to check the last modified timestamp of all files within a folder and delete files that are more than X days old
    
    .PARAMETER Path
    	Specifies the folder path
    
    .PARAMETER Days
    	Specifies the number of days old

    .PARAMETER IncludeEmptyFolder
    	To delete empty folder with zero file

    .INPUTS
    System.String[] for folder paths

    .OUTPUTS
    None
    
    .EXAMPLE 
        Housekeep-Folder -Path "F:\backup\" -Days 30

        Deleting files older than 30 days in [ F:\backup ]
        Deleting file: "F:\backup\file1.txt" (Last Modified: 28/02/2001 13:36:48)
        Deleting file: "F:\backup\file2.txt" (Last Modified: 28/02/2001 13:36:50)  
        
    .EXAMPLE
        Housekeep-Folder -Path "F:\backup\" -Days 7 -IncludeEmptyFolder

        Deleting files older than 30 days in [ F:\backup ]
        Deleting file: "F:\backup\file1.txt" (Last Modified: 28/02/2001 13:36:48)
        Deleting file: "F:\backup\subfolder\file2.txt" (Last Modified: 28/02/2001 13:36:50)

        Deleting empty folders in [ F:\backup ]
        Deleting empty folder: "F:\backup\EmptyFolder" (Last Modified: 28/02/2001 13:40:41)
        Deleting empty folder: "F:\backup\EmptyFolder2" (Last Modified: 28/02/2001 13:40:41)
        Deleting empty folder: "F:\backup\EmptyFolder3" (Last Modified: 28/02/2001 13:40:41)
        
    .LINK
	    https://github.com/uXTrebla/Powershell
   
    .NOTES
        Do not run this script on system folder or risk bricking your system.
	
	Recommend to use -WhatIf parameter to test before actual running

        Credits to Anthony Bartolo, with his initial code posting @
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

    Process {
        Write-Host ("`nDeleting files older than $Days days in [ $Path ]") -ForegroundColor Cyan

        Get-ChildItem $Path -Recurse -Force -ea 0 |
        ? {!$_.PsIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-$Days)} |
        ForEach-Object {
            If ($WhatIfPreference) { 
                $_ | Remove-Item -Force -WhatIf
            }
            else {
                $_ | Remove-Item -Force
                Write-Host ('Deleting file: "{0}" (Last Modified: {1})' -f $_.FullName, $_.LastWriteTime.ToString("dd/MM/yyyy HH:mm:ss"))
            }
        }

        #Delete empty folders and subfolders
        if ($IncludeEmptyFolder) {
            Write-Host ("`nDeleting empty folders in [ $Path ]") -ForegroundColor Cyan

            Get-ChildItem $Path -Recurse -Force -ea 0 |
            ? {$_.PsIsContainer -eq $True} |
            ? {$_.getfiles().count -eq 0} |
            ForEach-Object {
                If ($WhatIfPreference) { 
                    $_ | Remove-Item -Force -Recurse -WhatIf
                }
                else {
                    $_ | Remove-Item -Force -Recurse
                    Write-Host ('Deleting empty folder: "{0}" (Last Modified: {1})' -f $_.FullName, $_.LastWriteTime.ToString("dd/MM/yyyy HH:mm:ss"))
                }
            }
        }
    }
}

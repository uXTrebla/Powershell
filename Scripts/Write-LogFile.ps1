<#
    .SYNOPSIS
        Function to write message to a physical file with timestamp
   
    .DESCRIPTION
        Function to write message to a physical file with timestamp
    
    .PARAMETER FilePath
    	Specifies the path to the output file.

    .PARAMETER Message
        Message to be written to file

    .PARAMETER Severity
        Support the following parameters: Information, Warning, Error

    .INPUTS
        None

    .OUTPUTS
        None

    .EXAMPLE
        Write-LogFile -FilePath "$env:HOMEPATH\Log.txt" -Message "This is a normal message"
        Write-LogFile -FilePath "$env:HOMEPATH\Log.txt" -Message "This is a warning message" -Severity Warning
        Write-LogFile -FilePath "$env:HOMEPATH\Log.txt" -Message "This is an error message" -Severity Error

    .LINK
	https://github.com/uXTrebla/Powershell
        
    .NOTES
        Author  : Albert Xu
        Version : 1.0 (09 Sep 2021)
#>

function Write-LogFile {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
 
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information','Warning','Error')]
        [string]$Severity = 'Information'
    )
    Process
    {
        try
        {
            switch ($Severity)
            {
                'Information' {
                    $logMessage = ("{0} [{1}] {2}" -f $(Get-Date -Format "yyyy-MM-dd HH:mm:ss"),'INFO',$Message) 
                    Write-Host $logMessage
                }
                'Warning' {
                    $logMessage = ("{0} [{1}] {2}" -f $(Get-Date -Format "yyyy-MM-dd HH:mm:ss"),'WARN',$Message) 
                    Write-Host $logMessage -ForegroundColor Yellow
                }
                'Error' {
                    $logMessage = ("{0} [{1}] {2}" -f $(Get-Date -Format "yyyy-MM-dd HH:mm:ss"),'ERROR',$Message) 
                    Write-Host $logMessage -ForegroundColor Red
                }
            }
            $logMessage | Out-File -FilePath $FilePath -Append
        }
        catch
        {
            Write-Error $_
        }
    }
}
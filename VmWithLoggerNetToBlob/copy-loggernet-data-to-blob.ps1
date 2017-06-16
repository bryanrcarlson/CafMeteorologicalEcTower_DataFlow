<#
.SYNOPSIS
Copies files located in specified path to an Azure Blob Storage container, moves those files to a backup directory, and logs the changes.
.PARAMETER dest
Azure Blob service endpoint and container
.PARAMETER path
Absolute directory path where the files to be copied/backedup are located
.PARAMETER backup
Absolute directory path where the files are to be moved to
.PARAMETER logpartial
Absolute directory path and prefix filename for log file (time stamp and txt extension will be added)
.DESCRIPTION
Version 0.1.0
Author: Bryan Carlson
Contact: bryan.carlson@ars.usda.gov
Last Update: 5/11/2017

Dependencies
  * Microsoft Azure blob storage account and container
  * AzCopy installed on machine
  * A file named "blob-key.private" with the access key to the blob storage account located at same directory level as this script
.NOTES
Intended to be called by Campbell Scientific's Task Master after sucessfully downloading CR3000 data using LoggerNet.
.EXAMPLE
./copy-loggernet-data-to-blob.ps1 -dest "https://ltarcafdatastream.blob.core.windows.net/ectower-cookeast/raw" -path "C:\Files\EcTowerData\CookEast" -backup "C:\Files\EcTowerDataBackup\CookEast" -logpartial "C:\Files\logs\copy-local-to-blob\cookeast"
.LINK
https://github.com/bryanrcarlson/LtarMeteorologicalEcTower_DataFlow
#>

#$path = "C:\Users\brcarlson\Desktop\EcTower\CookEast"
#$backup = "C:\Users\brcarlson\Desktop\EcTowerBackup\CookEast"
#$dest = "https://ltarcafdatastream.blob.core.windows.net/ectower-cookeast/raw"
#$logpartial = "C:\Users\brcarlson\Desktop\logs\cookeast"

param(
    [Parameter(Mandatory=$true)][string]$dest, 
    [Parameter(Mandatory=$true)][string]$path, 
    [Parameter(Mandatory=$true)][string]$backup, 
    [Parameter(Mandatory=$true)][string]$logpartial)

# Program expects a file containing the Azure Access Key to the blob storage account.  Put the key in quotes. 
$key = Get-Content .\blob-key.private

$log = "$logpartial-$(Get-Date -f yyyyMMdd-HHmm).txt"

$numtries = 5
$itr = 0

#Start-Transcript $log -Append -Force
"# Date: $(Get-Date -f yyyyMMdd-HHmm)" >> $log
"# File: $PSCommandPath" >> $log
"# Param(dest): $dest" >> $log
"# Param(path): $path" >> $log
"# Param(backup): $backup" >> $log
"# Param(logpartial): $logpartial" >> $log


"$([Environment]::NewLine)# Copying files to blob storage..." >> $log
Do {
    & "C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy\AzCopy.exe" /Source:$path /Dest:$dest /DestKey:$key /S /Y /XO /XN *>> $log
    $azcopyresult = $LASTEXITCODE 
    $itr++
} While (($azcopyresult -ne 0) -And ($itr -lt $numtries))

if($itr -ge $numtries)
{
    "$([Environment]::NewLine)# Could not copy files to Azure Blob storage, aborting..." >> $log
}

"$([Environment]::NewLine)# Moving files to backup..." >> $log
if($LASTEXITCODE -eq 0)
{
    #$files = Get-ChildItem -Path $path -Recurse
    #$files | Move-Item -Destination $backup -Verbose -Force *>> $log
    robocopy.exe $path $backup /S /MOV >> $log

    #"$([Environment]::NewLine)# Checking success..." >> $log
    #foreach($file in $files)
    #{
    #    $filename = [System.IO.Path]::GetFileName($file)
    #    $oldpath = [System.IO.Path]::Combine($path,$filename)
    #    $newpath = [System.IO.Path]::Combine($backup, $filename)
    #
    #    if(![System.IO.File]::Exists($oldpath) -And [System.IO.File]::Exists($newpath))
    #    {
    #        "Successfully moved: $oldpath to $newpath" >> $log
    #    }
    #    else
    #    {
    #        "Failed to move $oldpath to $newpath" >> $log
    #    }
    #}
}
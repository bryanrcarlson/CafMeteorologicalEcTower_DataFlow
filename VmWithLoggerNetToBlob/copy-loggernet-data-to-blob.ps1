<#
.SYNOPSIS
Copies files located in specified path to an Azure Blob Storage container, moves those files to a backup directory, deletes backup files older than 14 days (and logs older than 4 months), and logs the changes.
.PARAMETER dest
Azure Blob service endpoint and container
.PARAMETER path
Absolute directory path where the files to be copied/backedup are located
.PARAMETER backup
Absolute directory path where the files are to be moved to
.PARAMETER logpartial
Absolute directory path and prefix filename for log file (time stamp and txt extension will be added)
.DESCRIPTION
Version 0.1.2
Author: Bryan Carlson
Contact: bryan.carlson@usda.gov
Last Update: 10/07/2019

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

# Cleans up backups by removing files older than 2 weeks
$timeToLiveData = "-14"
$timeToLiveLogs = "-120"

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

# Copied all files in source to Azure Blog Storage
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

# On successful copy to Blob Storage, move files to backup
"$([Environment]::NewLine)# Moving files to backup..." >> $log
if($LASTEXITCODE -eq 0)
{
    robocopy.exe $path $backup /S /MOV >> $log
}

# Clean up data backups that are more than 14 days old
"$([Environment]::NewLine)# Deleting 14 day old backups..." >> $log
$CurrentDate = Get-Date
$DateToDeleteData = $CurrentDate.AddDays($timeToLiveData)
$dataCnt
Get-ChildItem -Path $backup -Recurse -File | Where-Object { $_.LastWriteTime -lt $DateToDeleteData } | ForEach-Object {
    Remove-Item $_.FullName
    if ($?) {$dataCnt++}
}
Add-Content $log -value "... deleted $dataCnt data files."

# Clean up logs that are more than 120 days old
"$([Environment]::NewLine)# Deleting 4 month old logs..." >> $log
$DateToDeleteLogs = $CurrentDate.AddDays($timeToLiveLogs)
$logpath = [System.IO.Path]::GetDirectoryName($log)
$logCnt
Get-ChildItem -Path $logpath -Recurse -File | Where-Object { $_.LastWriteTime -lt $DateToDeleteLogs } | ForEach-Object {
    Remove-Item $_.FullName
    if ($?) {$logCnt++}
}
Add-Content $log -value "... deleted $logCnt log files."
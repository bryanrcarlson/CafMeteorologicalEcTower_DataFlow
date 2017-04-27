## Introduction
Files, scripts, and code for processing metereological data coming off of the various EC Towers located on the CAF LTAR sites.

### Dependencies
* copy-{sitename}.bat
    * Existing directory that contains zero or more files to be backed up
    * Existing directory to copy files into
    * Existing directory to output log files to
    * A Microsoft Azure blob storage container
    * Powershell.exe in PATH and the following at the same directory level as this script: copy-loggernet-data-to-blob.ps1
* copy-loggernet-data-to-blob.ps1
    * Microsoft Azure blob storage account and container
    * AzCopy installed on machine
    * A file named "blob-key.private" with the access key to the blob storage account located at same directory level as this script

### Related
* Datalogger code and specifications: [https://bitbucket.org/wsular/ltar-rjcaf-eddyflux-tower/overview]
* Data flow diagram: [https://drive.google.com/file/d/0B-xCGE2dEH_QdUFLS0hma2NGRTg/view?usp=sharing]
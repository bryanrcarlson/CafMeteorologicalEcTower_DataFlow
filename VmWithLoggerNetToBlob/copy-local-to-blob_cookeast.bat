rem Dependencies:
rem     * Existing directory that contains zero or more files to be backed up
rem     * Existing directory to copy files into
rem     * Existing directory to output log files to
rem     * A Microsoft Azure blob storage container
rem     * Powershell.exe in PATH and the following at the same directory level as this script: copy-loggernet-data-to-blob.ps1
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& './copy-loggernet-data-to-blob.ps1' -path \"C:\\Files\\LtarCookEast\\\" -backup \"C:\\Files\\backups\\LtarCookEast\" -dest \"https://ltarcafdatastream.blob.core.windows.net/cookeast-ectower/raw\" -logpartial \"C:\\Files\\logs\\copy-cookeas/rawt\""
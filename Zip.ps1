#Parameters
$ErrorActionPreference = "SilentlyContinue"
$zipURL = ""
$date = Get-Date -Format "yyyy-MM-dd"
$destinationDisk = "C:\"
$destinationFolderName = "Share"
$destinationFolder = $destinationDisk + $destinationFolderName
$destination = $destinationFolder + "\$date"

$LogFolder = $destinationFolder + "\Log"
$logFile = $LogFolder + "\log.txt"

$zipFilePath = $destination + "\zip_" + $date + ".zip"
$yesterday = Get-Date((Get-Date).AddDays(-1)) -Format "yyyy-MM-dd"
$oldFilePath = $destinationFolder + "\" + $yesterday + "\zip_" + $yesterday + ".zip"

#Create Folders
if (!(Test-Path -Path $destinationFolder)) {

    New-Item -Path $destinationDisk -Name $destinationFolder -ItemType "Directory"
}
if (!(Test-Path -Path $destination)) {

    New-Item -Path $destinationFolder -Name $date -ItemType "Directory"
}
if (!(Test-Path -Path $LogFolder)) {

    New-Item -Path $destinationFolder -Name "Log" -ItemType "Directory"
}

(Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " Start" | Out-File $logFile -Append

#Fetch zip from URL

(Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " Fetching zip file" | Out-File $logFile -Append
try {
    Invoke-RestMethod -Uri $zipURL -OutFile $zipFilePath
    (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " Zip file successfully downloaded" | Out-File $logFile -Append
}
catch {
    "An error occured please check log file"
    (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " An error occured during file download. Please check internet connection, URL, or contact eVisitor team." | Out-File $logFile -Append
    break
}

#Compare files old/new
(Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " Comparing file $zipFilePath with $oldFilePath"

if ((Get-FileHash $oldFilePath).Hash -eq (Get-FileHash $zipFilePath).Hash) {

    (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " Files are identical. Ending process" | Out-File $logFile -Append
    (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " Success" | Out-File $logFile -Append

}
else {

    #Unzip

    try {
    (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " Files are not identical. Unpacking zip file" | Out-File $logFile -Append
        Expand-Archive $zipFilePath -DestinationPath $destination -Force
    (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " Zip file unpacked" | Out-File $logFile -Append
    (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " Success" | Out-File $logFile -Append
    }
    catch {
        "An error occured please check log file"
        (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " An error occured during the file extraction. File might be corrupt. Plese try with downloading again or contact eVisitor team." | Out-File $logFile -Append
    }
}
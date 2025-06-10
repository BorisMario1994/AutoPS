# Get the directory where the script is located
$baseDir = $PSScriptRoot
$today = Get-Date
$dateStr = $today.ToString("yyyyMMdd")
$cutoffDate = $today.AddMonths(-1)
$targetFolder = Join-Path $baseDir "HDD${dateStr}M"

Write-Host "Creating folder: $targetFolder"
New-Item -Path $targetFolder -ItemType Directory -Force | Out-Null

# Get all folders in base directory (excluding the target folder itself)
$folders = Get-ChildItem -Path $baseDir -Directory | Where-Object { $_.FullName -ne $targetFolder }

if ($folders.Count -eq 0) {
    Write-Host "No folders found in $baseDir to move."
    exit
}

$totalFolders = $folders.Count
$folderIndex = 0

foreach ($folder in $folders) {
    $folderIndex++
    $sourcePath = $folder.FullName
    $destPath = Join-Path $targetFolder $folder.Name

    # Show folder moving progress
    Write-Progress -Activity "Moving Folders" -Status "Moving: $($folder.Name)" -PercentComplete (($folderIndex / $totalFolders) * 100)

    Write-Host "Moving '$sourcePath' to '$destPath'"
    try {
       Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force
    } catch {
        Write-Warning "Failed to move ${sourcePath}: $_"
        continue
    }

    # Clean up old files in the moved folder
    $files = Get-ChildItem -Path $destPath -Recurse -File
    $totalFiles = $files.Count
    $fileIndex = 0

    #foreach ($file in $files) {
       # $fileIndex++
       # Write-Progress -Activity "Deleting Old Files" -Status "Checking: $($file.Name)" -PercentComplete (($fileIndex / $totalFiles) * 100)

       # if ($file.LastWriteTime -lt $cutoffDate -or $file.LastWriteTime -gt $today) {
       #     Write-Host "Deleting old file: $($file.FullName)"
       #     Remove-Item -Path $file.FullName -Force
       # }
  #  }
}

Write-Progress -Activity "Done" -Completed
Write-Host "`n✅ Monthly completed."

# Get the directory where the script is located
$baseDir = $PSScriptRoot
$today = Get-Date
$dateStr = $today.ToString("yyyyMMdd")
$cutoffDate = $today.AddDays(-7)
$targetFolder = Join-Path $baseDir "HDD${dateStr}W"

Write-Host "Creating folder: $targetFolder"
New-Item -Path $targetFolder -ItemType Directory -Force | Out-Null

# Get all folders in base directory (excluding the target folder itself)
$folders = Get-ChildItem -Path $baseDir -Directory | Where-Object { $_.FullName -ne $targetFolder }

if ($folders.Count -eq 0) {
    Write-Host "No folders found in $baseDir to move."
    exit
}

foreach ($folder in $folders) {
    $sourcePath = $folder.FullName
    $destPath = Join-Path $targetFolder $folder.Name

    Write-Host "Moving '$sourcePath' to '$destPath'"
    try {
    Move-Item -Path $sourcePath -Destination $destPath -Force
} catch {
    Write-Warning "Failed to move ${sourcePath}: $_"
    continue
}

    # Clean up old files in the moved folder
    $files = Get-ChildItem -Path $destPath -Recurse -File
    foreach ($file in $files) {
        if ($file.LastWriteTime -lt $cutoffDate -or $file.LastWriteTime -gt $today) {
            Write-Host "Deleting old file: $($file.FullName)"
            Remove-Item -Path $file.FullName -Force
        }
    }
}

Write-Host "`nWeekly cleanup completed."

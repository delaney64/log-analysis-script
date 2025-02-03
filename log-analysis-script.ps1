# Get the current directory where the script is running
$currentDir = Get-Location
$outputFile = Join-Path $currentDir "sensor_disconnect_analysis.txt"

Write-Host "Starting log analysis in directory: $currentDir"

# Define the time range we're interested in
$startTime = Get-Date "2024-01-21 07:00:00Z"
$endTime = Get-Date "2024-01-21 10:00:00Z"

# Extended keywords for connectivity issues
$keywords = @(
    "disconnect",
    "connection lost",
    "connection refused",
    "timeout",
    "error",
    "failed",
    "failure",
    "network",
    "AWS",
    "USM",
    "sensor",
    "offline",
    "NetworkManager",
    "connectivity",
    "SSM",
    "agent",
    "critical",
    "warning",
    "unable to connect",
    "connection terminated"
)

try {
    # Initialize output file with UTF8 encoding
    $utf8NoBOM = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($outputFile, @("Log Analysis Report - AWS USM Anywhere Sensor Disconnection"), $utf8NoBOM)
    Add-Content -Path $outputFile -Value "Time Range: $startTime to $endTime"
    Add-Content -Path $outputFile -Value ("=" * 80)

    # Get all files in the directory
    $files = Get-ChildItem -Path $currentDir -File | Sort-Object Length -Descending

    Write-Host "Found $($files.Count) files to analyze"
    Add-Content -Path $outputFile -Value "Total files to analyze: $($files.Count)"

    $processedFiles = 0
    $matchingFiles = 0
    $totalMatches = 0

    foreach ($file in $files) {
        $processedFiles++
        $fileMatches = 0
        $hasContent = $false

        Write-Progress -Activity "Analyzing logs" -Status "$processedFiles of $($files.Count) files" -PercentComplete (($processedFiles / $files.Count) * 100)

        Write-Host "Processing ($processedFiles/$($files.Count)): $($file.Name) - Size: $([math]::Round($file.Length/1KB, 2)) KB"

        try {
            # Try different encodings if needed
            $content = Get-Content $file.FullName -Encoding UTF8 -ErrorAction Stop

            Add-Content -Path $outputFile -Value "`n`nFile: $($file.Name)"
            Add-Content -Path $outputFile -Value "Size: $([math]::Round($file.Length/1KB, 2)) KB"
            Add-Content -Path $outputFile -Value ("-" * 80)

            foreach ($line in $content) {
                $foundMatch = $false

                foreach ($keyword in $keywords) {
                    if ($line -match $keyword -and -not $foundMatch) {
                        $foundMatch = $true
                        $fileMatches++
                        $totalMatches++
                        $hasContent = $true

                        # Try to extract timestamp
                        $timestamp = "No Timestamp"
                        if ($line -match '\[(.*?)\]') {
                            try {
                                $timestamp = [DateTime]::Parse($matches[1])
                            } catch {
                                # Keep default "No Timestamp" if parsing fails
                            }
                        }
                        elseif ($line -match '\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}') {
                            try {
                                $timestamp = [DateTime]::Parse($matches[0])
                            } catch {
                                # Keep default "No Timestamp" if parsing fails
                            }
                        }

                        # Only add lines within our time range or without timestamp
                        if ($timestamp -eq "No Timestamp" -or
                                ($timestamp -ge $startTime -and $timestamp -le $endTime)) {
                            Add-Content -Path $outputFile -Value "[$timestamp] $line"
                        }
                    }
                }
            }

            if ($fileMatches -gt 0) {
                $matchingFiles++
                Add-Content -Path $outputFile -Value "`nMatches found in this file: $fileMatches"
            }
        }
        catch {
            Write-Host "Error processing file $($file.Name): $_"
            Add-Content -Path $outputFile -Value "Error processing file: $_"
        }
    }

    # Add summary
    Add-Content -Path $outputFile -Value "`n`n$('=' * 80)"
    Add-Content -Path $outputFile -Value "Analysis Summary"
    Add-Content -Path $outputFile -Value "-" * 80
    Add-Content -Path $outputFile -Value "Total files processed: $processedFiles"
    Add-Content -Path $outputFile -Value "Files with matches: $matchingFiles"
    Add-Content -Path $outputFile -Value "Total matches found: $totalMatches"
    Add-Content -Path $outputFile -Value "Analysis completed at: $(Get-Date)"

    Write-Host "`nAnalysis complete!"
    Write-Host "Files processed: $processedFiles"
    Write-Host "Files with matches: $matchingFiles"
    Write-Host "Total matches found: $totalMatches"
    Write-Host "Results saved to: $outputFile"
}
catch {
    Write-Host "A critical error occurred: $_"
    Write-Host "Stack trace: $($_.ScriptStackTrace)"
}
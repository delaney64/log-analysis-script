# Get the current directory where the script is running
$currentDir = Get-Location
$outputFile = Join-Path $currentDir "sensor_disconnect_analysis.txt"

Write-Host "Current directory: $currentDir"
Write-Host "Output will be saved to: $outputFile"

# Define the time range we're interested in
$startTime = Get-Date "2024-01-21 07:00:00Z"
$endTime = Get-Date "2024-01-21 10:00:00Z"

# Priority log files for sensor connectivity
$priorityLogs = @(
    "amazon-ssm-agent.log",
    "alienvault-ngnex-error.log",
    "syslog-ng-error.log",
    "errors.log",
    "alienvault_network_debug.log",
    "alienvault_network_check.log",
    "monitor.log",
    "unimatrix.log",
    "cloud-init-output.log"
)

# Extended keywords for AWS USM sensor issues
$keywords = @(
    "disconnect",
    "connection lost",
    "connection refused",
    "timeout",
    "network error",
    "AWS",
    "USM",
    "sensor",
    "offline",
    "failed",
    "NetworkManager",
    "connectivity",
    "SSM",
    "agent status"
)

try {
    # Create or clear the output file
    "Log Analysis Report - AWS USM Anywhere Sensor Disconnection" | Out-File -FilePath $outputFile -Force
    "Time Range: $startTime to $endTime" | Out-File -FilePath $outputFile -Append
    "=" * 80 | Out-File -FilePath $outputFile -Append

    # First process priority logs
    Write-Host "Processing priority log files..."
    foreach ($logName in $priorityLogs) {
        $logPath = Join-Path $currentDir $logName
        if (Test-Path $logPath) {
            Write-Host "Found priority log: $logName"
            "`nAnalyzing Priority Log: $logName" | Out-File -FilePath $outputFile -Append
            "-" * 80 | Out-File -FilePath $outputFile -Append
            
            Get-Content $logPath | ForEach-Object {
                $line = $_
                foreach ($keyword in $keywords) {
                    if ($line -match $keyword) {
                        if ($line -match '\[(.*?)\]' -or $line -match '\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}') {
                            try {
                                $timestamp = [DateTime]::Parse($matches[1])
                                if ($timestamp -ge $startTime -and $timestamp -le $endTime) {
                                    "[$timestamp] $line" | Out-File -FilePath $outputFile -Append
                                }
                            }
                            catch {
                                "[Timestamp Unknown] $line" | Out-File -FilePath $outputFile -Append
                            }
                        }
                        else {
                            "[No Timestamp] $line" | Out-File -FilePath $outputFile -Append
                        }
                    }
                }
            }
        }
        else {
            Write-Host "Priority log not found: $logName"
        }
    }

    # Then process all remaining .log files
    Write-Host "Processing remaining log files..."
    Get-ChildItem -Path $currentDir -Filter "*.log" | Where-Object { $_.Name -notin $priorityLogs } | ForEach-Object {
        $currentFile = $_
        Write-Host "Processing: $($currentFile.Name)"
        
        "`nAnalyzing: $($currentFile.Name)" | Out-File -FilePath $outputFile -Append
        "-" * 80 | Out-File -FilePath $outputFile -Append
        
        Get-Content $currentFile.FullName | ForEach-Object {
            $line = $_
            foreach ($keyword in $keywords) {
                if ($line -match $keyword) {
                    if ($line -match '\[(.*?)\]' -or $line -match '\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}') {
                        try {
                            $timestamp = [DateTime]::Parse($matches[1])
                            if ($timestamp -ge $startTime -and $timestamp -le $endTime) {
                                "[$timestamp] $line" | Out-File -FilePath $outputFile -Append
                            }
                        }
                        catch {
                            "[Timestamp Unknown] $line" | Out-File -FilePath $outputFile -Append
                        }
                    }
                    else {
                        "[No Timestamp] $line" | Out-File -FilePath $outputFile -Append
                    }
                }
            }
        }
    }

    # Add summary footer
    "`n" + "=" * 80 | Out-File -FilePath $outputFile -Append
    "Analysis completed at $(Get-Date)" | Out-File -FilePath $outputFile -Append

    if (Test-Path $outputFile) {
        Write-Host "Analysis complete. Results have been saved to: $outputFile"
        Write-Host "File size: $((Get-Item $outputFile).Length) bytes"
    }
    else {
        Write-Host "Error: Output file was not created!"
    }
}
catch {
    Write-Host "An error occurred: $_"
    Write-Host "Stack trace: $($_.ScriptStackTrace)"
}
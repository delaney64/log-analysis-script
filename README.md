# AWS USM Anywhere Sensor Disconnect Analysis Tool

A PowerShell script designed to analyze log files from AWS USM Anywhere sensors to identify and investigate sensor disconnection events within a specified time range.

## Overview

This script processes multiple log files to identify patterns and events related to AWS USM (Unified Security Management) sensor connectivity issues. It searches through priority security logs and system logs to extract relevant entries that may indicate the cause of sensor disconnections.

## Features

- **Priority Log Processing**: Analyzes critical log files first for faster troubleshooting
- **Flexible Keyword Matching**: Searches for multiple connectivity-related keywords
- **Time-Range Filtering**: Focuses analysis on specific time windows
- **Automated Report Generation**: Outputs findings to a structured text file
- **Comprehensive Coverage**: Processes all `.log` files in the working directory

## Requirements

- Windows PowerShell 5.1 or later
- Read access to log files
- Sufficient disk space for output file

## Usage

### Basic Usage

1. Place the script in the directory containing your log files
2. Update the time range variables if needed:
   ```powershell
   $startTime = Get-Date "2024-01-21 07:00:00Z"
   $endTime = Get-Date "2024-01-21 10:00:00Z"
   ```
3. Run the script:
   ```powershell
   .\sensor_disconnect_analysis.ps1
   ```

### Output

The script generates a file named `sensor_disconnect_analysis.txt` in the current directory containing:
- Timestamp-filtered log entries
- Priority log analysis results
- All matching entries from remaining log files
- Analysis completion summary

## Priority Log Files

The script prioritizes the following logs known to contain sensor connectivity information:

- `amazon-ssm-agent.log` - AWS Systems Manager agent logs
- `alienvault-ngnex-error.log` - AlienVault NGNEX error logs
- `syslog-ng-error.log` - Syslog-ng error messages
- `errors.log` - General error logs
- `alienvault_network_debug.log` - Network debugging logs
- `alienvault_network_check.log` - Network connectivity checks
- `monitor.log` - System monitoring logs
- `unimatrix.log` - Unimatrix service logs
- `cloud-init-output.log` - Cloud initialization logs

## Search Keywords

The script searches for the following indicators of connectivity issues:

- disconnect
- connection lost
- connection refused
- timeout
- network error
- AWS
- USM
- sensor
- offline
- failed
- NetworkManager
- connectivity
- SSM
- agent status

## Customization

### Modify Time Range

Edit the `$startTime` and `$endTime` variables to match your investigation period:

```powershell
$startTime = Get-Date "YYYY-MM-DD HH:mm:ssZ"
$endTime = Get-Date "YYYY-MM-DD HH:mm:ssZ"
```

### Add Keywords

Extend the `$keywords` array to search for additional terms:

```powershell
$keywords = @(
    "disconnect",
    "your_custom_keyword"
)
```

### Add Priority Logs

Add log filenames to the `$priorityLogs` array:

```powershell
$priorityLogs = @(
    "amazon-ssm-agent.log",
    "your_custom_log.log"
)
```

## Output Format

```
Log Analysis Report - AWS USM Anywhere Sensor Disconnection
Time Range: 01/21/2024 07:00:00 to 01/21/2024 10:00:00
================================================================================

Analyzing Priority Log: amazon-ssm-agent.log
--------------------------------------------------------------------------------
[01/21/2024 08:15:23] Connection lost to AWS endpoint
[01/21/2024 08:15:45] SSM agent status: offline

...
```

## Troubleshooting

### No Results Found

- Verify log files exist in the current directory
- Check that the time range includes the incident period
- Ensure log file timestamps match the expected format
- Verify keyword relevance to your log format

### Script Execution Errors

If you encounter execution policy errors:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Use Cases

- **Incident Response**: Quickly identify the timeline and cause of sensor disconnections
- **Root Cause Analysis**: Correlate events across multiple log sources
- **Audit Trail**: Document connectivity issues for compliance purposes
- **Pattern Recognition**: Identify recurring connectivity problems

## Contributing

Feel free to submit issues or pull requests to improve the script's functionality.

## License

MIT License - Feel free to use and modify for your security operations needs.

## Author

Created for cybersecurity operations and incident response workflows.

---

**Note**: This script is designed for AWS USM Anywhere sensor environments. Adapt the priority logs and keywords to match your specific deployment and logging configuration.

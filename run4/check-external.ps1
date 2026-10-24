<#
.SYNOPSIS
  GreenMind Hackathon: check the model endpoint from a machine outside the VM.

.DESCRIPTION
  Run on your own PC, not on the VM. A request to the public IP from inside the
  VM can fail or succeed for NAT-loopback reasons that say nothing about outside
  clients. Checks TCP reachability, GET /models (served id and context length),
  and one small chat completion with thinking disabled.

  Exit code 0 = reachable and serving the expected model; 1 = do not benchmark.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File run4\check-external.ps1
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File run4\check-external.ps1 -ExpectedMaxLen 32768
#>
param(
    [string]$BaseUrl = "http://103.153.118.56:8000/v1",
    [string]$ExpectedModel = "mango1.5-awq-w4a16",
    [int]$ExpectedMaxLen = 40960,
    [switch]$SkipChat
)

$ErrorActionPreference = "Stop"
$script:Failures = 0

function Pass([string]$Message) { Write-Host "[PASS] $Message" -ForegroundColor Green }
function Warn([string]$Message) { Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Fail([string]$Message) {
    Write-Host "[FAIL] $Message" -ForegroundColor Red
    $script:Failures++
}

function Finish {
    Write-Host ""
    if ($script:Failures -eq 0) {
        Write-Host "RESULT: EXTERNAL CHECK PASSED"
        exit 0
    }
    Write-Host "RESULT: EXTERNAL CHECK FAILED ($($script:Failures) check(s)). Do not benchmark."
    Write-Host "Check the Docker port mapping, VM firewall, cloud security rules, and routing."
    exit 1
}

$BaseUrl = $BaseUrl.TrimEnd("/")
$Uri = [Uri]$BaseUrl
Write-Host "=========================================="
Write-Host " GreenMind Hackathon: EXTERNAL ENDPOINT CHECK"
Write-Host "=========================================="
Write-Host "Time:     $(Get-Date -Format o)"
Write-Host "Client:   $env:COMPUTERNAME"
Write-Host "Endpoint: $BaseUrl"
Write-Host ""

# 1. TCP reachability, separate from HTTP so a firewall drop is obvious.
$Tcp = New-Object System.Net.Sockets.TcpClient
try {
    $Attempt = $Tcp.BeginConnect($Uri.Host, $Uri.Port, $null, $null)
    if ($Attempt.AsyncWaitHandle.WaitOne(5000) -and $Tcp.Connected) {
        $Tcp.EndConnect($Attempt)
        Pass "TCP connect to $($Uri.Host):$($Uri.Port)"
    } else {
        Fail "TCP connect to $($Uri.Host):$($Uri.Port) timed out after 5 s"
        Finish
    }
} catch {
    Fail "TCP connect to $($Uri.Host):$($Uri.Port) failed: $($_.Exception.Message)"
    Finish
} finally {
    $Tcp.Close()
}

# 2. GET /models
try {
    $Models = Invoke-RestMethod -Uri "$BaseUrl/models" -Method Get -TimeoutSec 15
} catch {
    Fail "GET /models failed: $($_.Exception.Message)"
    Finish
}
$Items = @($Models.data)
$Ids = @($Items | ForEach-Object { $_.id })
Write-Host "       Model ids: $($Ids -join ', ')"
$Match = $Items | Where-Object { $_.id -eq $ExpectedModel } | Select-Object -First 1
if ($null -eq $Match) {
    Fail "Endpoint answered, but '$ExpectedModel' is not served"
    Finish
}
Pass "GET /models serves $ExpectedModel"

if ($null -ne $Match.max_model_len) {
    if ([int]$Match.max_model_len -eq $ExpectedMaxLen) {
        Pass "Served context length is $ExpectedMaxLen"
    } else {
        Fail "Served context length is $($Match.max_model_len), expected $ExpectedMaxLen"
    }
} else {
    Warn "/models did not report max_model_len"
}

# 3. One small chat completion, thinking off so the reply is deterministic.
if (-not $SkipChat) {
    $Body = @{
        model = $ExpectedModel
        messages = @(@{ role = "user"; content = "Reply with exactly: PREFLIGHT_OK" })
        max_tokens = 64
        temperature = 0
        chat_template_kwargs = @{ enable_thinking = $false }
    } | ConvertTo-Json -Depth 6 -Compress
    try {
        $Chat = Invoke-RestMethod -Uri "$BaseUrl/chat/completions" -Method Post `
            -ContentType "application/json" -Body $Body -TimeoutSec 90
        $Reply = [string]$Chat.choices[0].message.content
        Write-Host "       Reply: '$Reply'"
        if ($Reply -match "PREFLIGHT_OK") {
            Pass "Chat completion over the public endpoint"
        } else {
            Fail "Chat completion returned, but without PREFLIGHT_OK"
        }
    } catch {
        Fail "Chat completion failed: $($_.Exception.Message)"
    }
}

Warn "This endpoint has no authentication. Limit inbound port $($Uri.Port) to trusted addresses."
Finish

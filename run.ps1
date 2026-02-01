# ==========================================
# 核心配置
$DownloadURL = 'https://get.elyar.de/MAS_AIO.cmd'
# ==========================================

# 1. 设置协议
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

# 2. 准备路径
$rand = [Guid]::NewGuid().Guid
$FilePath = "$env:TEMP\MAS_$rand.cmd"

# 3. 开始下载
try {
    Write-Host "正在连接 get.elyar.de 下载激活组件..." -ForegroundColor Cyan
    
    # === 修复点：移除了复杂的 Get-Date 参数，改用 Get-Random ===
    # 这样生成的 URL 绝对纯净，不会有格式错误
    $CleanURL = "$DownloadURL?r=$(Get-Random)"
    
    if ($PSVersionTable.PSVersion.Major -ge 3) {
        Invoke-RestMethod -Uri $CleanURL -OutFile $FilePath
    } else {
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($CleanURL, $FilePath)
    }
}
catch {
    Write-Host "下载失败！请检查您的网络连接。" -ForegroundColor Red
    Write-Host "错误详情: $($_.Exception.Message)" -ForegroundColor Red
    
    # 调试信息：如果再次失败，让用户看到尝试下载的链接到底长什么样
    Write-Host "调试链接: $CleanURL" -ForegroundColor Gray
    return
}

# 4. 运行
if (Test-Path $FilePath) {
    Write-Host "下载成功，正在启动..." -ForegroundColor Green
    $process = Start-Process -FilePath "$env:SystemRoot\system32\cmd.exe" `
        -ArgumentList "/c """"$FilePath"" $args""" `
        -Verb RunAs -PassThru -Wait
    Remove-Item -Path $FilePath -ErrorAction SilentlyContinue
}
